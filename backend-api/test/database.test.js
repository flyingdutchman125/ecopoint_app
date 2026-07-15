const supabase = require('../config/supabase');

async function testDatabaseConnection() {
  try {
    console.log('Testing Supabase connection...');
    const { data, error } = await supabase
      .from('users')
      .select('count')
      .limit(1);
    
    if (error) throw error;
    console.log('✓ Database connection successful');
    return true;
  } catch (error) {
    console.error('✗ Database connection failed:', error.message);
    return false;
  }
}

async function testPostGIS() {
  try {
    console.log('Testing PostGIS extension...');
    const { data, error } = await supabase.rpc('calculate_distance', {
      lng1: 106.8456,
      lat1: -6.2088,
      lng2: 106.8500,
      lat2: -6.2100
    });
    
    if (error) throw error;
    console.log(`✓ PostGIS working. Sample distance: ${data.toFixed(2)}m`);
    return true;
  } catch (error) {
    console.error('✗ PostGIS test failed:', error.message);
    return false;
  }
}

async function testCatalogPrices() {
  try {
    console.log('Testing catalog prices...');
    const { data, error } = await supabase
      .from('catalog_prices')
      .select('*')
      .limit(5);
    
    if (error) throw error;
    console.log(`✓ Found ${data.length} catalog prices`);
    return true;
  } catch (error) {
    console.error('✗ Catalog prices test failed:', error.message);
    return false;
  }
}

async function runAllTests() {
  console.log('==========================================');
  console.log('EcoPoint API - Database Tests');
  console.log('==========================================\n');

  const results = {
    connection: await testDatabaseConnection(),
    postgis: await testPostGIS(),
    catalog: await testCatalogPrices()
  };

  console.log('\n==========================================');
  console.log('Test Results:');
  console.log('==========================================');
  console.log(`Database Connection: ${results.connection ? '✓ PASS' : '✗ FAIL'}`);
  console.log(`PostGIS Functions: ${results.postgis ? '✓ PASS' : '✗ FAIL'}`);
  console.log(`Catalog Prices: ${results.catalog ? '✓ PASS' : '✗ FAIL'}`);

  const allPassed = Object.values(results).every(r => r === true);
  console.log(`\nOverall: ${allPassed ? '✅ ALL TESTS PASSED' : '❌ SOME TESTS FAILED'}`);
  
  process.exit(allPassed ? 0 : 1);
}

if (require.main === module) {
  require('dotenv').config();
  runAllTests();
}

module.exports = { testDatabaseConnection, testPostGIS, testCatalogPrices };
