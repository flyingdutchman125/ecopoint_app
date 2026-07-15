const supabase = require('../config/supabase');
const { scrapeBSIPrices } = require('../services/scraperService');
const { paginate } = require('../utils/paginate');

async function scrapePrices(req, res, next) {
  try {
    const result = await scrapeBSIPrices();
    res.json({ success: true, data: result });
  } catch (error) { next(error); }
}

async function updatePrice(req, res, next) {
  try {
    const { item_name, current_price } = req.body;
    if (!item_name || !current_price) return res.status(400).json({ success: false, message: 'item_name and current_price are required' });
    const { data, error } = await supabase.from('catalog_prices').upsert({
      item_name, current_price: parseFloat(current_price), last_updated: new Date().toISOString()
    }, { onConflict: 'item_name' }).select().single();
    if (error) throw error;
    res.json({ success: true, message: 'Price updated', data });
  } catch (error) { next(error); }
}

async function getAllOrders(req, res, next) {
  try {
    const { page, limit, status } = req.query;
    let query = supabase.from('orders').select('*', { count: 'exact' }).order('created_at', { ascending: false });
    if (status) query = query.eq('status', status);
    const result = await paginate(query, page, limit);
    res.json({ success: true, ...result });
  } catch (error) { next(error); }
}

async function getStatistics(req, res, next) {
  try {
    const [totalO, completedO, activeO, totalU, totalC, onlineC] = await Promise.all([
      supabase.from('orders').select('id', { count: 'exact', head: true }),
      supabase.from('orders').select('id', { count: 'exact', head: true }).eq('status', 'completed'),
      supabase.from('orders').select('id', { count: 'exact', head: true }).in('status', ['pending', 'accepted', 'en_route']),
      supabase.from('users').select('id', { count: 'exact', head: true }).eq('role', 'user'),
      supabase.from('users').select('id', { count: 'exact', head: true }).eq('role', 'collector'),
      supabase.from('users').select('id', { count: 'exact', head: true }).eq('role', 'collector').eq('is_online', true)
    ]);

    const { data: revData } = await supabase.from('orders').select('total_amount').eq('status', 'completed');
    const totalRevenue = revData?.reduce((s, r) => s + (parseFloat(r.total_amount) || 0), 0) || 0;

    res.json({
      success: true,
      data: {
        orders: { total: totalO.count || 0, completed: completedO.count || 0, active: activeO.count || 0 },
        users: { total: totalU.count || 0, collectors: totalC.count || 0, online_collectors: onlineC.count || 0 },
        revenue: { total: parseFloat(totalRevenue.toFixed(2)) }
      }
    });
  } catch (error) { next(error); }
}

async function getAllUsers(req, res, next) {
  try {
    const { page, limit, role } = req.query;
    let query = supabase.from('users').select('id, role, name, email, wallet_balance, eco_points, is_online, created_at', { count: 'exact' }).order('created_at', { ascending: false });
    if (role) query = query.eq('role', role);
    const result = await paginate(query, page, limit);
    res.json({ success: true, ...result });
  } catch (error) { next(error); }
}

async function updateUserBalance(req, res, next) {
  try {
    const { user_id, amount, operation } = req.body;
    if (!user_id || !amount || !operation) {
      return res.status(400).json({ success: false, message: 'user_id, amount, and operation (add/subtract) are required' });
    }
    if (!['add', 'subtract'].includes(operation)) return res.status(400).json({ success: false, message: 'operation must be add or subtract' });

    const { data: user } = await supabase.from('users').select('wallet_balance').eq('id', user_id).single();
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });

    const newBalance = operation === 'add' ? parseFloat(user.wallet_balance) + parseFloat(amount) : parseFloat(user.wallet_balance) - parseFloat(amount);
    if (newBalance < 0) return res.status(400).json({ success: false, message: 'Negative balance not allowed' });

    const { data, error } = await supabase.from('users').update({ wallet_balance: newBalance }).eq('id', user_id).select().single();
    if (error) throw error;
    res.json({ success: true, message: 'Balance updated', data });
  } catch (error) { next(error); }
}

module.exports = { scrapePrices, updatePrice, getAllOrders, getStatistics, getAllUsers, updateUserBalance };
