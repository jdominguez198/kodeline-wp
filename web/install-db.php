<?php
// database might not exist, so let's try creating it (just to be safe)
$stderr = fopen('php://stderr', 'w');
// https://codex.wordpress.org/Editing_wp-config.php#MySQL_Alternate_Port
//   "hostname:port"
// https://codex.wordpress.org/Editing_wp-config.php#MySQL_Sockets_or_Pipes
//   "hostname:unix-socket-path"
list($host, $socket) = explode(':', getenv('WORDPRESS_DB_HOST'), 2);
$port = 0;
if (is_numeric($socket)) {
    $port = (int) $socket;
    $socket = null;
}
$user = getenv('WORDPRESS_DB_USER');
$pass = getenv('WORDPRESS_DB_PASSWORD');
$dbName = getenv('WORDPRESS_DB_NAME');
$maxTries = 10;
echo sprintf('Connecting to \'%s:%s\' with user \'%s\' and password \'%s\'...', $host, $port, $user, $pass);
do {
    $mysql = new mysqli($host, $user, $pass, '', $port, $socket);
    if ($mysql->connect_error) {
        fwrite($stderr, "\n" . 'MySQL Connection Error: (' . $mysql->connect_errno . ') ' . $mysql->connect_error . "\n");
        --$maxTries;
        if ($maxTries <= 0) {
            exit(1);
        }
        sleep(3);
    }
} while ($mysql->connect_error);
if (!$mysql->query('CREATE DATABASE IF NOT EXISTS `' . $mysql->real_escape_string($dbName) . '`')) {
    fwrite($stderr, "\n" . 'MySQL "CREATE DATABASE" Error: ' . $mysql->error . "\n");
    $mysql->close();
    exit(1);
}
$mysql->close();