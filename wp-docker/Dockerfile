FROM php:7.3-apache-stretch

COPY install-php-extensions.sh .
RUN chmod +x install-php-extensions.sh
RUN ./install-php-extensions.sh

# set recommended PHP.ini settings
COPY opcache-recommended.ini /usr/local/etc/php/conf.d/opcache-recommended.ini
# https://codex.wordpress.org/Editing_wp-config.php#Configure_Error_Logging
COPY error-logging.ini /usr/local/etc/php/conf.d/error-logging.ini

RUN a2enmod rewrite expires

# Install phpredis
RUN pecl install -o -f redis \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis

# Do not use a privileged port for Apache so it can run as non-root
ENV PORT 8080
ENV TLS_PORT 8443
RUN sed -i "s/\<80\>/$PORT/g" /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf
RUN sed -i "s/\<443\>/$TLS_PORT/g" /etc/apache2/sites-available/default-ssl.conf /etc/apache2/ports.conf
