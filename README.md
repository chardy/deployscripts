DeployScript is a set of bash shell scripts to make the installation easy for applications deployment.

Requirement: Ubuntu 12.04 LTS

How to
------
git clone https://github.com/chardy/deployscripts.git
cd deployscripts
./install essentials

follow by: (eg. db)
./install database

Please check the recipes content first, conf function might need to be changed

Recipes
-------
* essentials - installs a current and secure basic box with some essential packages, this recipes must be run at initial
* app - installs a Ruby, NodeJS ready box based on Basic with production ready capabilities
* database - install database RDBMS like mysql (percona) and postgres
* lb - install load balancer, in this case, I use nginx or ha-proxy
* nosql - install NoSQL database like mongo

Libs
----
A collection of individual bash shell scripts.

Goals
-----
To create simple and straight forward deployment script, we only need to run this script in initial stage when we are preparing our Box. Chef and Puppet is complicated and often I spend a lot of time figuring the dependency when writing the recipes. So, back to basic, shell script :-)

TODO
----
* creating conf for mysql (my.cnf), nginx.conf, haproxy.conf
* monit.sh, redis.sh, memcache.sh
* many more...
