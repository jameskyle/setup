$user = 'jkyle'
$authorized_key_comment = "jkyle@Air-Protoss.local"
$authorized_key_type = "ssh-rsa"
$authorized_key = "AAAAB3NzaC1yc2EAAAADAQABAAABAQC/KTbhKZEL19BhHovHamtMLJNv85nC1GKpRvp3PAI1xEvze63cTwC43HqbvBJEWIyMQYTZDfHxujJSxy2KMvwU96fVhxQbA+SieMskxjlujXiU0WAwIlzo+5dZhgdMwTX0YUD5NwkVoELG/wAFiOZ0f4gbjOK8ossHGGNWGYl5b/pFbzb4ih2y+3LM80s8KBj3CF5bJS57fkhiYAwPIyWnqMgcaVsAcfL7XXPZsabzH9eVMmngfwimMkn0wzujuGrtw+bFGoEfDyD2HeY/bEn7eoBO9AMiyR25a5fIYvniRiOKCNkzSQeZfj5S45+SS82YZc7qtuZzRPmNyVkgFDLx"

package {['zsh','git']: }

$groups = $operatingsystem ? {
  /^(RedHat|Centos)$/ => ['adm', 'wheel'],
  /^(Debian|Ubuntu)$/ => ['adm', 'sudo'],
}

user { $user:
  ensure      => present,
  uid         => 5000,
  gid         => 5000,
  groups      => $groups,
  shell       => '/bin/zsh',
  home        => "/home/$user",
  managehome  => true,
  password    => '*',
  require     => Group[$user],
}

group {$user: gid => 5000 }
ssh_authorized_key {$authorized_key_comment:
  user    => $user,
  ensure  => present,
  type    => $authorized_key_type,
  key     => $authorized_key,
  require => User[$user],
}

file {"/etc/sudoers.d/jkyle":
  mode => 0440,
  owner => root,
  group => root,
  content => "jkyle ALL = (ALL) NOPASSWD: ALL",
}

file {'/tmp/setup.sh':
  mode     => 0755,
  owner    => root,
  group    => root,
  content  => "
#!/bin/bash
home=\"/home/${user}\"
rc=\"\${home}/.zprezto/runcoms\"

/usr/bin/git clone https://bitbucket.org/jkyle/prezto.git .zprezto 
cd .zprezto
/usr/bin/git checkout -b develop origin/develop
/usr/bin/git submodule init
/usr/bin/git submodule update

ln -sf \${rc}/zprezto    \${home}/.zprezto
ln -sf \${rc}/zlogin     \${home}/.zlogin
ln -sf \${rc}/zlogout    \${home}/.zlogout
ln -sf \${rc}/zpreztorc  \${home}/.zpreztorc
ln -sf \${rc}/zprofile   \${home}/.zprofile
ln -sf \${rc}/zshenv     \${home}/.zshenv
ln -sf \${rc}/zshrc      \${home}/.zshrc
",
}

exec {"setup-home":
  cwd      => "/home/${user}",
  command  => "/tmp/setup.sh",
  creates  => "/home/${user}/.zprezto",
  user     => $user,
  provider => "shell",
  require  => [Package['git'], File['/tmp/setup.sh'], User[$user]],
}

exec {'get-devstack':
  cwd     => "/home/${user}",
  creates => "/home/${user}/devstack",
  user    => $user,
  command => "/usr/bin/git clone https://github.com/openstack-dev/devstack.git",
  require => [Package['git'], User[$user]],
}

file {"/home/${user}/devstack/localrc":
  mode    => 0644,
  owner   => $user,
  group   => $user,
  content => "# vim: set ft=sh
disable_service n-net
enable_service q-svc
enable_service q-agt
enable_service q-dhcp
enable_service q-l3
enable_service q-meta
enable_service quantum
# Optional, to enable tempest configuration as part of devstack
enable_service tempest
DATABASE_PASSWORD=demo
RABBIT_PASSWORD=demo
SERVICE_TOKEN=demo
SERVICE_PASSWORD=demo
ADMIN_PASSWORD=demo
",
  require => Exec['get-devstack'],
}

file {"/home/${user}/.dput.cf":
  mode    => 644,
  owner   => $user,
  group   => $user,
  content => "
  [atheme]
  fqdn = ppa.launchpad.net
  method = sftp
  incoming = ~jkyle/atheme/ubuntu/
  login = jkyle
  "
  require => User[$user]
}
