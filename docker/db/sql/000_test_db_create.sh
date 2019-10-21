#!/bin/bash

echo "CREATE DATABASE IF NOT EXISTS "$MYSQL_TEST_DATABASE" ;" | "${mysql[@]}"
echo "CREATE USER IF NOT EXISTS '"$MYSQL_TEST_USER"'@'%' ;" | "${mysql[@]}"
echo "SET PASSWORD FOR '"$MYSQL_TEST_USER"'@'%'=PASSWORD('"$MYSQL_PASSWORD"') ;" | "${mysql[@]}"
echo "GRANT ALL ON "$MYSQL_TEST_DATABASE".* TO '"$MYSQL_TEST_USER"'@'%' ;" | "${mysql[@]}"
echo 'FLUSH PRIVILEGES ;' | "${mysql[@]}"