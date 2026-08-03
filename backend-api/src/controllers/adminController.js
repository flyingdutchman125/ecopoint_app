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
    const parsedPrice = parseFloat(current_price);
    const { data, error } = await supabase.from('catalog_prices').upsert({
      item_name,
      current_price: parsedPrice,
      last_updated: new Date().toISOString()
    }, { onConflict: 'item_name' }).select().single();
    if (error) throw error;

    const { error: historyError } = await supabase.from('catalog_price_history').insert({
      item_name,
      price: parsedPrice,
      created_at: new Date().toISOString()
    });
    if (historyError) console.warn('Failed to insert price history:', historyError.message || historyError);

    res.json({ success: true, message: 'Price updated', data });
  } catch (error) { next(error); }
}

async function getAllOrders(req, res, next) {
  try {
    const { page, limit, status } = req.query;
    let query = supabase.from('orders').select('*, user:user_id(name, phone), collector:collector_id(name, phone)', { count: 'exact' }).order('created_at', { ascending: false });
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
    let selectCols = 'id, role, name, email, phone, city, address, subdistrict, avatar_url, wallet_balance, eco_points, is_online, created_at';
    let query = supabase.from('users').select(selectCols, { count: 'exact' }).order('created_at', { ascending: false });
    if (role) query = query.eq('role', role);
    let result = await paginate(query, page, limit);
    res.json({ success: true, ...result });
  } catch (error) {
    try {
      const { page, limit, role } = req.query;
      let selectCols = 'id, role, name, email, phone, wallet_balance, eco_points, is_online, created_at';
      let query = supabase.from('users').select(selectCols, { count: 'exact' }).order('created_at', { ascending: false });
      if (role) query = query.eq('role', role);
      let result = await paginate(query, page, limit);
      res.json({ success: true, ...result });
    } catch (err) {
      next(err);
    }
  }
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

async function adminResetPassword(req, res, next) {
  try {
    const { user_id, new_password } = req.body;
    if (!user_id || !new_password) {
      return res.status(400).json({ success: false, message: 'user_id and new_password are required' });
    }
    const { error } = await supabase.auth.admin.updateUserById(user_id, { password: new_password });
    if (error) throw error;
    res.json({ success: true, message: 'Password reset successfully' });
  } catch (error) { next(error); }
}

async function adminDeleteUser(req, res, next) {
  try {
    const userId = req.params.userId || req.body.user_id;
    if (!userId) {
      return res.status(400).json({ success: false, message: 'userId is required' });
    }
    if (userId === req.user.id) {
      return res.status(400).json({ success: false, message: 'Admin cannot delete their own account' });
    }

    await Promise.allSettled([
      supabase.from('user_addresses').delete().eq('user_id', userId),
      supabase.from('transactions').delete().eq('user_id', userId),
      supabase.from('topups').delete().eq('user_id', userId),
      supabase.from('withdrawals').delete().eq('user_id', userId),
      supabase.from('order_messages').delete().eq('sender_id', userId),
    ]);

    const { error: authError } = await supabase.auth.admin.deleteUser(userId);
    if (authError && authError.status !== 404) throw authError;

    const { error: dbError } = await supabase.from('users').delete().eq('id', userId);
    if (dbError) throw dbError;

    res.json({ success: true, message: 'User deleted successfully' });
  } catch (error) { next(error); }
}

module.exports = { scrapePrices, updatePrice, getAllOrders, getStatistics, getAllUsers, updateUserBalance, adminResetPassword, adminDeleteUser };
