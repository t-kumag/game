#!/bin/bash

echo "CREATE DATABASE IF NOT EXISTS "$MYSQL_TEST_DATABASE" ;" | "${mysql[@]}"
# echo "CREATE USER IF NOT EXISTS '"$MYSQL_TEST_USER"'@'%' ;" | "${mysql[@]}"
echo "CREATE USER IF NOT EXISTS '"$MYSQL_TEST_USER"'@'127.0.0.1' ;" | "${mysql[@]}"
# echo "SET PASSWORD FOR '"$MYSQL_TEST_USER"'@'%'=PASSWORD('"$MYSQL_PASSWORD"') ;" | "${mysql[@]}"
echo "SET PASSWORD FOR '"$MYSQL_TEST_USER"'@'127.0.0.1'=PASSWORD('"$MYSQL_PASSWORD"') ;" | "${mysql[@]}"
# echo "GRANT ALL ON "$MYSQL_TEST_DATABASE".* TO '"$MYSQL_TEST_USER"'@'%' ;" | "${mysql[@]}"
echo "GRANT ALL ON "$MYSQL_TEST_DATABASE".* TO '"$MYSQL_TEST_USER"'@'127.0.0.1' ;" | "${mysql[@]}"
echo 'FLUSH PRIVILEGES ;' | "${mysql[@]}"