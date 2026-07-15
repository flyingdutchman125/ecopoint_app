#!/bin/bash

# Exit on error
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MYSQL_HOME="$DIR/mysql_data"
MYSQL_DATADIR="$MYSQL_HOME/data"
MYSQL_SOCKET="$MYSQL_HOME/mysql.sock"
MYSQL_PID_FILE="$MYSQL_HOME/mysql.pid"
MYSQL_PORT=3306

echo "Using MYSQL_HOME=$MYSQL_HOME"

if [ ! -d "$MYSQL_HOME" ]; then
  echo "Initializing database..."
  mkdir -p "$MYSQL_DATADIR"
  
  mysql_install_db --no-defaults \
    --auth-root-authentication-method=normal \
    --datadir="$MYSQL_DATADIR" \
    --pid-file="$MYSQL_PID_FILE"
fi

echo "Starting MariaDB on port $MYSQL_PORT..."
# Start mysqld in the background. We bind to 127.0.0.1.
mysqld --no-defaults \
  --bind-address=127.0.0.1 \
  --port=$MYSQL_PORT \
  --datadir="$MYSQL_DATADIR" \
  --pid-file="$MYSQL_PID_FILE" \
  --socket="$MYSQL_SOCKET" > "$MYSQL_HOME/mysql.log" 2>&1 &

# Save daemon PID
echo $! > "$MYSQL_HOME/mysql_daemon.pid"

# Wait for mysql to start responding
echo "Waiting for MariaDB to start..."
for i in {1..30}; do
  if mysqladmin --socket="$MYSQL_SOCKET" -u root ping >/dev/null 2>&1; then
    echo "MariaDB is ready."
    break
  fi
  sleep 1
done

if ! mysqladmin --socket="$MYSQL_SOCKET" -u root ping >/dev/null 2>&1; then
  echo "Failed to start MariaDB. Log:"
  cat "$MYSQL_HOME/mysql.log"
  exit 1
fi
