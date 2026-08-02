const crypto = require('crypto');
const supabase = require('../config/supabase');
const { analyzeWasteImage } = require('../services/aiVisionService');
const { getRoute } = require('../services/osrmService');
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

async function analyzeImage(req, res, next) {
  try {
    const { photo_url } = req.body;
    if (!photo_url) return res.status(400).json({ success: false, message: 'photo_url is required' });
    const result = await analyzeWasteImage(photo_url);
    res.json({ success: true, data: result });
  } catch (error) { next(error); }
}

async function createOrder(req, res, next) {
  try {
    const userId = req.user.id;
    const { item_type, est_weight, pickup_lng, pickup_lat, pickup_address, notes, photo_url } = req.body;
    if (!item_type || !pickup_lng || !pickup_lat) {
      return res.status(400).json({ success: false, message: 'item_type, pickup_lng, and pickup_lat are required' });
    }
    const { data, error } = await supabase.from('orders').insert({
      id: crypto.randomUUID(), user_id: userId, item_type, est_weight, pickup_address, notes, photo_url,
      pickup_location: `POINT(${pickup_lng} ${pickup_lat})`
    }).select().single();
    if (error) throw error;
    res.status(201).json({ success: true, data });
  } catch (error) { next(error); }
}

async function getUserOrders(req, res, next) {
  try {
    const { page, limit, status } = req.query;
    let query = supabase.from('orders').select('*', { count: 'exact' }).eq('user_id', req.user.id).order('created_at', { ascending: false });
    if (status) query = query.eq('status', status);
    const result = await paginate(query, page, limit);
    res.json({ success: true, ...result });
  } catch (error) { next(error); }
}

async function getOrderById(req, res, next) {
  try {
    const { id } = req.params;
    const { data, error } = await supabase.from('orders').select('*').eq('id', id).eq('user_id', req.user.id).single();
    if (error) return res.status(404).json({ success: false, message: 'Order not found' });
    res.json({ success: true, data });
  } catch (error) { next(error); }
}

async function cancelOrder(req, res, next) {
  try {
    const { id } = req.params;
    const { data: order } = await supabase.from('orders').select('status').eq('id', id).eq('user_id', req.user.id).single();
    if (!order) return res.status(404).json({ success: false, message: 'Order not found' });
    if (order.status !== 'pending') return res.status(400).json({ success: false, message: `Cannot cancel order with status: ${order.status}` });

    const { data, error } = await supabase.from('orders').update({ status: 'cancelled' }).eq('id', id).select().single();
    if (error) throw error;
    res.json({ success: true, message: 'Order cancelled successfully', data });
  } catch (error) { next(error); }
}

async function getPrices(req, res, next) {
  try {
    const { data: prices, error: priceError } = await supabase.from('catalog_prices').select('*').order('item_name');
    if (priceError) throw priceError;

    const itemNames = (prices || []).map(price => price.item_name);
    let priceHistory = [];

    if (itemNames.length) {
      const { data: historyData, error: historyError } = await supabase
        .from('catalog_price_history')
        .select('item_name, price, created_at')
        .in('item_name', itemNames)
        .order('item_name', { ascending: true })
        .order('created_at', { ascending: false });

      if (historyError) throw historyError;
      priceHistory = historyData || [];
    }

    const groupedHistory = priceHistory.reduce((map, entry) => {
      if (!map[entry.item_name]) map[entry.item_name] = [];
      map[entry.item_name].push(entry);
      return map;
    }, {});

    const enrichedPrices = (prices || []).map(price => {
      const history = groupedHistory[price.item_name] || [];
      const previous = history[1];
      const change = previous ? parseFloat((parseFloat(price.current_price) - parseFloat(previous.price)).toFixed(2)) : 0;
      const change_percent = previous && previous.price ? parseFloat(((change / parseFloat(previous.price)) * 100).toFixed(2)) : 0;
      return {
        ...price,
        change,
        change_percent,
        trend: change > 0 ? 'up' : change < 0 ? 'down' : 'stable'
      };
    });

    res.json({ success: true, data: enrichedPrices });
  } catch (error) { next(error); }
}

