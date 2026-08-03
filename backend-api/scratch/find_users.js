const supabase = require('../src/config/supabase');

async function main() {
  const { data: users, error } = await supabase.from('users').select('*').eq('role', 'user');
  if (error) {
    console.error('Error:', error);
  } else {
    console.log('Warga Users:', users.map(u => ({ email: u.email, id: u.id, name: u.name })));
  }
}

main();
