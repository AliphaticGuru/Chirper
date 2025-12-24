# Development setup

# FROM hardcore28/lara-base:8.4 AS app

# WORKDIR /var/www/html

# ENV PORT=80
# EXPOSE 80


# ---------- Vite build ----------
FROM node:20-alpine AS vite

WORKDIR /app
COPY src/package*.json ./
RUN npm install
COPY src/ .
RUN npm run build

## Production setup

FROM hardcore28/lara-base:8.4

WORKDIR /var/www/html/

ARG COMPOSER_AUTH
ENV COMPOSER_AUTH=$COMPOSER_AUTH

ENV PORT=10000
ENV APP_ENV=production
ENV APP_DEBUG=false
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_MEMORY_LIMIT=-1

USER root

# Install nginx
RUN apk add --no-cache nginx gettext \
    git \
    unzip \
    icu-dev \
    oniguruma-dev \
    libzip-dev \
    && mkdir -p /etc/nginx/http.d \
    && mkdir -p /run/nginx

RUN sed -i 's/^;*clear_env\s*=.*/clear_env = no/' /usr/local/etc/php-fpm.d/www.conf    

# Copy app
COPY ./src/ /var/www/html/

# Copy built assets
COPY --from=vite /app/public/build /var/www/html/public/build

RUN composer install \
    --no-dev \
    --optimize-autoloader \
    --no-interaction \
    --prefer-dist \
    --no-progress

# Copy nginx config
COPY nginx/default.conf.template /etc/nginx/default.conf.template


# Laravel permissions
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

EXPOSE 10000  

CMD sh -c "\
    php-fpm & \
    envsubst '\$PORT' < /etc/nginx/default.conf.template > /etc/nginx/http.d/default.conf && \
    nginx -g 'daemon off;' \
"