async function getDashboard(req, res, next) {
  try {
    const userId = req.user.id;

    const { data: walletData, error: walletError } = await supabase.from('users').select('wallet_balance, eco_points').eq('id', userId).single();
    if (walletError) throw walletError;

    const { data: reductionRows, error: reductionError } = await supabase
      .from('orders')
      .select('carbon_reduction')
      .eq('user_id', userId)
      .eq('status', 'completed');
    if (reductionError) throw reductionError;

    const { count: completedCount, error: completedCountError } = await supabase
      .from('orders')
      .select('id', { count: 'exact', head: true })
      .eq('user_id', userId)
      .eq('status', 'completed');
    if (completedCountError) throw completedCountError;

    const totalCarbonReduction = (reductionRows || []).reduce((sum, row) => sum + parseFloat(row.carbon_reduction || 0), 0);
    const { data: lastOrders, error: lastOrdersError } = await supabase
      .from('orders')
      .select('id, status, item_type, total_amount, completed_at, carbon_reduction')
      .eq('user_id', userId)
      .eq('status', 'completed')
      .order('completed_at', { ascending: false })
      .limit(3);
    if (lastOrdersError) throw lastOrdersError;

    const { count: activeOrderCount, error: activeCountError } = await supabase
      .from('orders')
      .select('id', { count: 'exact', head: true })
      .eq('user_id', userId)
      .in('status', ['pending', 'accepted', 'en_route']);
    if (activeCountError) throw activeCountError;

    const { count: pendingOrderCount, error: pendingCountError } = await supabase
      .from('orders')
      .select('id', { count: 'exact', head: true })
      .eq('user_id', userId)
      .eq('status', 'pending');
    if (pendingCountError) throw pendingCountError;

    const treeCount = Math.floor(totalCarbonReduction / 5);
    const nextTreeAt = parseFloat(Math.max(0, (treeCount + 1) * 5 - totalCarbonReduction).toFixed(2));
    const ecoTreeLevel = treeCount < 2 ? 'Eco Seedling' : treeCount < 5 ? 'Eco Sprout' : 'Eco Tree';

    res.json({
      success: true,
      data: {
        wallet_balance: parseFloat(walletData.wallet_balance || 0),
        eco_points: walletData.eco_points || 0,
        total_carbon_reduction: parseFloat(totalCarbonReduction.toFixed(2)),
        completed_orders: completedCount || 0,
        active_orders: activeOrderCount || 0,
        pending_orders: pendingOrderCount || 0,
        last_completed_orders: lastOrders || [],
        eco_tree: {
          level: ecoTreeLevel,
          trees_planted: treeCount,
          next_tree_in_kg: nextTreeAt
        }
      }
    });
  } catch (error) { next(error); }
}

async function getEcoBook(req, res, next) {
  try {
    const { data, error } = await supabase.from('eco_books').select('*').order('created_at', { ascending: false });
    if (error) throw error;
    res.json({ success: true, data });
  } catch (error) { next(error); }
}

async function getOrderRoute(req, res, next) {
  try {
    const { id } = req.params;

    const orderQuery = supabase.from('orders').select('collector_id, pickup_location').eq('id', id);
    if (req.user.role === 'user') {
      orderQuery.eq('user_id', req.user.id);
    } else {
      orderQuery.eq('collector_id', req.user.id);
    }

    const { data: order, error: orderError } = await orderQuery.single();
    if (orderError || !order) return res.status(404).json({ success: false, message: 'Order not found' });
    if (!order.collector_id) return res.status(400).json({ success: false, message: 'No collector assigned yet' });

    const { data: collector, error: collectorError } = await supabase.from('users').select('location').eq('id', order.collector_id).single();
    if (collectorError || !collector?.location) return res.status(400).json({ success: false, message: 'Collector location unavailable' });

    const collectorPos = parseLocation(collector.location);
    const pickupPos = parseLocation(order.pickup_location);
    if (!collectorPos || !pickupPos) return res.status(400).json({ success: false, message: 'Invalid routing points' });

    const route = await getRoute(collectorPos.lng, collectorPos.lat, pickupPos.lng, pickupPos.lat);
    res.json({ success: true, data: route });
  } catch (error) { next(error); }
}

async function getWallet(req, res, next) {
  try {
    const { data, error } = await supabase.from('users').select('wallet_balance, eco_points').eq('id', req.user.id).single();
    if (error) throw error;
    res.json({ success: true, data });
  } catch (error) { next(error); }
}

