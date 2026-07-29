const mysql = require('mysql2/promise');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const fs = require('fs');
require('dotenv').config();

const MYSQL_CONFIG = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  // Menggunakan operator ?? agar string kosong "" tidak tertimpa oleh fallback password 'jacki123'
  password: process.env.DB_PASSWORD ?? process.env.DB_PASS ?? '',
  database: process.env.DB_NAME || 'ecopoint',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
};

const SQLITE_DIR = path.join(__dirname, '..', 'data');
const SQLITE_PATH = path.join(SQLITE_DIR, 'ecopoint.db');

const createSqliteSchema = (db) => {
  db.exec(`
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT UNIQUE NOT NULL,
      password TEXT NOT NULL,
      role TEXT DEFAULT 'user',
      phone TEXT,
      ktp_photo_url TEXT,
      vehicle_type TEXT,
      plate_number TEXT,
      status TEXT DEFAULT 'active',
      created_at TEXT DEFAULT CURRENT_TIMESTAMP
    );
  `);
};

const createSqliteClient = () => {
  if (!fs.existsSync(SQLITE_DIR)) {
    fs.mkdirSync(SQLITE_DIR, { recursive: true });
  }

  const db = new sqlite3.Database(SQLITE_PATH);
  createSqliteSchema(db);

  return {
    execute: (sql, params = []) => new Promise((resolve, reject) => {
      const normalizedSql = sql.trim().toLowerCase();
      if (normalizedSql.startsWith('select')) {
        db.all(sql, params, (err, rows) => {
          if (err) return reject(err);
          resolve([rows]);
        });
      } else {
        db.run(sql, params, function (err) {
          if (err) return reject(err);
          resolve([{ insertId: this.lastID, affectedRows: this.changes }]);
        });
      }
    }),
  };
};

const createMysqlClient = async () => {
  return mysql.createPool(MYSQL_CONFIG);
};

const getDatabaseClient = async () => {
  try {
    const pool = await createMysqlClient();
    // Menguji koneksi dengan query sederhana
    await pool.query('SELECT 1');
    console.log(`Connected to MySQL database [Database: ${MYSQL_CONFIG.database}]`);
    return pool;
  } catch (error) {
    console.warn('MySQL connection failed, falling back to SQLite:', error?.message || error);
    return createSqliteClient();
  }
};

let dbPromise = getDatabaseClient();

module.exports = {
  execute: async (...args) => {
    const db = await dbPromise;
    return db.execute(...args);
  }
};