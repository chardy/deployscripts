#!/bin/bash

function install_nodejs {
  log "install_nodejs: Installing NodeJS..."
  apt-get -y install software-properties-common python-software-properties python g++ make
  add-apt-repository -y ppa:chris-lea/node.js
  apt-get -y update
  apt-get -y install nodejs
  npm install -g uglify-js@1
}
