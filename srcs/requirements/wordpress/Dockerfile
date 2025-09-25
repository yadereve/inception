FROM debian:oldstable

RUN apt update && apt install -y \
    curl \
    wget \
    gnupg2 \
    ca-certificates \
    lsb-release \
    apt-transport-https

RUN wget -qO /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list

RUN apt update && apt install -y \
    php7.4 \
    php7.4-fpm \
    php7.4-cli \
    php7.4-json \
    php7.4-common \
    php7.4-mysql \
    php7.4-zip \
    php7.4-gd \
    php7.4-mbstring \
    php7.4-curl \
    php7.4-xml \
    php7.4-bcmath \
    mariadb-client \
    && apt clean

# Install PHP 7.4 and listen on port 9000
RUN if [ -f /etc/php/7.4/fpm/pool.d/www.conf ]; then \
		sed -i 's|listen = /run/php/php7.4-fpm.sock|listen = 9000|g' /etc/php/7.4/fpm/pool.d/www.conf; \
	else \
		echo "❌ PHP-FPM config not found"; \
		ls -la /etc/php/7.4/fpm/pool.d/; \
	fi

WORKDIR /var/www/html

# copy script
COPY ./tools/script.sh /tmp/script.sh
RUN chmod +x /tmp/script.sh

# Configure PHP-FPM to run in the foreground
RUN mkdir -p /run/php

EXPOSE 9000

# Start the PHP-FPM server
ENTRYPOINT [ "bash", "/tmp/script.sh" ]
