#!/bin/bash


SHA="f804697ee81f057ea69716e2fe7d35dd4f6db97e"
wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb
dpkg -i puppetlabs-release-precise.deb
apt-get update

apt-get install puppet -y

curl "https://gist.github.com/jameskyle/6017819/raw/${SHA}/setup.pp" -o /tmp/setup.pp

puppet apply /tmp/setup.pp

