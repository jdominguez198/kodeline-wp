#!/bin/bash
set -eu

echo "Executing installation of basic theme"

cd /var/www/

echo "Downloading theme..."
git clone https://${WORDPRESS_THEME_REPOSITORY_USER}:${WORDPRESS_THEME_REPOSITORY_PASSWORD}@${WORDPRESS_THEME_REPOSITORY} theme

echo "Copying to wp-content folder..."
cp -R /var/www/theme/wp-content/. /var/www/html/wp-content/

echo "Executing sql import..."
sed -i 's#${SITE_USER}#'"${WORDPRESS_ADMIN_USER}"'#g' /var/www/theme/database/dump.sql
sed -i 's#${SITE_EMAIL}#'"${WORDPRESS_ADMIN_EMAIL}"'#g' /var/www/theme/database/dump.sql
sed -i 's#${SITE_URL}#'"localhost:${WORDPRESS_SITE_PORT}"'#g' /var/www/theme/database/dump.sql
mysql -u${WORDPRESS_DB_USER} -p${WORDPRESS_DB_PASSWORD} -hdb ${WORDPRESS_DB_NAME} < /var/www/theme/database/dump.sql

echo "Cleaning..."
rm -rf /var/www/html/.git /var/www/html/wp-content/themes/twenty* /var/www/theme

echo "Theme installation complete"