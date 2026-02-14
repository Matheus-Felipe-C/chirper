# Stage 1: Build dependencies
FROM composer:2 AS composer

WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Stage 2: Application
FROM php:8.3-fpm-alpine

# Install system dependencies
RUN apk add --no-cache \
    bash \
    libzip-dev \
    oniguruma-dev \
    sqlite-dev \
    mysql-client \
    zip \
    unzip \
    curl

RUN docker-php-ext-install pdo pdo_mysql pdo_sqlite zip

WORKDIR /var/www

COPY . .
COPY --from=composer /app/vendor ./vendor

RUN chown -R www-data:www-data /var/www

CMD ["php-fpm"]
