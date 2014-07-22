define drush::run (
  $command     = false,
  $site_alias  = $drush::defaults::site_alias,
  $options     = $drush::defaults::options,
  $arguments   = $drush::defaults::arguments,
  $site_path   = $drush::defaults::site_path,
  $drush_user  = $drush::defaults::drush_user,
  $drush_home  = $drush::defaults::drush_home,
  $log         = $drush::defaults::log,
  $installed   = $drush::defaults::installed,
  $creates     = $drush::defaults::creates,
  $paths       = $drush::defaults::paths,
  $timeout     = undef,
  $unless      = undef,
  $onlyif      = undef,
  $refreshonly = undef
  ) {

  if $log { $log_output = " >> ${log} 2>&1" }

  if $command { $real_command = $command }
  else { $real_command = $name}

  exec { "drush-run:${name}":
    command     => "drush ${site_alias} --yes ${options} ${real_command} ${arguments} ${log_output}",
    user        => $drush_user,
    group       => $drush_user,
    path        => $paths,
    environment => "HOME=${drush_home}",
    require     => Composer::Require['drush/drush'],
    cwd         => $site_path,
    creates     => $creates,
    timeout     => $timeout,
    unless      => $unless,
    onlyif      => $onlyif,
    refreshonly => $refreshonly,
  }
}
