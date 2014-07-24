define dns::zone (
  $soa = "${::fqdn}.",
  $soa_email = "root.${::fqdn}.",
  $serial = false,
  $zone_ttl = '604800',
  $zone_refresh = '604800',
  $zone_retry = '86400',
  $zone_expire = '2419200',
  $zone_minimum = '604800',
  $nameservers = [ $::fqdn ],
  $ip = undef,
  $rdns = true,
  $a = [],
  $cname = [],
  $mx = [],
  $txt = [],
  $reverse = false,
  $zone_type = 'master',
  $allow_transfer = [],
  $slave_masters = undef,
  $zone_notify = false,
  $ensure = present
) {

  validate_array($allow_transfer)

  $zone_serial = $serial ? {
    false   => inline_template('<%= Time.now.to_i %>'),
    default => $serial
  }

  $zone = $reverse ? {
    true    => "${name}.in-addr.arpa",
    default => $name
  }

  $zone_file = "/etc/bind/zones/db.${name}"

  if $ensure == absent {
    file { $zone_file:
      ensure => absent,
    }
  } else {
    # Zone Database
    concat { $zone_file:
      owner   => 'bind',
      group   => 'bind',
      mode    => '0644',
      require => [Class['concat::setup'], Class['dns::server']],
      notify  => Class['dns::server::service']
    }
    concat::fragment{"db.${name}.soa":
      target  => $zone_file,
      order   => 1,
      content => template("${module_name}/zone_file.erb")
    }
  }

  # Include Zone in named.conf.local
  concat::fragment{"named.conf.local.${name}.include":
    ensure  => $ensure,
    target  => '/etc/bind/named.conf.local',
    order   => 3,
    content => template("${module_name}/zone.erb")
  }

  # Shortcut: specify ip => '1.2.3.4' as a shortcut
  # method of creating an a record for the domain,
  # and a cname for www.domain pointing at the same
  # ip address.
  if $ip {
    dns::record::a { "$name:default_a_record":
      host => "${name}.",
      data => $ip,
      ptr => $rdns,
      zone => $name,
    }
    dns::record::cname { "$name:default_www_record":
      host => "www",
      data => "${name}.",
      zone => $name,
    }
  }

  $defaults = { 'zone' => $name }
  if !empty($a) {
    create_resources('dns::record::a', $a, $defaults)
  }
  if !empty($cname) {
    create_resources('dns::record::cname', $cname, $defaults)
  }
  if !empty($mx) {
    if is_hash($mx) {
      create_resources('dns::record::mx',$mx, $defaults)
    }
    else {
      dns::record::mx { "$name:default_mx_record":
        host => "${name}.",
        preference => 10,
        data => $mx,
        zone => $name,
      }
    }
  }
  if !empty($txt) {
    create_resources('dns::record::txt',$txt, $defaults)
  }
}
