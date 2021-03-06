#!/bin/bash

# This script starts the database server.
echo "Creating user $user for databases loaded from $url"

# Import database if provided via 'docker run --env url="http:/ex.org/db.sql"'
echo "Adding data into MySQL"

file -bi /var/mysql/database.sql
/usr/sbin/mysqld &
sleep 5
curl $url | mysql --default-character-set=utf8
mysqladmin shutdown

# Now the provided user credentials are added
/usr/sbin/mysqld &
sleep 5
echo "Creating user"
echo "CREATE USER 'reviewer'" | mysql --default-character-set=utf8
echo "REVOKE ALL PRIVILEGES ON *.* FROM 'reviewer'@'%'; FLUSH PRIVILEGES" | mysql --default-character-set=utf8
echo "GRANT SELECT ON *.* TO 'reviewer'@'%'; FLUSH PRIVILEGES" | mysql --default-character-set=utf8

# And we restart the server to go operational
mysqladmin shutdown
echo "Starting MySQL Server"
/usr/sbin/mysqld
