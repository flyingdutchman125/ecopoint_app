const supabase = require('../src/config/supabase');

async function main() {
  const { data: orders, error } = await supabase.from('orders').select('*').limit(5);
  if (error) {
    console.error('Error:', error);
  } else {
    console.log('Orders in DB:', orders.map(o => ({ id: o.id, item_type: o.item_type, status: o.status })));
  }
}

main();
