-- Setup Database
CREATE DATABASE IF NOT EXISTS ecopoint;
USE ecopoint;

-- Set root password and grant privileges for local connections
ALTER USER 'root'@'localhost' IDENTIFIED BY 'jacki123';
CREATE USER IF NOT EXISTS 'root'@'127.0.0.1' IDENTIFIED BY 'jacki123';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'127.0.0.1' WITH GRANT OPTION;
FLUSH PRIVILEGES;

-- Create Users table
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  role ENUM('user', 'collector', 'admin') DEFAULT 'user',
  phone VARCHAR(50),
  ktp_photo_url VARCHAR(255),
  vehicle_type VARCHAR(50),
  plate_number VARCHAR(50),
  status ENUM('active', 'pending_verification', 'rejected') DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
