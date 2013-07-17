#!/bin/bash

rpm -ivh http://yum.puppetlabs.com/el/6/products/i386/puppetlabs-release-6-7.noarch.rpm
yum install puppet -y

curl "https://raw.github.com/jameskyle/setup/master/setup.pp" -o /tmp/setup.pp

puppet apply /tmp/setup.pp

