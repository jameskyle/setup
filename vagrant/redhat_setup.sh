#!/bin/bash
PUBKEY=https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub

rpm -ivh http://yum.puppetlabs.com/el/6/products/i386/puppetlabs-release-6-7.noarch.rpm

yum groupremove 'Dial-up Networking Support' \
                'Base' \
                'E-mail server' \
                            'Graphical Administration Tools' \
                'Hardware monitoring utilities' \
                            'Legacy UNIX compatibility' \
                'Networking Tools' \
                            'Performance Tools' \
                'Perl Support' -y

yum remove wireless-tools \
           gtk2 \
           libX11 \
           hicolor-icon-theme \
           avahi freetype \
           bitstream-vera-fonts -y

/usr/bin/yum upgrade -y
/usr/bin/yum install gcc make kernel-devel perl puppet -y

useradd -G adm vagrant
passwd vagrant

echo -e "NETWORKING=yes\nHOSTNAME=vagrant.virtual\n" > /etc/sysconfig/network

cat <<EOF > /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE="eth0"
BOOTPROTO="dhcp"
NM_CONTROLLED="yes"
ONBOOT="yes"
TYPE="Ethernet"
UUID="15b118e6-66d6-4caa-8214-9d32739ae93c"
EOF

mkdir -p /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
curl -L $PUBKEY > /home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant

cat <<EOF > /etc/sudoers
Defaults    !visiblepw
Defaults    always_set_home
Defaults    env_reset
Defaults    env_keep =  "COLORS DISPLAY HOSTNAME HISTSIZE INPUTRC KDEDIR"
Defaults    env_keep += "PATH LSCOLORS LC_CTYPE LC_MESSAGES XAUTHORITY"
Defaults    env_keep += "MAIL PS1 PS2 QTDIR USERNAME LANG LC_ADDRESS"
Defaults    env_keep += "LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT"
Defaults    env_keep += "LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE"
Defaults    env_keep += "LC_TIME LC_ALL LANGUAGE LINGUAS _XKB_CHARSET"
Defaults    secure_path = /sbin:/bin:/usr/sbin:/usr/bin

root    ALL=(ALL) NOPASSWD: ALL
vagrant ALL=(ALL)       NOPASSWD: ALL

#includedir /etc/sudoers.d
EOF

mount -t iso9660 /dev/cdrom /mnt
cd /tmp && tar xzf /mnt/VMwareTools-*.tar.gz  -C /tmp
cd vmware-tools-distrib
./vmware-install.pl --default

yum remove gcc make perl -y
yum clean headers packages dbcache expire-cache
rm -rf /tmp/*
rm /etc/udev/rules.d/70-persistent-net.rules
