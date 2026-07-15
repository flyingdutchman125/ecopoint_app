const bcrypt = require('bcryptjs');
const db = require('./config/db');

async function seedAdmin() {
  try {
    const email = 'admin@ecopoint.com';
    const password = 'admin123';
    
    const [existing] = await db.execute('SELECT id FROM users WHERE email = ?', [email]);
    if (existing.length > 0) {
      console.log('Admin already exists.');
      process.exit(0);
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    
    await db.execute(
      'INSERT INTO users (name, email, password, role, status) VALUES (?, ?, ?, ?, ?)',
      ['Administrator', email, hashedPassword, 'admin', 'active']
    );
    console.log('Admin account created successfully: admin@ecopoint.com / admin123');
  } catch (error) {
    console.error('Error seeding admin:', error);
  } finally {
    process.exit(0);
  }
}

seedAdmin();
