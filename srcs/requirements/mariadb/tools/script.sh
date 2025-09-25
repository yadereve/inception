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

pkill -f mysqld_safe || true
pkill -f mysqld || true

# Ensure directories exist with correct permissions
mkdir -p /var/run/mysqld
chown mysql:mysql /var/run/mysqld
mkdir -p /var/lib/mysql
chown -R mysql:mysql /var/lib/mysql

# Initialize MariaDB data directory if it doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "📦 Initializing MariaDB data directory..."
	mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Only setup database if it hasn't been setup before
if [ ! -f "/var/lib/mysql/.db_setup_complete" ]; then
	echo "⚙️ Starting temporary MariaDB for initial setup..."
	mysqld --user=mysql --skip-networking &
	pid="$!"

	# Wait until MariaDB is ready
	echo "⏳ Waiting for MariaDB to be ready..."
	timeout=30
	until mysqladmin ping --socket=/var/run/mysqld/mysqld.sock --silent; do
		sleep 1
		timeout=$((timeout - 1))
		if [ "$timeout" -le 0 ]; then
			echo "❌ MariaDB did not start"
			kill "$pid" 2>/dev/null || true
			exit 1
		fi
	done

	# Setup root password, database, user and privileges
	echo "🔧 Setting up database and users..."

	mysql --socket=/var/run/mysqld/mysqld.sock -u root <<MYSQL_SCRIPT
	CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
	CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${SQLPASS}';
	GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
	ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQLROOTPASS}';
	FLUSH PRIVILEGES;
MYSQL_SCRIPT

	# Mark setup as complete
	touch /var/lib/mysql/.db_setup_complete
	echo "✅ Database setup completed successfully!"

	# Shut down temporary MariaDB
	kill "$pid" 2>/dev/null || true
    wait "$pid" 2>/dev/null || true
fi

# Start MariaDB normally (foreground)
echo "✅ Starting MariaDB server..."
exec mysqld --user=mysql --bind-address=0.0.0.0 --port=3306
