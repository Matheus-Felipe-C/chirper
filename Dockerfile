# ---- Base PHP Image ----
FROM php:8.4.1-fpm-alpine

# Install system dependencies
RUN apk add --no-cache \
    nginx \
    curl \
    git \
    unzip \
    libzip-dev \
    oniguruma-dev \
    icu-dev \
    bash

# Install PHP extensions required by Laravel
RUN docker-php-ext-install \
    pdo \
    pdo_mysql \
    mbstring \
    intl \
    zip \
    opcache

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy application files
COPY . .

RUN mkdir -p storage/framework/views \
    storage/framework/cache \
    storage/framework/sessions \
 && chown -R www-data:www-data storage bootstrap/cache

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Set correct permissions
RUN chown -R www-data:www-data storage bootstrap/cache

# ---- Nginx configuration ----
COPY docker/nginx.conf /etc/nginx/nginx.conf

# Expose port
EXPOSE 80

# Start services
CMD php-fpm -D && nginx -g "daemon off;"