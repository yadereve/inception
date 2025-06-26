#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Check that all required environment variables are set
: "${SQLNAME:? SQLNAME not set}"
: "${SQLUSER:? SQLUSER not set}"
: "${SQLPASS:? SQLPASS not set}"
: "${SQLROOTPASS:? SQLROOTPASS not set}"

# Ensure no existing process is running to avoid file locking
pkill -f mysqld_safe || true
pkill -f mysqld || true

# Initialize MariaDB data directory if it doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "📦 Initializing MariaDB data directory..."
	mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null
	# mysqld --initialize-insecure --user=mysql --datadir=/var/lib/mysql > /dev/null
fi

# Start MariaDB temporarily without networking to set it up
echo "⚙️ Starting MariaDB temporarily for initial setup..."
mysqld_safe --skip-networking &
# Wait for MariaDB to start
sleep 5

# Wait until MariaDB is ready to accept connections
echo "⏳ Waiting for MariaDB to be ready..."
until mysqladmin ping --silent; do
	sleep 1
done

# Setup root password, database, user and privileges
echo "🔧 Setting up database and users..."
mysql -u root <<EOF
-- Change root password
ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQLROOTPASS}';

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS \`${SQLNAME}\`;

-- Create user and grant privileges
CREATE USER IF NOT EXISTS '${SQLUSER}'@'%' IDENTIFIED BY '${SQLPASS}';
GRANT ALL PRIVILEGES ON \`${SQLNAME}\`.* TO '${SQLUSER}'@'%';

-- 🚿 Flush privileges
FLUSH PRIVILEGES;
EOF

# Shut down temporary MariaDB instance gracefully
echo "🛑 Shutting down temporary MariaDB server..."
mysqladmin -u root -p"${SQLROOTPASS}" shutdown

# Start MariaDB normally (foreground)
echo "✅ Starting MariaDB server..."
exec mysqld --bind-address=0.0.0.0
