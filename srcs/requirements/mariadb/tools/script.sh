#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

if [ -f /run/secrets/db_root_password ]; then
	SQLROOTPASS=$(cat /run/secrets/db_root_password)
else
	echo "❌ Root password secret not found"
	exit 1
fi

if [ -f /run/secrets/db_password ]; then
	SQLPASS=$(cat /run/secrets/db_password)
else
	echo "❌ Database password secret not found"
	exit 1
fi

# Check environment variables
: "${MYSQL_DATABASE:? MYSQL_DATABASE not set}"
: "${MYSQL_USER:? MYSQL_USER not set}"

# Ensure no existing process is running
# pkill -f mysqld_safe || true
# pkill -f mysqld || true

mkdir -p /var/run/mysqld
chown mysql:mysql /var/run/mysqld

mkdir -p /var/lib/mysql
chown -R mysql:mysql /var/lib/mysql

# Initialize MariaDB data directory if it doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "📦 Initializing MariaDB data directory..."
	mysql_install_db --user=mysql --datadir=/var/lib/mysql
	# mysqld --initialize-insecure --user=mysql --datadir=/var/lib/mysql > /dev/null
fi

echo "⚙️ Starting temporary MariaDB for initial setup..."
mysqld --user=mysql --skip-networking --socket=/var/run/mysqld/mysqld.sock &
pid="$!"

# Start MariaDB temporarily without networking to set it up
# echo "⚙️ Starting MariaDB temporarily for initial setup..."
# mysqld_safe --skip-networking --user=mysql &
# mysqld_safe --user=mysql &

# Wait until MariaDB is ready
echo "⏳ Waiting for MariaDB to be ready..."
timeout=30
until mysqladmin ping --protocol=socket --silent; do
	sleep 1
	timeout=$((timeout - 1))
	if [ "$timeout" -le 0 ]; then
		echo "❌ MariaDB did not start"
		kill "$pid"
		exit 1
	fi
done

# Setup root password, database, user and privileges
echo "🔧 Setting up database and users..."
mysql -u root --protocol=socket <<EOF
-- Change root password
ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQLROOTPASS}';

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

-- Create user and grant privileges
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${SQLPASS}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

-- Flush privileges
FLUSH PRIVILEGES;
EOF

# Shut down temporary MariaDB instance gracefully
# echo "🛑 Shutting down temporary MariaDB server..."
# mysqladmin -u root -p"${SQLROOTPASS}" shutdown
# pkill -f mysqld_safe
# pkill -f mysqld
kill "$pid"
wait "$pid" 2>/dev/null || true

# Start MariaDB normally (foreground)
echo "✅ Starting MariaDB server..."
exec mysqld --user=mysql --bind-address=0.0.0.0