async function getTransactions(req, res, next) {
  try {
    const { page, limit } = req.query;
    let query = supabase.from('transactions').select('*', { count: 'exact' })
      .or(`sender_id.eq.${req.user.id},receiver_id.eq.${req.user.id}`)
      .order('created_at', { ascending: false });
    const result = await paginate(query, page, limit);
    res.json({ success: true, ...result });
  } catch (error) { next(error); }
}

async function redeemCoins(req, res, next) {
  try {
    const { points = 1000 } = req.body;
    if (points < 1000 || points % 1000 !== 0) {
      return res.status(400).json({ success: false, message: 'Points must be in multiples of 1000' });
    }

    const { data: user } = await supabase.from('users').select('eco_points').eq('id', req.user.id).single();
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    if (user.eco_points < points) {
      return res.status(400).json({ success: false, message: `Insufficient eco points. Available: ${user.eco_points}, Required: ${points}` });
    }

    const bonus = (points / 1000) * 5000;
    const { data: usr } = await supabase.from('users').select('wallet_balance').eq('id', req.user.id).single();
    await supabase.from('users').update({
      eco_points: user.eco_points - points,
      wallet_balance: parseFloat(usr.wallet_balance) + bonus
    }).eq('id', req.user.id);

    await supabase.from('transactions').insert({
      order_id: null, sender_id: req.user.id, receiver_id: req.user.id,
      amount: bonus, type: 'redeem',
      description: `Redeemed ${points} eco points for Rp ${bonus}`
    });

    res.json({ success: true, data: { points_redeemed: points, bonus_received: bonus } });
  } catch (error) { next(error); }
}

async function getMissions(req, res, next) {
  try {
    const userId = req.user.id;
    const defaultMissions = {
      daily_checkin: {
        consecutive_days: 2,
        last_checkin: new Date().toISOString().split('T')[0],
        claimed_days: [1, 2]
      },
      ai_scan: { current: 1, target: 1, points: 300, claimed: false },
      weekly_weight: { current: 2.5, target: 5.0, points: 1800, claimed: false },
      master_category: { current: 1, target: 3, points: 2500, claimed: false },
      consistent_orders: { current: 0, target: 2, points: 1350, claimed: false }
    };
    res.json({ success: true, data: defaultMissions });
  } catch (error) { next(error); }
}

async function claimMission(req, res, next) {
  try {
    const userId = req.user.id;
    const { mission_type, day_index, user_level = 1 } = req.body;

    let pointsEarned = 0;
    let isGoldenChest = false;
    let luckPercentage = 25;

    if (mission_type === 'daily_checkin') {
      if (day_index === 4) {
        isGoldenChest = true;
        const luckMap = { 1: 25, 2: 45, 3: 65, 4: 80 };
        luckPercentage = luckMap[user_level] || 95;

        const baseRewardMap = { 1: 50, 2: 100, 3: 180, 4: 300 };
        const base = baseRewardMap[user_level] || 500;

        const isLucky = (Math.random() * 100) < luckPercentage;
        const bonus = isLucky ? Math.floor(base * 0.5) : 0;
        pointsEarned = base + bonus;
      } else {
        const rewardMap = { 1: 70, 2: 80, 3: 90, 5: 70, 6: 80 };
        pointsEarned = rewardMap[day_index] || 70;
      }
    } else if (mission_type === 'ai_scan') {
      pointsEarned = 300;
    } else if (mission_type === 'weekly_weight') {
      pointsEarned = 1800;
    } else if (mission_type === 'master_category') {
      pointsEarned = 2500;
    } else if (mission_type === 'consistent_orders') {
      pointsEarned = 1350;
    }

    const { data: user } = await supabase.from('users').select('eco_points').eq('id', userId).single();
    if (user) {
      await supabase.from('users').update({
        eco_points: (user.eco_points || 0) + pointsEarned
      }).eq('id', userId);
    }

    res.json({
      success: true,
      data: {
        points_earned: pointsEarned,
        is_golden_chest: isGoldenChest,
        luck_percentage: luckPercentage,
        user_level: user_level
      }
    });
  } catch (error) { next(error); }
}

module.exports = {
  analyzeImage,
  createOrder,
  getUserOrders,
  getOrderById,
  cancelOrder,
  getPrices,
  getDashboard,
  getEcoBook,
  getOrderRoute,
  getWallet,
  getTransactions,
  redeemCoins,
  getMissions,
  claimMission
};
