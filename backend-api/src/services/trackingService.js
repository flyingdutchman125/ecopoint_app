const supabase = require('../config/supabase');

async function appendStatusHistory(orderId, status, userId) {
  try {
    const entry = { status, timestamp: new Date().toISOString(), by: userId };
    const { data: order } = await supabase.from('orders').select('status_history').eq('id', orderId).single();
    const history = order?.status_history || [];
    history.push(entry);
    await supabase.from('orders').update({ status_history: history }).eq('id', orderId);
  } catch (e) {
    // column may not exist yet — silent fail
  }
}

module.exports = { appendStatusHistory };
