#!/bin/bash
set -ex

if ! `which puppet` 2>&1 > /dev/null;then
    codename=`lsb_release -c -s`
    apt-get autoremove --purge -y
    apt-get update
    curl -O http://apt.puppetlabs.com/puppetlabs-release-${codename}.deb
    dpkg -i puppetlabs-release-${codename}.deb
    apt-get update
    apt-get dist-upgrade -y
    apt-get install puppet -y
fi

curl "https://raw.githubusercontent.com/jameskyle/setup/master/setup.pp" -o /tmp/setup.pp

puppet apply /tmp/setup.pp

