#!/bin/sh
if [ -f "/var/lib/mysql/my.cnf" ] ; then
  cp /var/lib/mysql/my.cnf /etc/mysql/
else
  if ! mysql_install_db_prog="$(type -p "mysql_install_db")" || [ -z "$mysql_install_db_prog" ]; then
    mysqld --initialize-insecure --user=mysql
    r=$?
    if [ "$r" -ne 0 ]; then
      echo "Errorcode: $r"
      echo "Cannot initial DB" 
      exit 3
    fi
  else
    mysql_install_db  --user=mysql
    r=$?
    if [ "$r" -ne 0 ]; then
      echo "Errorcode: $r"
      echo "Cannot initial DB" 
      exit 3
    fi
  fi

  if [ "$MYSQL_ROOT_PASSWORD" = "" ]; then
    MYSQL_ROOT_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 24 | head -n 1)
    echo "MySQL root Password: $MYSQL_ROOT_PASSWORD"
  fi

  MYSQL_DATABASE=${MYSQL_DATABASE:-""}
  MYSQL_USER=${MYSQL_USER:-""}
  MYSQL_PASSWORD=${MYSQL_PASSWORD:-""}

  if [ ! -d "/run/mysqld" ]; then
    mkdir -p /run/mysqld
  fi

  tfile=`mktemp`
  if [ ! -f "$tfile" ]; then
      return 1
  fi


  cat << EOF > $tfile
USE mysql;
FLUSH PRIVILEGES;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
UPDATE user SET password=PASSWORD("$MYSQL_ROOT_PASSWORD") WHERE user='root' AND host='localhost';
EOF

  if [ ! -z $MYSQL_ROOT_HOST ]; then
    echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'$MYSQL_ROOT_HOST' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD' with grant option;" >> $tfile
  fi  
  if [ ! -z "$MYSQL_DATABASE" ]; then
    echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` CHARACTER SET utf8 COLLATE utf8_general_ci;" >> $tfile
  fi
  if [ ! -z "$MYSQL_USER" ] && [ ! -z "$MYSQL_HOST" ]; then
      echo "GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'$MYSQL_HOST' IDENTIFIED BY '$MYSQL_PASSWORD' with grant option;" >> $tfile
  fi
  echo "FLUSH PRIVILEGES;" >> $tfile
  /usr/bin/mysqld --user=mysql  --bootstrap  < $tfile

  cp /etc/mysql/my.cnf /var/lib/mysql/
fi
