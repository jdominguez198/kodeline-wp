#!/bin/bash
set -eu

cd ${ABSOLUTE_PATH}/${DOCKER_FOLDER}

# Start all containers
docker-compose up -d

# Execute composer installation for dependencies
docker-compose exec web composer install

# Add all settings needed
docker-compose exec web ./install-configs.sh

# Create the database
docker-compose exec web php install-db.php

# Optional! Install a basic theme
cd ${ABSOLUTE_PATH}/${WEB_FOLDER}
git clone git@bitbucket.org:kodeline/wp-theme-kodeline.git theme
cp -R theme/wp-content/. html/wp-content/
rm -rf html/wp-content/themes/twenty*
cd ${ABSOLUTE_PATH}/${DOCKER_FOLDER}
docker exec -i $(docker-compose ps -q db) mysql -uwordpress -pwordpress wordpress < ${ABSOLUTE_PATH}/${WEB_FOLDER}/theme/database/dump.sql

# Stop all containers
docker-compose stop