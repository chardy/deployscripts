#!/bin/bash

###########################################################
# mysql-server
###########################################################
# ref: installing non attended
# http://stackoverflow.com/questions/7739645/install-mysql-on-ubuntu-without-password-prompt
# http://stackoverflow.com/questions/9743828/installing-percona-mysql-unattended-on-ubuntu
#

function install_mysql {
  # install percona, choice of better MySQL that works well in SSD
  # $1 - the mysql root password

  log "install_mysql: Installing MySQL..."
  if [ ! -n "$1" ]; then
    log "mysql_install: requires the root password as its first argument"
    return 1;
  fi

  export DEBIAN_FRONTEND=noninteractive
  apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A

  # echo "deb http://repo.percona.com/apt precise main" >> /etc/apt/sources.list
  # echo "deb-src http://repo.percona.com/apt precise main" >> /etc/apt/sources.list

  echo "deb http://repo.percona.com/apt trusty main" >> /etc/apt/sources.list
  echo "deb-src http://repo.percona.com/apt trusty main" >> /etc/apt/sources.list

  apt-get update

  # echo "percona-server-server-5.5 percona-server-server-5.5/root_password password $1" | debconf-set-selections
  # echo "percona-server-server-5.5 percona-server-server-5.5/root_password_again password $1" | debconf-set-selections

  apt-get -y install percona-server-server-5.5 percona-server-client-5.5 libmysqlclient-dev

  mysqladmin -u root password $1

  echo "Sleeping while MySQL starts up for the first time..."
  sleep 5
}

function install_mysql_client {
  log "install_mysql_client: Installing MySQL client..."

  export DEBIAN_FRONTEND=noninteractive
  apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A

  echo "deb http://repo.percona.com/apt trusty main" >> /etc/apt/sources.list
  echo "deb-src http://repo.percona.com/apt trusty main" >> /etc/apt/sources.list

  apt-get update

  apt-get -y install percona-server-client-5.5 libmysqlclient-dev

}

function create_mysql_database {
  # $1 - the mysql root password
  # $2 - the db name to create
  if [ ! -n "$1" ]; then
    log "mysql_create_database: requires the root pass as its first argument"
    return 1;
  fi
  if [ ! -n "$2" ]; then
    log "mysql_create_database: requires the name of the database as the second argument"
    return 1;
  fi
  log "Creating database $2..."
  echo "CREATE DATABASE $2 CHARACTER SET utf8 COLLATE utf8_general_ci;" | mysql -u root -p$1
}

function create_mysql_user {
  # $1 - the mysql root password
  # $2 - the user to create
  # $3 - their password
  if [ ! -n "$1" ]; then
    log "mysql_create_user: requires the root pass as its first argument"
    return 1;
  fi
  if [ ! -n "$2" ]; then
    log "mysql_create_user: requires username as the second argument"
    return 1;
  fi
  if [ ! -n "$3" ]; then
    log "mysql_create_user: requires a password as the third argument"
    return 1;
  fi
  log "Creating MySQL user $2..."
  echo "CREATE USER '$2'@'localhost' IDENTIFIED BY '$3';" | mysql -u root -p$1
}

function grant_mysql_user {
  # $1 - the mysql root password
  # $2 - the user to bestow privileges
  # $3 - the database
  if [ ! -n "$1" ]; then
    log "mysql_grant_user: requires the root pass as its first argument"
    return 1;
  fi
  if [ ! -n "$2" ]; then
    log "mysql_grant_user: requires username as the second argument"
    return 1;
  fi
  if [ ! -n "$3" ]; then
    log "mysql_grant_user: requires a database as the third argument"
    return 1;
  fi
  log "Granting MySQL user $2 all privileges to $3 database..."
  echo "GRANT ALL PRIVILEGES ON $3.* TO '$2'@'localhost';" | mysql -u root -p$1
  echo "FLUSH PRIVILEGES;" | mysql -u root -p$1
}

function backup_mysql
{
  if [ ! -n "$1" ]; then
    log "backup_mysql: requires the database user as its first argument"
    return 1;
  fi
  if [ ! -n "$2" ]; then
    log "backup_mysql) requires the database password as its second argument"
    return 1;
  fi
  if [ ! -n "$3" ]; then
    log "backup_mysql: requires the output file path as its third argument"
    return 1;
  fi
  local USER="$1"
  local PASS="$2"
  local BACKUP_DIR="$3"
  local DBNAMES="$4"

  fname=""
  if [ -n "$DBNAMES" ] ; then
    fname=$(echo "$DBNAMES" | sed 's/ /_/g')
    mysqldump --single-transaction --add-drop-table --add-drop-database -h localhost --user="$USER" --password="$PASS" --databases $DBNAMES > "/tmp/$fname-db.sql"
  else
    fname="all"
    mysqldump --single-transaction --add-drop-table --add-drop-database -h localhost --user="$USER" --password="$PASS" --all-databases  > "/tmp/$fname-db.sql"
  fi

  mkdir -p "$BACKUP_DIR"
  local curdir=$(pwd)
  cd /tmp
  rm -rf "$BACKUP_DIR/$fname-db.tar.gz"
  tar zcf "$BACKUP_DIR/$fname-db.tar.bz2" "$fname-db.sql"
  rm -rf "$fname-db.sql"
  cd "$curdir"
}

function restore_mysql
{
  if [ ! -n "$1" ]; then
    log "restore_mysql: requires the database user as its first argument"
    return 1;
  fi
  if [ ! -n "$2" ]; then
    log "restore_mysql) requires the database password as its second argument"
    return 1;
  fi
  if [ ! -n "$3" ]; then
    log "restore_mysql: requires the backup directory as its third argument"
    return 1;
  fi

  local USER="$1"
  local DB_PASSWORD="$2"
  local BACKUP_DIR="$3"

  rm -rf "/tmp/tmp.db" "/tmp/tmp.db.all.sql"
  mkdir "/tmp/tmp.db"

  db_zips=$(ls "$BACKUP_DIR/"*-db.tar.bz2)
  for dbz in $db_zips ; do
    tar -C "/tmp/tmp.db" -xjf "$dbz"
    cat /tmp/tmp.db/* >> "/tmp/tmp.db.all.sql"
    rm -rf /tmp/tmp.db/*
  done

  #ensure that current user (usually root) and debian-sys-maint have same password as before, and that they still have all permissions
  old_debian_pw=$(echo $(cat /etc/mysql/debian.cnf | grep password | sed 's/^.*=[\t ]*//g') | awk ' { print $1 } ')
  echo "USE mysql ;"                                                                            >> "/tmp/tmp.db.all.sql"
  echo "GRANT ALL ON *.* TO 'debian-sys-maint'@'localhost' ;"                                   >> "/tmp/tmp.db.all.sql"
  echo "GRANT ALL ON *.* TO '$USER'@'localhost' ;"                                              >> "/tmp/tmp.db.all.sql"
  echo "UPDATE user SET password=PASSWORD(\"$old_debian_pw\") WHERE User='debian-sys-maint' ;"  >> "/tmp/tmp.db.all.sql"
  echo "UPDATE user SET password=PASSWORD(\"$DB_PASSWORD\") WHERE User='$USER' ;"               >> "/tmp/tmp.db.all.sql"
  echo "FLUSH PRIVILEGES ;"                                                                     >> "/tmp/tmp.db.all.sql"

  mysql --user="$USER" --password="$DB_PASSWORD" < "/tmp/tmp.db.all.sql"
  rm -rf "/tmp/tmp.db" "/tmp/tmp.db.all.sql"

  touch /tmp/restart-mysql
}
