FROM debian:oldstable

RUN apt-get update && apt-get install -y curl php-fpm php-mysql php-mbstring php-xml \
    php-gd php-curl php-zip php-xmlrpc php-soap php-intl php-cli php-ldap php-imap \
    php-gmp php-bcmath php-imagick php-redis \
    default-mysql-client

# Install PHP 7.4 and listen on port 9000
RUN sed -i 's|listen = /run/php/php7.4-fpm.sock|listen = 9000|g' /etc/php/7.4/fpm/pool.d/www.conf

WORKDIR /var/www/html

# copy script
COPY ./tools/script.sh .
RUN chmod +x script.sh

# Configure PHP-FPM to run in the foreground
RUN mkdir -p /run/php


# Download and extract WordPress
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

EXPOSE 9000

# Start the PHP-FPM server
ENTRYPOINT [ "bash", "./script.sh" ]
