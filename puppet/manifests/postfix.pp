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

Exec { path => "/usr/sbin/:/sbin:/usr/bin:/bin" }
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

package { 'procmail': ensure => installed }

# Look up the domain records defined for
# this host.  If not empty, then configure
# a DNS server.
$domain_records = hiera("domain_records", [])
if !empty($domain_records) {
  include dns::server

  $dns_zones = hiera("dns_zones", [])
  create_resources('dns::zone',$dns_zones)
  create_resources('dns::record::a',$domain_records)
  $mx_records = hiera("mx_records", [])
  if !empty($mx_records) {
    create_resources('dns::record::mx',$mx_records)
  }
  $txt_records = hiera("txt_records", [])
  if !empty($txt_records) {
    create_resources('dns::record::txt',$txt_records)
  }
}

group { 'ogm':
  ensure           => 'present',
  gid              => 444,
}

file { '/home/ogm':
  require          => User['ogm'],
  ensure           => directory,
  owner            => 'ogm',
  group            => 'ogm',
  mode             => 750,
}

file { '/home/ogm/.procmailrc':
  require          => User['ogm'],
  ensure           => file,
  content          => "MAILDIR = mail
LOGFILE = proc-log
SHELL=/bin/sh

# Pull out the domain from the X-Original-To header
DOMAIN=`formail -cXX-Original-To: | sed -e 's/^[^@]*@//'`

:0
|/home/ogm/bin/deliver $DOMAIN
",
  owner            => 'ogm',
  group            => 'ogm',
  mode             => 700,
}

user { 'ogm':
  require          => Group['ogm'],
  ensure           => 'present',
  comment          => 'og_mailinglist proxy user',
  gid              => 444,
  home             => "/home/ogm",
  password         => false,
  shell            => '/bin/false',
  uid              => 444,
}

$apache_php_ini = hiera("php::mod_php5::inifile", "/etc/php.ini")
$apache_php_ini_parent = dirname($apache_php_ini)

file { $apache_php_ini_parent:
  ensure => directory,
  recurse => true,
  before => Php::Ini[$apache_php_ini],
}

php::ini { $apache_php_ini:
  memory_limit => '256M',
}

$cli_php_ini = hiera("php::cli::inifile", "/etc/cli.ini")
$cli_php_ini_parent = dirname($cli_php_ini)

file { $cli_php_ini_parent:
  ensure => directory,
  recurse => true,
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

hiera_include('classes')
