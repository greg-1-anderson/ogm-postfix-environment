class drupal (
  $site_url          = 'example.com',
  $projects          = '',
  $modules           = '',
  $site_parent       = '/srv/www',
  $root_user         = 'www-admin',
  $webserver_user    = 'www-data',
  $password          = 'password',
) {

  file { "/srv/www/$site_url":
    ensure => directory,
    owner => $root_user,
    group => $root_user,
    mode => '0750',
  }

  drush::dl { 'drupal':
    options => "--destination=/srv/www/$site_url --drupal-project-rename=drupal",
    drush_user => $root_user,
    creates => "/srv/www/$site_url/drupal",
    require => File["/srv/www/$site_url"],
  }

  drush::dl { "$site_url:projects":
    arguments => $projects,
    options => "--root=/srv/www/$site_url/drupal",
    drush_user => $root_user,
    require => Drush::Dl['drupal'],
  }

  Database {
    require => Class['mysql::server'],
  }

  mysql::db { 'drupaldb':
    user     => $webserver_user,
    password => $password,
    host     => 'localhost',
    grant    => ['all'],
  }

  # Drupal needs php5-gd
  package { 'php5-gd':
  }

  exec { 'drupal-permissions':
    command => "mkdir -p /srv/www/$site_url/drupal/sites/default/files && chgrp -R www-data /srv/www/$site_url && chmod -R g+w /srv/www/$site_url/drupal/sites/default/files",
    require => [ Drush::Dl['drupal'], Drush::Dl["$site_url:projects"], ],
  }

  drush::run { 'site-install':
    options => "--root=/srv/www/$site_url/drupal --db-su=root --db-su-pw=$password --db-url=mysql://www-data:password@localhost/drupaldb --site-name='OG Mailinglist Server'",
    require => [ Package['php5-gd'], Mysql::Db['drupaldb'], Exec['drupal-permissions'], ],
  }

  drush::en { '$site_url:modules':
    options => "--root=/srv/www/$site_url/drupal",
    drush_user => $root_user,
    require => Drush::Run['site-install'],
  }

  apache::vhost { $site_url:
    port    => '80',
    priority => 5,
    docroot => "/srv/www/$site_url/drupal",
    notify => Service['apache2'],
    require => Drush::Run['site-install'],
  }

  apache::mod { 'php5': }

}
