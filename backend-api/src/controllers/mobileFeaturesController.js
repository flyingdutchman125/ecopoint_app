const supabase = require('../config/supabase');

// --- PROFILE ---
async function updateProfile(req, res, next) {
  try {
    const userId = req.user.id;
    const { name, phone, avatar_url } = req.body;

    const { data, error } = await supabase
      .from('users')
      .update({ name, phone, avatar_url })
      .eq('id', userId)
      .select()
      .single();

    if (error) return res.status(400).json({ success: false, message: error.message });
    res.json({ success: true, data });
  } catch (error) { next(error); }
}

// --- ADDRESSES ---
async function getAddresses(req, res, next) {
  try {
    const { data, error } = await supabase
      .from('user_addresses')
      .select('*')
      .eq('user_id', req.user.id)
      .order('is_primary', { ascending: false });

    if (error) return res.status(400).json({ success: false, message: error.message });
    res.json({ success: true, data });
  } catch (error) { next(error); }
}

async function addAddress(req, res, next) {
  try {
    const { label, address, latitude, longitude, is_primary } = req.body;
    
    if (!latitude || !longitude) {
      return res.status(400).json({ success: false, message: 'Latitude and longitude are required' });
    }

    if (is_primary) {
      await supabase.from('user_addresses').update({ is_primary: false }).eq('user_id', req.user.id);
    }

    const { data, error } = await supabase
      .from('user_addresses')
      .insert({
        user_id: req.user.id,
        label, address, is_primary: is_primary || false,
        location: `POINT(${longitude} ${latitude})`
      })
      .select()
      .single();

    if (error) return res.status(400).json({ success: false, message: error.message });
    res.status(201).json({ success: true, data });
  } catch (error) { next(error); }
}

async function deleteAddress(req, res, next) {
  try {
    const { id } = req.params;
    const { error } = await supabase
      .from('user_addresses')
      .delete()
      .eq('id', id)
      .eq('user_id', req.user.id);

    if (error) return res.status(400).json({ success: false, message: error.message });
    res.json({ success: true, message: 'Address deleted successfully' });
  } catch (error) { next(error); }
}

// --- CHAT (ORDER MESSAGES) ---
async function sendMessage(req, res, next) {
  try {
    const { id: order_id } = req.params;
    const { message } = req.body;

    const { data, error } = await supabase
      .from('order_messages')
      .insert({ order_id, sender_id: req.user.id, message })
      .select()
      .single();

    if (error) return res.status(400).json({ success: false, message: error.message });
    res.status(201).json({ success: true, data });
  } catch (error) { next(error); }
}

async function getMessages(req, res, next) {
  try {
    const { id: order_id } = req.params;
    const { data, error } = await supabase
      .from('order_messages')
      .select('*')
      .eq('order_id', order_id)
      .order('created_at', { ascending: true });

    if (error) return res.status(400).json({ success: false, message: error.message });
    res.json({ success: true, data });
  } catch (error) { next(error); }
}

// --- RATINGS & REVIEWS ---
async function addReview(req, res, next) {
  try {
    const { id: order_id } = req.params;
    const { reviewee_id, rating, comment } = req.body;

    if (!reviewee_id) {
      return res.status(400).json({ success: false, message: 'reviewee_id is required' });
    }

    const { data, error } = await supabase
      .from('order_reviews')
      .insert({ order_id, reviewer_id: req.user.id, reviewee_id, rating, comment })
      .select()
      .single();

    if (error) return res.status(400).json({ success: false, message: error.message });
    res.status(201).json({ success: true, data });
  } catch (error) { next(error); }
}

// --- PAYMENTS (TOPUP & WITHDRAWAL) ---
async function requestWithdrawal(req, res, next) {
  try {
    const { amount, bank_name, account_number } = req.body;
    
    // Check balance first
    const { data: user } = await supabase.from('users').select('wallet_balance').eq('id', req.user.id).single();
    if (user.wallet_balance < amount) {
      return res.status(400).json({ success: false, message: 'Insufficient balance' });
    }

    // Deduct balance directly (In real app, this should be transactional or done upon admin approval)
    await supabase.from('users').update({ wallet_balance: user.wallet_balance - amount }).eq('id', req.user.id);

    const { data, error } = await supabase
      .from('withdrawals')
      .insert({ user_id: req.user.id, amount, bank_name, account_number, status: 'pending' })
      .select()
      .single();

    if (error) return res.status(400).json({ success: false, message: error.message });
    res.status(201).json({ success: true, data, message: 'Withdrawal requested' });
  } catch (error) { next(error); }
}

async function requestTopup(req, res, next) {
  try {
    const { amount, payment_method } = req.body;
    
    // Mocking an instant top up for simplicity
    const { data: user } = await supabase.from('users').select('wallet_balance').eq('id', req.user.id).single();
    await supabase.from('users').update({ wallet_balance: Number(user.wallet_balance) + Number(amount) }).eq('id', req.user.id);

    const { data, error } = await supabase
      .from('topups')
      .insert({ user_id: req.user.id, amount, payment_method, status: 'completed' })
      .select()
      .single();

    if (error) return res.status(400).json({ success: false, message: error.message });
    res.status(201).json({ success: true, data, message: 'Top up successful' });
  } catch (error) { next(error); }
}

module.exports = {
  updateProfile,
  getAddresses, addAddress, deleteAddress,
  sendMessage, getMessages,
  addReview,
  requestWithdrawal, requestTopup
};
