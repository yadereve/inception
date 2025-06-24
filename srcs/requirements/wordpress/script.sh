#!/bin/bash

until mysqladmin ping -h"$DBHOST" -u"$DBUSER" -p"$DBPASS" --silent; do
    echo "⏳ Waiting for MariaDB..."
    sleep 2
done

cd /var/www/html
DB_CHECK=$(./wp-cli.phar db size --allow-root 2>&1)
if echo "$DB_CHECK" | grep -q "0 tables"; then
    ./wp-cli.phar core download --allow-root
    ./wp-cli.phar config create \
        --dbname="$DBNAME" \
        --dbuser="$DBUSER" \
        --dbpass="$DBPASS" \
        --dbhost="$DBHOST" \
        --allow-root
    ./wp-cli.phar core install \
        --url="$DOMAIN" \
        --title="$WPTITLE" \
        --admin_user="$WPADMINUSER" \
        --admin_password="$WPADMINPASS" \
        --admin_email="$WPADMINEMAIL" \
        --allow-root
fi

php-fpm7.4 -F

