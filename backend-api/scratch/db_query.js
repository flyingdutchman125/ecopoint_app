const supabase = require('../src/config/supabase');

async function main() {
  const { data: prices, error } = await supabase.from('catalog_prices').select('*');
  if (error) {
    console.error('Error fetching catalog_prices:', error);
  } else {
    console.log('Catalog Prices in DB:', prices);
  }
}

main();
