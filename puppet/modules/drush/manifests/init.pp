class drush (
  $version          = $drush::params::version,
  $prefer_source    = false,
  ) inherits drush::params {

  composer::require { 'install-drush':
    package => "drush/drush",
    version => "$version",
  }
}
