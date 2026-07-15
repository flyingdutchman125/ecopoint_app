const fetch = (...args) => import('node-fetch').then(({default: f}) => f(...args));

const BASE = 'http://localhost:3000';
const ANON = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9ybmZsdm1lZmllZ2duZXp4ZXphIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE5NDU3MDIsImV4cCI6MjA5NzUyMTcwMn0.IEeVL4p0LFOmvtSnt7L6IhMBkfE9QGN8krivA2s5oKk';
const URL = 'https://ornflvmefieggnezxeza.supabase.co';

async function login(email) {
  const res = await fetch(URL + '/auth/v1/token?grant_type=password', {
    method: 'POST',
    headers: { 'apikey': ANON, 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password: 'Test1234!' })
  });
  return (await res.json()).access_token;
}

async function test(name, method, path, token, body) {
  const opts = { method, headers: { 'Content-Type': 'application/json' } };
  if (token) opts.headers['Authorization'] = 'Bearer ' + token;
  if (body) opts.body = JSON.stringify(body);
  const res = await fetch(BASE + path, opts);
  const data = await res.json();
  const ok = res.status >= 200 && res.status < 300;
  console.log(`${ok ? '✅' : '❌'} ${name} [${res.status}]`);
  if (!ok) console.log('   Error:', JSON.stringify(data).substring(0, 200));
  return { ok, data, status: res.status };
}

async function run() {
  console.log('\n═══════════════════════════════════════════════');
  console.log('  ECOPOINT API - FULL ENDPOINT TEST');
  console.log('═══════════════════════════════════════════════\n');

  const userToken = await login('user@test.com') || (await (await fetch(BASE + '/api/login', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ email: 'user@test.com', password: 'Test1234!' }) })).json()).data?.token;
  const collectorToken = await login('collector@test.com') || (await (await fetch(BASE + '/api/login', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ email: 'collector@test.com', password: 'Test1234!' }) })).json()).data?.token;
  const adminToken = await login('admin@test.com') || (await (await fetch(BASE + '/api/login', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ email: 'admin@test.com', password: 'Test1234!' }) })).json()).data?.token;

  console.log('Tokens obtained\n');
  console.log('── USER ENDPOINTS ──');

  await test('GET /health', 'GET', '/health');
  await test('POST /analyze-image', 'POST', '/api/analyze-image', null, {
    photo_url: 'https://sys.mxflower.eu.org/stream/1577?hash=1e2853'
  });
  await test('GET /api/prices', 'GET', '/api/prices', userToken);
  await test('GET /api/wallet', 'GET', '/api/wallet', userToken);
  await test('GET /api/orders', 'GET', '/api/orders', userToken);
  await test('GET /api/transactions', 'GET', '/api/transactions', userToken);

  const orderRes = await test('POST /api/order', 'POST', '/api/order', userToken, {
    item_type: 'Cooking Oil', est_weight: 2, pickup_lng: 106.8456, pickup_lat: -6.2088,
    pickup_address: 'Jl. Asia Afrika, Jakarta'
  });

  const orderId = orderRes.data?.data?.id;
  if (orderId) {
    await test('GET /api/order/:id', 'GET', '/api/order/' + orderId, userToken);
  }

  console.log('\n── COLLECTOR ENDPOINTS ──');
  await test('PUT /api/location', 'PUT', '/api/location', collectorToken, {
    lng: 106.8456, lat: -6.2088, is_online: true
  });
  await test('GET /api/nearby-orders', 'GET', '/api/nearby-orders?radius=5000', collectorToken);

  if (orderId) {
    await test('POST /api/order/:id/accept', 'POST', '/api/order/' + orderId + '/accept', collectorToken);
    await test('PUT /api/order/:id/en-route', 'PUT', '/api/order/' + orderId + '/en-route', collectorToken);
    await test('GET /api/order/:id/route', 'GET', '/api/order/' + orderId + '/route', collectorToken);
    await test('POST /api/order/:id/pay', 'POST', '/api/order/' + orderId + '/pay', collectorToken, { actual_weight: 1.8 });
  }
  await test('GET /api/collector/orders', 'GET', '/api/collector/orders', collectorToken);

  console.log('\n── ADMIN ENDPOINTS ──');
  await test('GET /api/statistics', 'GET', '/api/statistics', adminToken);
  await test('GET /api/admin/users', 'GET', '/api/admin/users', adminToken);
  await test('GET /api/admin/orders', 'GET', '/api/admin/orders', adminToken);

  console.log('\n═══════════════════════════════════════════════');
  console.log('  TEST COMPLETE');
  console.log('═══════════════════════════════════════════════\n');
  process.exit(0);
}

run().catch(e => { console.error('FATAL:', e.message); process.exit(1); });
