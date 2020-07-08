#!/bin/sh

#abort on error
set -e

function usage
{
    echo "usage: mysql_template -MYSQL_ROOT_PASSWORD AN_ARG -MYSQL_USER AN_ARG -MYSQL_PASSWORD AN_ARG -MYSQL_DATABASE AN_ARG"
    echo "   ";
    echo "  -MYSQL_ROOT_PASSWORD            : MySQL Root User Password";
    echo "  -MYSQL_USER                     : MySQL Username";
    echo "  -MYSQL_PASSWORD                 : MySQL Password";
    echo "  -MYSQL_DATABASE                 : Database name";
    echo "  -h | --help                     : This message";
}

function parse_args
{
  # positional args
  args=()

  # named args
  while [ "$1" != "" ]; do
      case "$1" in
          -MYSQL_ROOT_PASSWORD )               MYSQL_ROOT_PASSWORD="$2";             shift;;
          -MYSQL_USER )                        MYSQL_USER="$2";     shift;;
          -MYSQL_PASSWORD )                    MYSQL_PASSWORD="$2";      shift;;
          -MYSQL_DATABASE )                    MYSQL_DATABASE="$2";     shift;;
          -h | --help )                 usage;                   exit;; # quit and show usage
          * )                           args+=("$1")             # if no match, add it to the positional args
      esac
      shift # move to next kv pair
  done

  # validate required args
  if [[ -z "${MYSQL_ROOT_PASSWORD}" || -z "${MYSQL_USER}" || -z "${MYSQL_PASSWORD}" || -z "${MYSQL_DATABASE}" ]]; then
      echo "Invalid arguments"
      usage
      exit;
  fi
}

function run
{
  parse_args "$@"

  echo "you passed in...\n"
  echo "MYSQL_ROOT_PASSWORD: $MYSQL_ROOT_PASSWORD"
  echo "MYSQL_USER: $MYSQL_USER"
  echo "MYSQL_PASSWORD: $MYSQL_PASSWORD"
  echo "MYSQL_DATABASE: $MYSQL_DATABASE"
  systemctl enable mariadb.service
  systemctl start mariadb.service

  SECURE_MYSQL=$( expect -c "
  set timeout 10
  spawn mysql_secure_installation
  expect \"Enter current password for root (enter for none):\"
  send \"$MYSQL\r\"
  expect \"Set root password?\"
  send \"Y\r\"
  expect \"New password:\"
  send \"$MYSQL_ROOT_PASSWORD\r\"
  expect \"Re-enter new password:\"
  send \"$MYSQL_ROOT_PASSWORD\r\"
  expect \"Remove anonymous users?\"
  send \"Y\r\"
  expect \"Disallow root login remotely?\"
  send \"Y\r\"
  expect \"Remove test database and access to it?\"
  send \"Y\r\"
  expect \"Reload privilege tables now?\"
  send \"Y\r\"
  expect eof
  " )

  echo $SECURE_MYSQL
  mysql -u root -p$MYSQL_ROOT_PASSWORD --execute="GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD'"
  mysql -u root -p$MYSQL_ROOT_PASSWORD --execute="create database $MYSQL_DATABASE"
  mysql -u root -p$MYSQL_ROOT_PASSWORD --execute="CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD'"
  mysql -u root -p$MYSQL_ROOT_PASSWORD --execute="GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD'"
}

run "$@";
