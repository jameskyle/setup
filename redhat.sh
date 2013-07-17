#!/bin/bash

SHA="f804697ee81f057ea69716e2fe7d35dd4f6db97e"
rpm -ivh http://yum.puppetlabs.com/el/6/products/i386/puppetlabs-release-6-7.noarch.rpm
yum install puppet -y

curl "https://gist.github.com/jameskyle/6017819/raw/${SHA}/setup.pp" -o /tmp/setup.pp

puppet apply /tmp/setup.pp

