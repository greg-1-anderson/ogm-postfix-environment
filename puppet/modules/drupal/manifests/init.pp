class drupal (
  $site_parent       = '/srv/www',
  $root_user         = 'www-admin',
  $webserver_user    = 'www-data',
  $password          = 'password',
  $sites             = [],
) {

  Database {
    require => Class['mysql::server'],
  }

  # Drupal needs php5-gd
  package { 'php5-gd':
  }

  apache::mod { 'php5': }

  if !empty($sites) {
    create_resources('drupal::site', $sites)
  }

  if ! defined(User["$root_user"]) and ($root_user != "vagrant") {

    group { "$root_user":
      ensure           => 'present',
      gid              => 888,
    }

    user { "$root_user":
      require          => Group["$root_user"],
      ensure           => 'present',
      comment          => 'web admin; owns files not writable by web server, etc.',
      gid              => 888,
      home             => "/srv/www",
      password         => false,
      shell            => '/bin/false',
      uid              => 888,
    }

  }

  file { '/srv':
    ensure => directory,
    mode => '0755',
  }

  file { '/srv/www':
    ensure => directory,
    owner => "$root_user",
    group => "$root_user",
    mode => '0755',
  }

  $bashrc = "/home/$root_user/.bashrc"
  $path_line = "PATH=\$PATH:$composer::composer_home/vendor/bin"

  exec { "set PATH":
    command => "/bin/sed -i -e '1i $path_line' $bashrc",
    unless => "/bin/grep -qFx '${path_line}' '${bashrc}'"
  }

}
