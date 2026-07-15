#!/bin/bash

# Exit on error
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"

echo "Installing NPM packages in backend..."
npm install

echo "Creating uploads directory..."
mkdir -p uploads

# Start MariaDB server
echo "Starting database server..."
./run_db.sh

# Run init_db.sql using mysql client via the local socket
echo "Initializing database schema..."
MYSQL_SOCKET="$DIR/mysql_data/mysql.sock"
if mysql --socket="$MYSQL_SOCKET" -u root -pjacki123 -e "SELECT 1" >/dev/null 2>&1; then
  mysql --socket="$MYSQL_SOCKET" -u root -pjacki123 < init_db.sql
else
  mysql --socket="$MYSQL_SOCKET" -u root < init_db.sql
fi

# Create .env if not exists
if [ ! -f .env ]; then
  echo "Creating .env file..."
  cat <<EOT > .env
DB_HOST=127.0.0.1
DB_USER=root
DB_PASSWORD=jacki123
DB_PASS=jacki123
DB_NAME=ecopoint
JWT_SECRET=supersecretkey
PORT=3000
EOT
fi

# Run seedAdmin.js to create the default admin account
echo "Seeding admin account..."
node seedAdmin.js

echo "Starting Node.js Express server..."
npm start
