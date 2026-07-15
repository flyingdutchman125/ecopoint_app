const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../config/db');

const JWT_SECRET = process.env.JWT_SECRET || 'supersecretkey';

exports.registerUser = async (req, res) => {
  try {
    const { name, email, password, phone } = req.body;
    
    const [existingUsers] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);
    if (existingUsers.length > 0) {
      return res.status(400).json({ message: 'Email already registered' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const [result] = await db.execute(
      'INSERT INTO users (name, email, password, role, phone, status) VALUES (?, ?, ?, ?, ?, ?)',
      [name, email, hashedPassword, 'user', phone, 'active']
    );

    res.status(201).json({ message: 'User registered successfully', userId: result.insertId });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.registerCollector = async (req, res) => {
  try {
    const { name, email, password, phone, vehicle_type, plate_number } = req.body;
    const ktp_photo_url = req.file ? `/uploads/${req.file.filename}` : null;

    const [existingUsers] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);
    if (existingUsers.length > 0) {
      return res.status(400).json({ message: 'Email already registered' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const [result] = await db.execute(
      'INSERT INTO users (name, email, password, role, phone, vehicle_type, plate_number, ktp_photo_url, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [name, email, hashedPassword, 'collector', phone, vehicle_type, plate_number, ktp_photo_url, 'pending_verification']
    );

    res.status(201).json({ message: 'Collector registered successfully. Waiting for admin verification.', userId: result.insertId });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    const [users] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);
    if (users.length === 0) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const user = users[0];
    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    if (user.role === 'collector' && user.status === 'pending_verification') {
       return res.status(403).json({ message: 'Account is pending verification by Admin' });
    }

    const token = jwt.sign({ id: user.id, role: user.role }, JWT_SECRET, { expiresIn: '7d' });

    res.status(200).json({
      message: 'Login successful',
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        status: user.status
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};
