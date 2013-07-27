#!/bin/bash


wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb
dpkg -i puppetlabs-release-precise.deb
apt-get update
apt-get dist-upgrade -y
apt-get install puppet -y

curl "https://raw.github.com/jameskyle/setup/master/setup.pp" -o /tmp/setup.pp

puppet apply /tmp/setup.pp

