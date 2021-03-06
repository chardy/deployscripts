#!/bin/bash

###########################################################
# utilitary functions
###########################################################

function log {
  if [ ! -n "$1" ]; then
    log "log: requires text string as its argument"
    return 1;
  fi
  echo "`date '+%D %T'` -  $1" >> $LOG_FILE
  echo "`date '+%D %T'` -  $1"
}

function ask {
  if [ ! -n "$1" ]; then
    log "ask: requires a question to ask"
    return 1;
  fi
  read -p "$1 " ANSWER
  echo "$ANSWER"
}

function upgrade_system {
  log "upgrade_system: Upgrading System..."
  apt-get -o Acquire::ForceIPv4=true update
  apt-get -y install aptitude
  aptitude -y full-upgrade
}

function make_sure_no_apache {
  log "make_sure_no_apache: Need to make sure apache is not running, some Cloud provider install apache by default..."
  apt-get -y purge apache2 apache2-utils apache2.2-bin apache2-common
  apt-get autoremove --purge
}

function install_basics {
  log "install_essentials: Installing Essentials..."
  apt-get -y install autoconf automake bash-completion bison build-essential curl dnsutils debconf-utils freetds-bin freetds-dev git-core less libc6-dev libcurl3 libcurl3-gnutls libcurl4-openssl-dev libpcre3-dev libreadline-dev libreadline6 libreadline6-dev libsqlite3-0 libsqlite3-dev libssl-dev libsvn-dev libtool libxml2 libxml2-dev libxslt1-dev libyaml-dev locate libncurses5-dev openssh-server openssl rsync sqlite-doc sqlite3 subversion subversion-tools sudo tdsodbc unzip vim wget whois zlib1g zlib1g-dev 

}

function update_locale_en_US_UTF_8 {
  log "update_locale_en_US_UTF_8: Updating locale to en_US.UTF-8..."
  locale-gen en_US.UTF-8
  dpkg-reconfigure locales -f noninteractive
  update-locale LANG=en_US.UTF-8
  echo "UTC" > /etc/timezone
  dpkg-reconfigure -f noninteractive tzdata
}

function install_ntp {
  apt-get -y install ntp
  service ntp restart
}

function install_java {
  log "install_java: Installing Java..."
  apt-get -y install default-jdk
}

function additional_installs {
  log "additional_installs: Installing additionals: "
  apt-get -y install libcroco-tools libmagickwand-dev libmagickcore-dev libmagickcore-extra libgraphviz-dev libgvc6 imagemagick webp mongodb-clients graphicsmagick libgraphicsmagick1-dev
}
