#!/bin/bash
set -e

# Read password from secrets
if [ -f /run/secrets/db_password ]; then
	SQLPASS=$(cat /run/secrets/db_password)
else
	echo "❌ Database password secret not found"
	exit 1
fi

# Read WordPress credentials
if [ -f /run/secrets/wp_credentials ]; then
	WPADMINPASS=$(head -1 /run/secrets/wp_credentials | cut -d: -f1)
	WPUSERPASS=$(tail -1 /run/secrets/wp_credentials | cut -d: -f2)
else
	echo "❌ WordPress credentials secret not found"
	exit 1
fi

timeout=10
counter=0
echo "⏳ Waiting for MariaDB..."
until mysqladmin ping -h"$WORDPRESS_DB_HOST" -u"$WORDPRESS_DB_USER" -p"$SQLPASS" --silent; do
	sleep 2
    counter=$((counter + 1))
    if [ $counter -ge $timeout ]; then
        echo "❌ Timeout reached while waiting for MariaDB."
        exit 1
    fi
done

echo "✅ MariaDB is ready."

echo "🔧 Setting ownership for /var/www/html..."
chown -R www-data:www-data /var/www/html

if [ ! -f wp-config.php ]; then
	echo "📥 Downloading WordPress core..."
	wp core download --allow-root

	echo "⚙️ Creating WordPress configuration..."
	wp config create \
		--dbname="$WORDPRESS_DB_NAME" \
		--dbuser="$WORDPRESS_DB_USER" \
		--dbpass="$SQLPASS" \
		--dbhost="$WORDPRESS_DB_HOST" \
		--allow-root

	echo "🏗️ Installing WordPress..."
	wp core install \
		--url="$DOMAIN" \
		--title="$WPTITLE" \
		--admin_user="$WPADMINUSER" \
		--admin_password="$WPADMINPASS" \
		--admin_email="$WPADMINEMAIL" \
		--allow-root

	echo "👤 Creating additional user..."
	wp user create \
		"$WPUSER" \
		"$WPUSEREMAIL" \
		--user_pass="$WPUSERPASS" \
		--role=author \
		--allow-root

	echo "🎨 Activating theme..."
	wp theme activate \
		"$WPTHEME" --allow-root
fi

echo "✅ WordPress installation complete."

# Ensure correct ownership before starting PHP-FPM
chown -R www-data:www-data /var/www/html

echo "🚀 Starting PHP-FPM..."
if command -v php-fpm7.4 >/dev/null 2>&1; then
    echo "✅ php-fpm7.4 found"
    php-fpm7.4 --version
else
    echo "❌ php-fpm7.4 not found"
    ls -la /usr/sbin/php*
    exit 1
fi

echo "🔍 Checking PHP-FPM status..."
php-fpm7.4 -t

exec php-fpm7.4 -F
