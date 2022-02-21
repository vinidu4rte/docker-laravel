FROM composer:2.1.6 as build

COPY php.ini /usr/local/etc/php/

COPY . .

RUN composer install --ignore-platform-reqs

FROM php:8.0.10-apache as prod

WORKDIR /var/www

RUN docker-php-ext-install pdo_mysql

# apache config
COPY apache2.conf /etc/apache2/

COPY --from=build /app/vendor/  ./vendor
COPY --from=build /app/composer.lock  .

COPY . .

RUN chmod 777 -R storage/
RUN chmod 777 -R bootstrap/

RUN a2enmod rewrite

RUN php artisan key:generate
RUN php artisan migrate:fresh --seed

# configs para deploy
# RUN php artisan config:cache
# RUN php artisan route:cache
# RUN php artisan view:cache