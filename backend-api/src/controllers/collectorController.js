const supabase = require('../config/supabase');
const { getRoute } = require('../services/osrmService');
const { transferBalance, addEcoPoints } = require('../services/walletService');
const { getCatalogPrices } = require('../services/scraperService');
const { appendStatusHistory } = require('../services/trackingService');
const { paginate } = require('../utils/paginate');

function parseLocation(loc) {
  if (!loc) return null;
  if (loc.type === 'Point' && loc.coordinates) return { lng: loc.coordinates[0], lat: loc.coordinates[1] };
  if (typeof loc === 'string' && loc.startsWith('01')) {
    const buf = Buffer.from(loc, 'hex');
    return { lng: buf.readDoubleLE(9), lat: buf.readDoubleLE(17) };
  }
  const m = String(loc).match(/POINT\(([^ ]+) ([^ ]+)\)/);
  if (m) return { lng: parseFloat(m[1]), lat: parseFloat(m[2]) };
  return null;
}

function haversine(lng1, lat1, lng2, lat2) {
  const R = 6371000;
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLng = (lng2 - lng1) * Math.PI / 180;
  const a = Math.sin(dLat / 2) ** 2 + Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * Math.sin(dLng / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

async function updateLocation(req, res, next) {
  try {
    const { lng, lat, is_online } = req.body;
    if (!lng || !lat) return res.status(400).json({ success: false, message: 'lng and lat are required' });
    const update = { location: `POINT(${lng} ${lat})` };
    if (typeof is_online === 'boolean') update.is_online = is_online;
    const { data, error } = await supabase.from('users').update(update).eq('id', req.user.id).select().single();
    if (error) throw error;
    res.json({ success: true, message: 'Location updated', data });
  } catch (error) { next(error); }
}

async function getNearbyOrders(req, res, next) {
  try {
    const { radius = 5000 } = req.query;
    const { data: collector } = await supabase.from('users').select('location').eq('id', req.user.id).single();
    if (!collector?.location) return res.status(400).json({ success: false, message: 'Update your location first' });
    const loc = parseLocation(collector.location);
    if (!loc) return res.status(400).json({ success: false, message: 'Could not parse location' });

    const { data: orders, error } = await supabase.from('orders').select('id, user_id, item_type, est_weight, pickup_address, pickup_location, photo_url, created_at').eq('status', 'pending');
    if (error) throw error;

    const nearby = (orders || []).filter(o => {
      const ol = parseLocation(o.pickup_location);
      if (!ol) return false;
      o.distance_meters = Math.round(haversine(loc.lng, loc.lat, ol.lng, ol.lat));
      return o.distance_meters <= parseFloat(radius);
    }).sort((a, b) => a.distance_meters - b.distance_meters);

    res.json({ success: true, data: nearby });
  } catch (error) { next(error); }
}

async function acceptOrder(req, res, next) {
  try {
    const { id } = req.params;
    const { data: order } = await supabase.from('orders').select('status').eq('id', id).single();
    if (!order) return res.status(404).json({ success: false, message: 'Order not found' });
    if (order.status !== 'pending') return res.status(400).json({ success: false, message: `Cannot accept order with status: ${order.status}` });

    const { data, error } = await supabase.from('orders').update({ collector_id: req.user.id, status: 'accepted' }).eq('id', id).eq('status', 'pending').select().single();
    if (error?.code === 'PGRST116') return res.status(409).json({ success: false, message: 'Already accepted by another collector' });
    if (error) throw error;

    appendStatusHistory(id, 'accepted', req.user.id);
    res.json({ success: true, message: 'Order accepted', data });
  } catch (error) { next(error); }
}

async function startEnRoute(req, res, next) {
  try {
    const { id } = req.params;
    const { data, error } = await supabase.from('orders').update({ status: 'en_route' }).eq('id', id).eq('collector_id', req.user.id).eq('status', 'accepted').select().single();
    if (error || !data) return res.status(400).json({ success: false, message: 'Cannot start en-route' });

    appendStatusHistory(id, 'en_route', req.user.id);
    res.json({ success: true, message: 'En-route', data });
  } catch (error) { next(error); }
}

async function getOrderRoute(req, res, next) {
  try {
    const { id } = req.params;
    const { data: collector } = await supabase.from('users').select('location').eq('id', req.user.id).single();
    const { data: order } = await supabase.from('orders').select('pickup_location').eq('id', id).single();
    if (!collector?.location || !order?.pickup_location) return res.status(400).json({ success: false, message: 'Location data missing' });
    const cl = parseLocation(collector.location);
    const ol = parseLocation(order.pickup_location);
    if (!cl || !ol) return res.status(400).json({ success: false, message: 'Invalid location data' });
    const route = await getRoute(cl.lng, cl.lat, ol.lng, ol.lat);
    res.json({ success: true, data: route });
  } catch (error) { next(error); }
}

async function completeOrderWithPayment(req, res, next) {
  try {
    const { id } = req.params;
    const { actual_weight } = req.body;
    if (!actual_weight || actual_weight <= 0) return res.status(400).json({ success: false, message: 'Valid actual_weight is required' });

    const { data: order } = await supabase.from('orders').select('*').eq('id', id).eq('collector_id', req.user.id).single();
    if (!order) return res.status(404).json({ success: false, message: 'Order not found' });
    if (order.status !== 'en_route' && order.status !== 'accepted') {
      return res.status(400).json({ success: false, message: `Cannot complete order with status: ${order.status}` });
    }

    const prices = await getCatalogPrices();
    const price = prices.find(p => p.item_name.toLowerCase() === order.item_type.toLowerCase());
    if (!price) return res.status(400).json({ success: false, message: `Price not found for ${order.item_type}` });

    const total = parseFloat((actual_weight * price.current_price).toFixed(2));
    const payment = await transferBalance(req.user.id, order.user_id, total, id);
    await addEcoPoints(order.user_id, 10);

    const { data: updated, error } = await supabase.from('orders').update({
      status: 'completed', actual_weight, total_amount: total, completed_at: new Date().toISOString()
    }).eq('id', id).select().single();
    if (error) throw error;

    appendStatusHistory(id, 'completed', req.user.id);
    res.json({ success: true, message: 'Order completed', data: { order: updated, payment } });
  } catch (error) { next(error); }
}

async function getCollectorOrders(req, res, next) {
  try {
    const { page, limit, status } = req.query;
    let query = supabase.from('orders').select('*', { count: 'exact' }).eq('collector_id', req.user.id).order('created_at', { ascending: false });
    if (status) query = query.eq('status', status);
    const result = await paginate(query, page, limit);
    res.json({ success: true, ...result });
  } catch (error) { next(error); }
}

async function getEarnings(req, res, next) {
  try {
    const { period } = req.query;
    let query = supabase.from('transactions')
      .select('*')
      .eq('receiver_id', req.user.id)
      .eq('type', 'payment')
      .order('created_at', { ascending: false });

    if (period === 'day') {
      const start = new Date(); start.setHours(0, 0, 0, 0);
      query = query.gte('created_at', start.toISOString());
    } else if (period === 'week') {
      const start = new Date(); start.setDate(start.getDate() - 7);
      query = query.gte('created_at', start.toISOString());
    } else if (period === 'month') {
      const start = new Date(); start.setMonth(start.getMonth() - 1);
      query = query.gte('created_at', start.toISOString());
    }

    const { data, error } = await query;
    if (error) throw error;

    const total = (data || []).reduce((s, t) => s + parseFloat(t.amount || 0), 0);
    const count = (data || []).length;

    const { data: collector } = await supabase.from('users').select('wallet_balance').eq('id', req.user.id).single();

    res.json({
      success: true,
      data: {
        wallet_balance: parseFloat(collector?.wallet_balance || 0),
        total_earnings: parseFloat(total.toFixed(2)),
        total_orders: count,
        period: period || 'all',
        transactions: data || []
      }
    });
  } catch (error) { next(error); }
}

module.exports = { updateLocation, getNearbyOrders, acceptOrder, startEnRoute, getOrderRoute, completeOrderWithPayment, getCollectorOrders, getEarnings };
