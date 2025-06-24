FROM debian:oldstable

RUN apt-get update && apt-get install -y lsb-release apt-transport-https ca-certificates curl gnupg \
    && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list \
    && curl -fsSL https://packages.sury.org/php/apt.gpg | apt-key add - \
    && apt-get update && apt-get install -y \
    php7.4 php7.4-fpm php7.4-mysql php7.4-mbstring php7.4-xml \
    php7.4-gd php7.4-curl php7.4-zip php7.4-xmlrpc php7.4-soap php7.4-intl php7.4-cli php7.4-ldap php7.4-imap \
    php7.4-gmp php7.4-bcmath php7.4-imagick php7.4-redis \
    default-mysql-client

# copy config file
COPY www.conf /etc/php/7.4/fpm/pool.d/.

# copy script
COPY script.sh .
RUN chmod +x script.sh

RUN mkdir -p /run/php

RUN mkdir -p /var/www/html
RUN set -ex && \
    cd /var/www/html && \
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar

ENTRYPOINT [ "./script.sh" ]
