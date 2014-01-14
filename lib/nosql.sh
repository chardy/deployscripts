#!/bin/bash

function install_mongodb 
{
  log "install_mongodb: Installing mongoDB..."
  # make sure no mongodb clients is installed
  sudo apt-get remove mongodb-clients
  
  # install mongodb from 10gen directly
  apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
  echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen" | tee -a /etc/apt/sources.list.d/10gen.list
  apt-get -y update
  apt-get -y install mongodb-10gen
  # /etc/mongodb.conf
}