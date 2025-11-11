FROM php:8.3-apache-trixie AS php

WORKDIR /build

# install dependencies to build image
RUN \
    apt update && apt full-upgrade -y && \
    apt install --no-install-recommends libldap2-dev wget zlib1g-dev libpng-dev libzip-dev curl libcurl4-gnutls-dev libxml2-dev libpq-dev unzip libicu-dev -y && \
    rm -rf /var/lib/apt/lists/* && \
    docker-php-ext-configure ldap --with-libdir=lib/$(uname -m)-linux-gnu/ && \
    docker-php-ext-configure pdo --with-libdir=lib/$(uname -m)-linux-gnu/ && \
    docker-php-ext-install ldap pdo && \
    docker-php-ext-install zip curl bcmath dom ctype iconv pdo_mysql pdo_pgsql gd intl

RUN pecl install --force redis-6.0.2 \
&& rm -rf /tmp/pear \
&& docker-php-ext-enable redis

FROM php AS php-build

# copy files
#COPY . .
# get GitHub repository
RUN wget https://github.com/Lopo/Limas/archive/refs/heads/master.zip
RUN unzip master.zip
RUN mv Limas-master/* Limas-master/.* . || true
# get php composer
RUN wget https://getcomposer.org/installer -O - | php -- \
# install composer dependencies
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN SYMFONY_ENV=prod php composer.phar install -o



FROM node:20-trixie-slim AS node

WORKDIR /build
# build frontend files
COPY --from=php-build /build .
RUN yarn install --frozen-lockfile
RUN yarn build



FROM php AS final

COPY --from=node --chown=www-data:www-data /build /var/www/html

# apply apache2 config for symfony
RUN bash -c 'echo -e "<VirtualHost *:80>\n\
        ServerAdmin webmaster@localhost\n\
        DocumentRoot /var/www/html/public/\n\
        <Directory /var/www/html/public>\n\
            AllowOverride None\n\
            Require all granted\n\
            FallbackResource /index.php\n\
        </Directory>\n\
\n\
        ErrorLog \${APACHE_LOG_DIR}/error.log\n\
        CustomLog \${APACHE_LOG_DIR}/access.log combined\n\
\n\
</VirtualHost>\
" > /etc/apache2/sites-available/000-default.conf'

EXPOSE 80

WORKDIR /var/www/html

# specify environment variables for .env file

ENV REDIS_DSN="redis://redis"
ENV APP_ENV="prod"
ENV APP_SECRET=""
ENV DATABASE_URL="mysql://limas:limas@mysql:3306/limas?serverVersion=8.4.6&charset=utf8mb4"
ENV NEXAR_ID="client"
ENV NEXAR_SECRET="secret"
# ISO 3166 (alpha-2) country code
ENV NEXAR_COUNTRY="DE"
# ISO 4217 currency code
ENV NEXAR_CURRENCY="EUR"


# run build commands
RUN php bin/console limas:extjs:models
RUN php bin/console cache:warmup

# overwrite entrypoint for custom startup commands
COPY entrypoint.sh /var/www/html/docker/entrypoint.sh
RUN chmod +x /var/www/html/docker/entrypoint.sh

RUN mkdir -p /var/www/html/data

#VERY SLOW: RUN chown www-data:www-data -R /var/www/html
RUN find /var/www/html -not -group www-data -not -user www-data -print0 | xargs -P 0 -0 --no-run-if-empty chown --no-dereference www-data:www-data

#VOLUME ["/var/www/html/data"]
# workaround for the data folder
USER root
ENTRYPOINT ["/var/www/html/docker/entrypoint.sh"]