# Question: where should we install global composer commands?
# /root/.composer is not good; we do not want to add +x to /root.
# For that matter, we don't really want to require +x on any /home
# directory, nor do we want to stipulate that there must be a particular
# user who 'owns' all of the composer components.
#
# How about /usr/local/composer/vendor/bin, then?
define composer::require (
  $package,
  $version
) {
  include composer

  file { '/etc/profile.d/composerglobalpath.sh':
    mode => 0755,
    content => 'PATH=$PATH:/usr/local/composer/vendor/bin',
  }

  exec { 'create-composer-home':
    command => 'mkdir -p /usr/local/composer',
    require => File['/etc/profile.d/composerglobalpath.sh'],
  }

  exec { $title:
    command => "composer global require $package:$version",
    environment => ["COMPOSER_HOME=/usr/local/composer"],
    require => [ Exec['composer-fix-permissions'], Exec['create-composer-home'], ],
  }
}
