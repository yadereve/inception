#!/bin/bash

until mysqladmin ping -h"mariadb" --silent; do
    echo "⏳ Waiting for MariaDB..."
    sleep 2
done

cd /var/www/html
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
if [ ! -f /var/www/http/wp-config.php ]; then
    ./wp-cli.phar core download --allow-root
    ./wp-cli.phar config create \
        --dbname=wordpress \
        --dbuser=wpuser \
        --dbpass=password \
        --dbhost=mariadb \
        --allow-root
    ./wp-cli.phar core install \
        --url=localhost \
        --title=inception \
        --admin_user=admin \
        --admin_password=admin \
        --admin_email=admin@admin.com \
        --allow-root
fi

php-fpm7.4 -F

