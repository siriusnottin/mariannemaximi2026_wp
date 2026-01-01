FROM php:8.2-apache

# Enable Apache modules
RUN a2enmod rewrite headers

# PHP extensions commonly needed by WordPress/Bedrock
RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libpng-dev libjpeg-dev libonig-dev libxml2-dev \
 && docker-php-ext-configure gd --with-jpeg \
 && docker-php-ext-install pdo_mysql mysqli zip gd \
 && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
