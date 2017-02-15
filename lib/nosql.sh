#!/bin/bash

function install_mongodb 
{
  log "install_mongodb: Installing mongoDB..."
  # make sure no mongodb clients is installed
  # sudo apt-get remove mongodb-clients
  
  # install mongodb from 10gen directly
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
  echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
  apt-get -o Acquire::ForceIPv4=true update
  apt-get -y install mongodb-org
  cat > /etc/systemd/system/mongodb.service << EOF
[Unit]
Description=High-performance, schema-free document-oriented database
After=network.target

[Service]
User=mongodb
ExecStart=/usr/bin/mongod --quiet --config /etc/mongod.conf

[Install]
WantedBy=multi-user.target

EOF

  systemctl enable mongod
  systemctl daemon-reload
  systemctl start mongodb
}