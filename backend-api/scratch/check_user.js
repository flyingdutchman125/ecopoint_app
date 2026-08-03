const supabase = require('../src/config/supabase');

async function main() {
  const { data: user, error } = await supabase.from('users').select('*').eq('email', 'test@ecopoint.id').single();
  if (error) {
    console.error('Error:', error);
  } else {
    console.log('User test@ecopoint.id:', user);
  }
}

main();
