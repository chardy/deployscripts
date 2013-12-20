#!/bin/bash

function install_haproxy
{
  log "install_haproxy: "
  apt-get -y install haproxy
}