const mysql = require('mysql2/promise');
require('dotenv').config();

// SQL Query to create users table:
/*
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  role ENUM('user', 'collector', 'admin') DEFAULT 'user',
  phone VARCHAR(50),
  ktp_photo_url VARCHAR(255),
  vehicle_type VARCHAR(50),
  plate_number VARCHAR(50),
  status ENUM('active', 'pending_verification') DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
*/

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'jacki123',
  database: process.env.DB_NAME || 'ecopoint',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

module.exports = pool;
