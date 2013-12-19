#!/bin/bash

function install_nginx
{
  log "install_nginx() Install nginx..."
  apt-get -y install nginx 
}