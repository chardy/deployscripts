#!/bin/bash

function install_nginx
{
  log "install_nginx: Install nginx..."
  # apt-get -y install python-software-properties
  apt-get -y install software-properties-common
  apt-add-repository -y ppa:nginx/stable
  apt-get -o Acquire::ForceIPv4=true update
  apt-get -y install nginx 
  /etc/init.d/nginx start
  
}