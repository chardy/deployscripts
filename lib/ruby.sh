#!/bin/bash

######################
# Ruby/RubyGem/Rails #
######################

function install_ruby
{
  log "install_ruby: Installing standard ruby..."
  aptitude -y install ruby1.9.1 ruby1.9.1-dev rubygems1.9.1 irb1.9.1 ri1.9.1 rdoc1.9.1 libopenssl-ruby1.9.1 libssl-dev zlib1g-dev libpcre3-dev
  create_gemrc
}

function install_ruby_ng
{
  log "install_ruby_ng: Installing Ruby Next Generation (Brightbox)"
  # http://brightbox.com/docs/ruby/ubuntu/

  apt-get -y install python-software-properties
  apt-add-repository -y ppa:brightbox/ruby-ng
  apt-get update
  apt-get -y install ruby1.9.3 ruby-switch
  ruby-switch --set ruby1.9.1
  create_gemrc
  # update_rubygems
}

function install_ruby_rbenv
{
  log "install_ruby_rbenv: Installing rbenv ruby"
  
  su - $USER_NAME -c "curl -L https://raw.github.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash"
  su - $USER_NAME -c "echo 'export RBENV_ROOT="${HOME}/.rbenv"' >> ~/.bashrc"
  su - $USER_NAME -c "echo 'if [ -d "${RBENV_ROOT}" ]; then' >> ~/.bashrc"
  su - $USER_NAME -c "echo '  export PATH="${RBENV_ROOT}/bin:${PATH}"' >> ~/.bashrc"
  su - $USER_NAME -c "echo '  eval "$(rbenv init -)"' >> ~/.bashrc"
  su - $USER_NAME -c "echo 'fi' >> ~/.bashrc"
  su - $USER_NAME -c "source ~/.bashrc"
  su - $USER_NAME -c "rbenv bootstrap-ubuntu-12-04"
  su - $USER_NAME -c "rbenv install 1.9.3-p484"
  su - $USER_NAME -c "rbenv global 1.9.3-p484"
}

function create_gemrc {
  log "create_gemrc: Setting up .gemrc file"
  cat > ~/.gemrc << EOF
verbose: true
bulk_treshold: 1000
install: --no-ri --no-rdoc --env-shebang
benchmark: false
backtrace: false
update: --no-ri --no-rdoc --env-shebang
update_sources: true
EOF
  USER_HOME=$(user_home "$USER_NAME")
  cp ~/.gemrc $USER_HOME
  chown $USER_NAME:$USER_NAME $USER_HOME/.gemrc
}

function update_rubygems {
  log "update_rubygems:"
  gem update --system
}

function install_bundler {
  log "install_bundler: Installing bundler..."
  gem install bundler
}

function install_rbenv_bundler {
  log "install_bundler: Installing bundler..."
  su - $USER_NAME -c "gem install bundler"
}

function install_gems {
  log "install_gems: installing additional essential gems..."
  gem install rails capistrano rmagick curb tzinfo unicorn rack sinatra mysql2 pg nokogiri
}

function install_rbenv_gems {
  log "install_gems: installing additional essential gems for rbenv build..."
  su - $USER_NAME -c "gem install rails capistrano rmagick curb tzinfo unicorn rack sinatra mysql2 pg nokogiri"
}

function install_monit {
  apt-get -y install monit
}
