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
	WPADMINPASS=$(head -1 /run/secrets/wp_credentials | cut -d: -f2)
	WPUSERPASS=$(tail -1 /run/secrets/wp_credentials | cut -d: -f2)
else
	echo "❌ WordPress credentials secret not found"
	exit 1
fi

echo "⏳ Waiting for MariaDB..."
until mysqladmin ping -h"$WORDPRESS_DB_HOST" -u"$WORDPRESS_DB_USER" -p"$SQLPASS" --silent; do
	sleep 2
done

echo "✅ MariaDB is ready."

echo "🔧 Setting ownership for /var/www/html..."
chown -R www-data:www-data /var/www/html

if [ ! -f wp-config.php ]; then
	wp core download --allow-root
	wp config create \
		--dbname="$WORDPRESS_DB_NAME" \
		--dbuser="$WORDPRESS_DB_USER" \
		--dbpass="$SQLPASS" \
		--dbhost="$WORDPRESS_DB_HOST" \
		--allow-root
	wp core install \
		--url="$DOMAIN" \
		--title="$WPTITLE" \
		--admin_user="$WPADMINUSER" \
		--admin_password="$WPADMINPASS" \
		--admin_email="$WPADMINEMAIL" \
		--allow-root
	wp user create \
		"$WPUSER" \
		"$WPUSEREMAIL" \
		--user_pass="$WPUSERPASS" \
		--role=author \
		--allow-root
	wp theme activate \
		"$WPTHEME" --allow-root
fi

echo "✅ WordPress installation complete."
exec php-fpm7.4 -F
