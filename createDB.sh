#!/bin/bash

# Usage Info
if [ "$#" -ne 3 ] || [ "$1" == "-h" ]; then
  echo "Usage: `basename $0` DBUSER DBNAME DBPASS"
  echo "        example `basename $0` mydbuser mydb XXXSECRETPASSXXX"
  exit 0
fi

DBUSER=$1
DBNAME=$2
DBPASS=$3


mysql -e "CREATE USER '${DBUSER}'@'localhost' IDENTIFIED WITH mysql_native_password BY '${DBPASS}';"
mysql -e "CREATE DATABASE ${DBNAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -e "GRANT ALL PRIVILEGES ON ${DBNAME}.* TO '${DBUSER}'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"