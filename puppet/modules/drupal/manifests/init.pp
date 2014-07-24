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

}
