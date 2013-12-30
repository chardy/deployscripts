#!/bin/bash

#################################
# Security                      #
#################################

function set_basic_security {
  log "set_basic_security: Setting up basic security..."
  install_ufw
  basic_ufw_setup
  sshd_permit_root_login no
  sshd_password_authentication no
  sshd_pub_key_authentication yes
  /etc/init.d/ssh restart
}

function install_ufw {
  log "install_ufw: installing firewall"
  aptitude -y install ufw
}

function basic_ufw_setup {
  log "basic_ufw_setup:"
  # see https://help.ubuntu.com/community/UFW
  ufw logging on
  ufw default deny
  ufw allow ssh
  ufw allow http
  ufw allow https
  ufw allow ntp
  ufw enable
}

function security_logcheck {
  log "security_logcheck:"
  aptitude -y install logcheck logcheck-database
}

function sshd_edit_value {
    # $1 - param name
    # $2 - Yes/No
    VALUE=$2
    if [ "$VALUE" == "yes" ] || [ "$VALUE" == "no" ]; then
        sed -i "s/^#*\($1\).*/\1 $VALUE/" /etc/ssh/sshd_config
    fi
}

function sshd_permit_root_login {
    sshd_edit_value "PermitRootLogin" "$1"
}

function sshd_password_authentication {
    sshd_edit_value "PasswordAuthentication" "$1"
}

function sshd_pub_key_authentication {
    sshd_edit_value "PubkeyAuthentication" "$1"
}

function sshd_password_authentication {
    sshd_edit_value "PasswordAuthentication" "$1"
}
