#!/bin/bash

until mysqladmin ping -h"$SQLHOST" -u"$SQLUSER" -p"$SQLPASS" --silent; do
	echo "⏳ Waiting for MariaDB..."
	sleep 2
done

# if [ ! -f wp-config.php ]; then
	wp core download --allow-root
	wp config create \
		--dbname="$SQLNAME" \
		--dbuser="$SQLUSER" \
		--dbpass="$SQLPASS" \
		--dbhost="$SQLHOST" \
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
	wp theme install \
		"$WPTHEME" --activate \
		--allow-root
# fi

exec php-fpm7.4 -F
