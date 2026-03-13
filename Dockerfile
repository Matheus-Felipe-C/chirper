# Stage 1: Node (Vite build)
FROM node:22-alpine AS frontend
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 2: Composer
FROM composer:2 AS composer
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-scripts
COPY . .
RUN composer dump-autoload --optimize

# Stage 3: App
FROM php:8.4-fpm-alpine

RUN apk add --no-cache \
    nginx \
    bash \
    libzip-dev \
    oniguruma-dev \
    postgresql-dev \
    mariadb-dev \
    zip \
    unzip \
    curl

RUN docker-php-ext-install \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    pgsql \
    zip

WORKDIR /var/www
COPY --from=composer /app /var/www
COPY --from=frontend /app/public/build /var/www/public/build

# Nginx config (snippet only — http.d is included inside http {}, so no "events"/"http" block)
COPY docker/nginx-http-snippet.conf /etc/nginx/http.d/default.conf

RUN mkdir -p /run/nginx /var/lib/nginx/tmp \
    && chown -R www-data:www-data /var/www

EXPOSE 8080

CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]