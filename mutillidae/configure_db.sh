#!/bin/bash

set -euo pipefail

MYSQL_ROOT_PASSWORD='test'

MYSQL_DB='mutillidae'
MYSQL_USER='mutillidae'
MYSQL_PASSWORD='mutillidae'

cat <<EOF | /usr/bin/mysqld --datadir='./data' --user=mysql --bootstrap --verbose=0
USE mysql;
FLUSH PRIVILEGES;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' identified by '${MYSQL_ROOT_PASSWORD}' WITH GRANT OPTION;
UPDATE user SET password=PASSWORD("${MYSQL_ROOT_PASSWORD}") WHERE user='root' AND host='localhost';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DB} CHARACTER SET utf8 COLLATE utf8_general_ci;
GRANT ALL ON ${MYSQL_DB}.* TO '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
FLUSH PRIVILEGES;
EOF

cat <<EOF > /usr/share/nginx/html/mutillidae/includes/database-config.php
<?php
define('DB_HOST', 'acra-connector');
define('DB_USERNAME', '${MYSQL_USER}');
define('DB_PASSWORD', '${MYSQL_PASSWORD}');
define('DB_NAME', '${MYSQL_DB}');
?>
EOF

cat <<EOF > /etc/my.cnf.d/mariadb-server.cnf
[mysqld]
bind-address=0.0.0.0
EOF
