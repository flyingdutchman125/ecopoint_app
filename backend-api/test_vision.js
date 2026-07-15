const { createClient } = require('@supabase/supabase-js');
const fetch = (...args) => import('node-fetch').then(({default: f}) => f(...args));

const BASE = 'http://localhost:3000';
const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9ybmZsdm1lZmllZ2duZXp4ZXphIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE5NDU3MDIsImV4cCI6MjA5NzUyMTcwMn0.IEeVL4p0LFOmvtSnt7L6IhMBkfE9QGN8krivA2s5oKk';

async function testVision() {
  console.log('🔐 Getting token...');
  const loginRes = await fetch('https://ornflvmefieggnezxeza.supabase.co/auth/v1/token?grant_type=password', {
    method: 'POST',
    headers: { 'apikey': anonKey, 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: 'user@test.com', password: 'testpassword123' })
  });
  const loginData = await loginRes.json();
  const token = loginData.access_token;
  console.log('✅ Token obtained\n');

  console.log('🧪 Testing AI Vision with kardus image...\n');
  const res = await fetch(BASE + '/api/user/order/analyze-image', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ' + token
    },
    body: JSON.stringify({ photo_url: 'https://sys.mxflower.eu.org/stream/1577?hash=1e2853' })
  });
  
  const data = await res.json();
  console.log('Status:', res.status);
  console.log('Response:', JSON.stringify(data, null, 2));
  process.exit(0);
}

testVision().catch(e => { console.error('Error:', e.message); process.exit(1); });
