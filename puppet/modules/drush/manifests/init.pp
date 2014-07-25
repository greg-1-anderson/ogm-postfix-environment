class drush (
  $version          = $drush::defaults::version,
  $prefer_source    = undef,
  ) inherits drush::defaults {

  composer::require { 'drush/drush':
    version => "$version",
  }

  file { '/etc/drush':
    ensure => directory,
  }
}
