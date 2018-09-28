# kodeline Wordpress in Docker

## Getting Started

First of all, you must create your .env (environment) file.
Use the following command to create it. After, edit it with your common editor:

> cp tools/docker/env-example tools/docker/.env

You have a set of different commands to manage this container. These are:

> bin/console install

This command must be your first step. It will create all the necessary files to work with WordPress in this container.
<br/>Once the process ends, you can start your container using:

> bin/console start

It starts the container (without daemon), and allows you to access your localhost (and port used on your .env file) to enter your site.
<br/>You can stop the running containers using CTRL + C. To ensure all the containers are stopped, you can use:

> bin/console stop

And if you want to remove the containers (keeping safe the data from them, off course), the command will be:

> bin/console down

## Changelog

> v1.1.0 - 2018-09-28

- Changed folder structure
- Enhanced Gulp Dockerfile
- Enhanced Web Dockerfile
- Added .env setup

> v1.0.0 - 2018-09-26

- First version with basic setup, no .env files (TODO)
- Wordpress version 4.9.8
- kodeline Theme (from private repository, you can use whatever you want)
- Basic console commands