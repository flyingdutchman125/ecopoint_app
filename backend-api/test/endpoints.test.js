const fetch = require('node-fetch');

const BASE_URL = process.env.API_URL || 'http://localhost:3000';

async function testHealthCheck() {
  try {
    console.log('Testing health check endpoint...');
    const response = await fetch(`${BASE_URL}/health`);
    const data = await response.json();
    
    if (response.ok && data.status === 'ok') {
      console.log('✓ Health check passed');
      return true;
    } else {
      console.error('✗ Health check failed');
      return false;
    }
  } catch (error) {
    console.error('✗ Health check error:', error.message);
    return false;
  }
}

async function testAnalyzeImage() {
  try {
    console.log('Testing AI vision endpoint...');
    const response = await fetch(`${BASE_URL}/api/user/order/analyze-image`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        photo_url: 'https://images.unsplash.com/photo-1591790139948-df0c0fca5c1d'
      })
    });
    
    if (response.ok) {
      const data = await response.json();
      console.log('✓ AI vision endpoint responded');
      return true;
    } else {
      console.log('⚠ AI vision endpoint failed (may need valid API key)');
      return false;
    }
  } catch (error) {
    console.error('✗ AI vision error:', error.message);
    return false;
  }
}

async function runEndpointTests() {
  console.log('==========================================');
  console.log('EcoPoint API - Endpoint Tests');
  console.log('==========================================\n');

  const results = {
    health: await testHealthCheck(),
    vision: await testAnalyzeImage()
  };

  console.log('\n==========================================');
  console.log('Test Results:');
  console.log('==========================================');
  console.log(`Health Check: ${results.health ? '✓ PASS' : '✗ FAIL'}`);
  console.log(`AI Vision: ${results.vision ? '✓ PASS (or ⚠ needs config)' : '✗ FAIL'}`);

  const criticalPassed = results.health;
  console.log(`\nCritical Tests: ${criticalPassed ? '✅ PASSED' : '❌ FAILED'}`);
  
  process.exit(criticalPassed ? 0 : 1);
}

if (require.main === module) {
  runEndpointTests();
}

module.exports = { testHealthCheck, testAnalyzeImage };
