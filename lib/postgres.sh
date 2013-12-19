#!/bin/bash

function install_postgresql
{
  log "install_postgresql() Installing postgresql..."
  apt-add-repository ppa:pitti/postgresql
  apt-get -y update
  aptitude -y install postgresql postgresql-contrib postgresql-dev postgresql-client libpq-dev
  pg_conf=$(find /etc/ -name "pg_hba.conf" | head -n 1)
  sed -i -e  's/^.*local.*all.*all.*$/local\tall\tall\tmd5/g'  $pg_conf
  /etc/init.d/postgresql restart
}

function postgresql_create_user
{
  # $1 - the user to create
  # $2 - their password
  # $3 - allow user to create db?
  if [ -z "$1" ] ; then
    echo "postgresql_create_user() requires the username as its first argument"
    return 1;
  fi
  if [ -z "$2" ] ; then
    echo "postgresql_create_user() requires the user password to set as the second argument"
    return 1;
  fi
  echo "CREATE ROLE $1 WITH LOGIN ENCRYPTED PASSWORD '$2';" | sudo -u postgres psql

  if [ -n "$3" ] ; then
    if [ "$3" = "1" ] ; then
      echo "ALTER ROLE $1 WITH CREATEDB;" | sudo -u postgres psql
    fi
  fi
}

function postgresql_grant_user
{
  # $1 - the user to bestow privileges
  # $2 - the database

  if [ -z "$1" ] ; then
    echo "postgresql_grant_user() requires username as the first argument"
    return 1;
  fi
  if [ -z "$2" ] ; then
    echo "postgresql_grant_user() requires a database as the second argument"
    return 1;
  fi
  echo "GRANT ALL PRIVILEGES ON DATABASE $2 TO $1 ;" | sudo -u postgres psql

}

function postgresql_create_database
{
  # $1 - the db name to create

  if [ -z "$1" ] ; then
    echo "postgresql_create_database() requires the name of the database as the first argument"
    return 1;
  fi

  sudo -u postgres createdb --owner=postgres $1
}

function backup_postgresql
{
  if [ -z "$1" ] ; then
    echo "backup_postgresql() requires the backup directory as its first argument"
    return 1;
  fi

  local BACKUP_DIR="$1"
  mkdir -p "$BACKUP_DIR"

  sudo -u postgres pg_dumpall >/tmp/all-db-postgres.sql
  local curdir=$(pwd)
  cd /tmp
  rm -rf "$BACKUP_DIR/all-db-postgres.tar.gz"
  tar zcf "$BACKUP_DIR/all-db-postgres.tar.gz" "all-db-postgres.sql"
  rm -rf "all-db-postgres.sql"
  cd "$curdir"
}

function restore_postgresql
{
  if [ -z "$1" ] ; then
    echo "restore_postgresql() requires the backup directory as its first argument"
    return 1;
  fi

  local BACKUP_DIR="$1"

  if [ -e "$BACKUP_DIR/all-db-postgres.tar.bz2" ] ; then
    rm -rf /tmp/tmp.db
    mkdir /tmp/tmp.db
    tar -C "/tmp/tmp.db" -xjf "$BACKUP_DIR/all-db-postgres.tar.bz2"
    if [ -e /tmp/tmp.db/all-db-postgres.sql ] ; then
      cat /tmp/tmp.db/all-db-postgres.sql | sudo -u postgres psql
    fi
    rm -rf /tmp/tmp.db
  fi
}
