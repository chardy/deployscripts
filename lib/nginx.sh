#!/bin/bash

function install_nginx
{
  log "install_nginx: Install nginx..."
  apt-get -y install python-software-properties
  apt-add-repository -y ppa:nginx/stable
  apt-get -y update
  apt-get -y install nginx 
  /etc/init.d/nginx start
  
}