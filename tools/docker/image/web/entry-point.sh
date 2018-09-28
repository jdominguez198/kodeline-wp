#!/bin/bash
set -e

if [ ! -e /var/www-conf/composer.json ]; then
    echo "Installation can't be launched twice. Rebuild the web container"
    exit 1
fi

echo "Moving composer.json file to right folder..."
sed -i 's#${WORDPRESS_VERSION}#'"${WORDPRESS_VERSION}"'#g' /var/www-conf/composer.json
mv /var/www-conf/composer.json /var/www/composer.json

echo "Executing composer install..."
composer install

echo "Executing config installation..."
/var/www-conf/install-configs.sh

echo "Executing database setup..."
php /var/www-conf/install-db.php

echo "Executing theme installation..."
/var/www-conf/install-theme.sh

echo "Cleaning environment vars for security..."
envs=(
    WORDPRESS_DB_HOST
    WORDPRESS_DB_USER
    WORDPRESS_DB_PASSWORD
    WORDPRESS_DB_NAME
    WORDPRESS_DB_CHARSET
    WORDPRESS_DB_COLLATE
    "${uniqueEnvs[@]/#/WORDPRESS_}"
    WORDPRESS_TABLE_PREFIX
    WORDPRESS_DEBUG
    WORDPRESS_CONFIG_EXTRA
)
for e in "${envs[@]}"; do
    unset "$e"
done

echo "Cleaning files..."
rm -rf /var/www/composer.* /var/www-conf/*

exec "$@"