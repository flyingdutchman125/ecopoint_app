const crypto = require('crypto');
const supabase = require('../config/supabase');
const { analyzeWasteImage } = require('../services/aiVisionService');
const { paginate } = require('../utils/paginate');

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
    const { data, error } = await supabase.from('catalog_prices').select('*').order('item_name');
    if (error) throw error;
    res.json({ success: true, data });
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

module.exports = { analyzeImage, createOrder, getUserOrders, getOrderById, cancelOrder, getPrices, getWallet, getTransactions, redeemCoins };
