define drush::vset (
  $site_alias  = $drush::defaults::site_alias,
  $options     = $drush::defaults::options,
  $variable    = undef,
  $value       = '1',
  $drush_user  = $drush::defaults::drush_user,
  $drush_home  = $drush::defaults::drush_home,
  $log         = $drush::defaults::log,
  $refreshonly = false,
  ) {

  if $variable { $real_variable = $variable }
  else { $real_variable = $name }

  drush::run {"drush-vset:${name}":
    command     => 'variable-set',
    site_alias  => $site_alias,
    options     => "$options --exact=1",
    arguments   => "$real_variable $value",
    drush_user  => $drush_user,
    drush_home  => $drush_home,
    refreshonly => $refreshonly,
    log         => $log,
  }
}
