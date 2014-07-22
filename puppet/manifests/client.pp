#
# Manifest for test client server
#
#
# To apply to an actual machine:
#
#   $ cd puppet
#   $ sudo puppet apply --modulepath=modules:/etc/puppet/modules manifests/client.pp
#
# Alternately (preferred), use Vagrant to create a virtual machine:
#
#   $ vagrant up client
#

Exec { path => "/usr/sbin/:/sbin:/usr/bin:/bin" }
File { owner => 'root', group => 'root' }

#
# Set up our /etc/hosts file.
#
# It is important for this to be set up correctly
# and consistently; otherwise, Kerberos won't work right.
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


Apache_httpd {
  extendedstatus => 'Off',
  # serveradmin    => 'greg.anderson@ricohsv.com',
}

