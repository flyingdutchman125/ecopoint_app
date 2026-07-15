const supabase = require('../config/supabase');

async function transferBalance(senderId, receiverId, amount, orderId) {
  try {
    if (!senderId || !receiverId) {
      throw new Error('Sender and receiver IDs are required');
    }

    if (!amount || amount <= 0) {
      throw new Error('Amount must be greater than zero');
    }

    const { data, error } = await supabase.rpc('transfer_dummy_balance', {
      sender_id: senderId,
      receiver_id: receiverId,
      amount: amount,
      order_id: orderId
    });

    if (error) {
      throw new Error(error.message || 'Transfer failed');
    }

    return data;

  } catch (error) {
    console.error('Wallet Service Error:', error);
    throw error;
  }
}

async function getBalance(userId) {
  try {
    const { data, error } = await supabase
      .from('users')
      .select('wallet_balance, eco_points')
      .eq('id', userId)
      .single();

    if (error) throw error;

    return {
      wallet_balance: data.wallet_balance,
      eco_points: data.eco_points
    };

  } catch (error) {
    console.error('Get Balance Error:', error);
    throw new Error(`Failed to get balance: ${error.message}`);
  }
}

async function addEcoPoints(userId, points) {
  try {
    const { data: current, error: readErr } = await supabase
      .from('users')
      .select('eco_points')
      .eq('id', userId)
      .single();

    if (readErr) throw readErr;

    const newPoints = (current.eco_points || 0) + points;

    const { data, error } = await supabase
      .from('users')
      .update({ eco_points: newPoints })
      .eq('id', userId)
      .select('eco_points')
      .single();

    if (error) throw error;

    return data;

  } catch (error) {
    console.error('Add Eco Points Error:', error);
    throw new Error(`Failed to add eco points: ${error.message}`);
  }
}

async function getTransactionHistory(userId, limit = 50) {
  try {
    const { data, error } = await supabase
      .from('transactions')
      .select('*')
      .or(`sender_id.eq.${userId},receiver_id.eq.${userId}`)
      .order('created_at', { ascending: false })
      .limit(limit);

    if (error) throw error;

    return data;

  } catch (error) {
    console.error('Get Transaction History Error:', error);
    throw new Error(`Failed to get transaction history: ${error.message}`);
  }
}

module.exports = {
  transferBalance,
  getBalance,
  addEcoPoints,
  getTransactionHistory
};
