#!/bin/bash

function install_haproxy
{
  log "install_haproxy: "
  sudo apt-get -y install haproxy
}