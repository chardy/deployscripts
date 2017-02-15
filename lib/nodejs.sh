#!/bin/bash

function install_nodejs {
  log "install_nodejs: Installing NodeJS..."
  apt-get -y install software-properties-common python-software-properties python g++ make
  # add-apt-repository -y ppa:chris-lea/node.js
  apt-get -o Acquire::ForceIPv4=true update
  apt-get -y install nodejs
  apt-get -y install npm
  npm install -g uglify-js
}
