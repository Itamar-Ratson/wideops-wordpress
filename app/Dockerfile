FROM php:7.4-apache

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" gd mysqli \
    && rm -rf /var/lib/apt/lists/*

RUN printf '%s\n' 'SetEnvIf X-Forwarded-Proto "^https$" HTTPS=on' \
        > /etc/apache2/conf-available/forwarded-https.conf \
    && a2enconf forwarded-https

RUN printf '%s\n' 'mysqli.default_socket=/var/run/mysqld/mysqld.sock' \
        > /usr/local/etc/php/conf.d/mysqli-socket.ini

COPY . /var/www/html/
