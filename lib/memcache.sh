#!/bin/bash

function install_memcache {
  log "install_memcache: Installing Memcache..."
  apt-get -y install memcached
}
