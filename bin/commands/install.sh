#!/bin/bash
set -eu

cd ${ABSOLUTE_PATH}/${DOCKER_FOLDER}

if [ ! -e .env ]; then
    echo "You must create a .env file at ${DOCKER_FOLDER}"
    exit 1
fi

# Start all containers
echo "Starting all containers..."
docker-compose up -d

echo "Launching installation inside web container..."
docker-compose exec web /entry-point.sh

# Stop all containers
echo "Stopping all containers..."
docker-compose stop

echo "Installation complete!"