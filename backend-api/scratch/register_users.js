const supabase = require('../src/config/supabase');

async function registerUser(email, password, name, role) {
  console.log(`Registering ${email}...`);
  // Try admin create user
  const adminRes = await supabase.auth.admin.createUser({
    email,
    password,
    email_confirm: true,
    user_metadata: { role, phone: '08123456789', city: 'Jakarta' },
  });

  let authUser;
  if (adminRes.error) {
    if (adminRes.error.message.includes('already registered')) {
      console.log(`${email} already registered in Auth.`);
      // Try to find the user in auth.users or db
      const { data: existingUser } = await supabase.from('users').select('id').eq('email', email).single();
      if (existingUser) {
        console.log(`User exists in db: ${existingUser.id}`);
        return;
      }
    } else {
      console.error(`Admin create error:`, adminRes.error);
      return;
    }
  } else {
    authUser = adminRes.data.user;
  }

  if (authUser) {
    const { error: dbError } = await supabase.from('users').insert({
      id: authUser.id,
      email,
      name,
      role,
      phone: '08123456789',
      city: 'Jakarta',
      address: 'Jl. Test No. 123',
      subdistrict: 'Kebon Jeruk',
      wallet_balance: role === 'user' ? 50000 : 85000,
      eco_points: role === 'user' ? 1200 : 0
    });
    if (dbError) {
      console.error('DB Insert error:', dbError);
    } else {
      console.log(`Successfully registered ${email}`);
    }
  }
}

async function main() {
  await registerUser('test@ecopoint.id', 'test123456', 'Warga Test', 'user');
  await registerUser('collector@ecopoint.id', 'test123456', 'Collector Test', 'collector');
}

main();
