FROM debian:oldstable

RUN apt update && apt install -y \
    lsb-release ca-certificates curl apt-transport-https gnupg \
 && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list \
 && curl -fsSL https://packages.sury.org/php/apt.gpg | apt-key add - \
 && apt update && apt install -y php7.4 php7.4-fpm php-mysqli

COPY www.conf /etc/php/7.4/fpm/pool.d/.

RUN mkdir -p /run/php

CMD ["php-fpm7.4", "-F"]
