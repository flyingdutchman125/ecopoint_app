const supabase = require('../src/config/supabase');

async function main() {
  const { data: users, error } = await supabase.from('users').select('*').limit(5);
  if (error) {
    console.error('Error fetching users:', error);
  } else {
    console.log('Users:', users);
  }
}

main();
