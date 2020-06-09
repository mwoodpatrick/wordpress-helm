#!/bin/sh

# install the PHP extensions (from the WP Dockerfile)
set -ex;

savedAptMark="$(apt-mark showmanual)";

apt-get update;
apt-get install -y --no-install-recommends \
	libjpeg-dev \
	libpng-dev \
	libzip-dev \
;

docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr;
docker-php-ext-install gd mysqli opcache zip;

# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
apt-mark auto '.*' > /dev/null;
apt-mark manual $savedAptMark;
ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
	| awk '/=>/ { print $3 }' \
	| sort -u \
	| xargs -r dpkg-query -S \
	| cut -d: -f1 \
	| sort -u \
	| xargs -rt apt-mark manual; \

apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false;
rm -rf /var/lib/apt/lists/*

