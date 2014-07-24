#
# Manifest for Postfix server
#
#
# To apply to an actual machine:
#
#   $ cd puppet
#   $ sudo puppet apply --modulepath=modules:/etc/puppet/modules manifests/postfix.pp
#
# Alternately (preferred), use Vagrant to create a virtual machine:
#
#   $ vagrant up postfix
#

Exec { path => "/usr/sbin/:/sbin:/usr/bin:/bin:/usr/local/bin" }
File { owner => 'root', group => 'root' }

#
# Set up our /etc/hosts file.
#
# Puppet provides $fqdn and $ip_address for us.
#
host { "$::fqdn":
    ip => "$::ip_address",
    host_aliases => ["$::hostname",'localhost']
}
file { 'hostname':
  content => "$hostname",
  ensure => file,
  path => '/etc/hostname',
  mode => '0644',
}
exec { "set-hostname":
  command => "/bin/hostname -F /etc/hostname",
  require => File['hostname'],
}

# We must always run apt-get update before any Package rule
exec { "apt-update":
    command => "/usr/bin/apt-get update",
}
Exec["apt-update"] -> Package <| |>

$apache_php_ini = hiera("php::mod_php5::inifile", "/etc/php.ini")
$apache_php_ini_parent = dirname($apache_php_ini)

exec { "mkdir -p $apache_php_ini_parent":
  before => Php::Ini[$apache_php_ini],
}

php::ini { $apache_php_ini:
  memory_limit => '256M',
}

$cli_php_ini = hiera("php::cli::inifile", "/etc/cli.ini")
$cli_php_ini_parent = dirname($cli_php_ini)

exec { "mkdir -p $cli_php_ini_parent":
  before => Php::Ini[$cli_php_ini],
}

php::ini { $cli_php_ini:
  memory_limit => '512M',
}

# For php 5.4 on Ubuntu 12.04:
#   add-apt-repository ppa:ondrej/php5-oldstable
# For php 5.5 on Ubuntu 12.04:
#   add-apt-repository ppa:ondrej/php5
package { 'python-software-properties':
}
exec { "php-upgrade":
    command => "/usr/bin/add-apt-repository ppa:ondrej/php5-oldstable; /usr/bin/apt-get update",
    require => Package['python-software-properties'],
}
Exec["php-upgrade"] -> Package['php5']

group { 'www-admin':
  ensure           => 'present',
  gid              => 888,
}

user { 'www-admin':
  require          => Group['www-admin'],
  ensure           => 'present',
  comment          => 'web admin; owns files not writable by web server, etc.',
  gid              => 888,
  home             => "/srv/www",
  password         => false,
  shell            => '/bin/false',
  uid              => 888,
}


file { '/srv':
  ensure => directory,
  mode => '0755',
}

file { '/srv/www':
  ensure => directory,
  owner => 'www-admin',
  group => 'www-admin',
  mode => '0755',
}


hiera_include('classes')
