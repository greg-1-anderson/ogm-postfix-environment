define drupal::site (
  $projects          = '',
  $modules           = '',
  $site_parent       = $::drupal::site_parent,
  $root_user         = $::drupal::root_user,
  $webserver_user    = $::drupal::webserver_user,
  $password          = $::drupal::password,
) {
  $site_url = $name
  $joined_site_url = join(split($site_url, '.'))
  $db_name = "${joined_site_url}db"
  $db_url = "mysql://www-data:password@localhost/${$db_name}"

  file { "/srv/www/$site_url":
    ensure => directory,
    owner => $root_user,
    group => $root_user,
    mode => '0750',
  }

  drush::dl { "${site_url}":
    arguments => 'drupal',
    options => "--destination=/srv/www/$site_url --drupal-project-rename=drupal",
    drush_user => $root_user,
    creates => "/srv/www/$site_url/drupal",
    require => File["/srv/www/$site_url"],
  }

  drush::dl { "$site_url:projects":
    arguments => $projects,
    options => "--root=/srv/www/$site_url/drupal",
    drush_user => $root_user,
    require => Drush::Dl["${site_url}"],
  }

  mysql::db { "$db_name":
    user     => $webserver_user,
    password => $password,
    host     => 'localhost',
    grant    => ['all'],
  }

  exec { "${site_url}:permissions":
    command => "mkdir -p /srv/www/$site_url/drupal/sites/default/files && chgrp -R www-data /srv/www/$site_url && chmod -R g+w /srv/www/$site_url/drupal/sites/default/files",
    require => [ Drush::Dl["${site_url}"], Drush::Dl["$site_url:projects"], ],
  }

  drush::run { "${site_url}:site-install":
    command => "site-install",
    options => "--root=/srv/www/$site_url/drupal --db-su=root --db-su-pw=$password --db-url=$db_url --site-name='OG Mailinglist Server'",
    require => [ Package['php5-gd'], Mysql::Db["$db_name"], Exec["${site_url}:permissions"], ],
  }

  drush::en { '$site_url:modules':
    arguments => $modules,
    options => "--root=/srv/www/$site_url/drupal",
    drush_user => $root_user,
    require => Drush::Run["${site_url}:site-install"],
  }

  apache::vhost { $site_url:
    port    => '80',
    priority => 5,
    docroot => "/srv/www/$site_url/drupal",
    notify => Service['apache2'],
    require => Drush::Run["${site_url}:site-install"],
  }
}
