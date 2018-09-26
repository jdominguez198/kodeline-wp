# kodeline Wordpress in Docker

## Getting Started

You have a set of different commands to manage this container. These are:

> bin/console install

This command must be your first step, because it will create all the necessary files to work with Wordpress in this container.
<br/>Once the process ends, you can start your container using:

> bin/console start

It starts the container (without daemon), and allows you to access to http://localhost:8000/ to enter your site.
<br/>You can stop the process using CTRL + C. To ensure the container is stopped, you can use:

> bin/console stop

And if you want to remove the containers (keeping the data of it, off course), the command will be:

> bin/console down

## Changelog

> v1.0.0 - 26/09/18

- First version with basic setup, no .env files (TODO)
- Wordpress version 4.9.8
- kodeline Theme (from private repository, you can use whatever you want)
- Basic console commands