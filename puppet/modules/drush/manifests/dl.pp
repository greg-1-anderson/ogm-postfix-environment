define drush::dl (
  $site_alias = $drush::defaults::site_alias,
  $options    = $drush::defaults::options,
  $arguments  = $drush::defaults::arguments,
  $drush_user = $drush::defaults::drush_user,
  $drush_home = $drush::defaults::drush_home,
  $log        = $drush::defaults::log
  ) {

  if $arguments { $real_args = $arguments }
  else { $real_args = "${name}" }

  drush::run {"drush-dl:${name}":
    command    => 'pm-download',
    site_alias => $real_alias,
    options    => $options,
    arguments  => $real_args,
    drush_user => $drush_user,
    drush_home => $drush_home,
    log        => $log,
  }

  if defined(Drush::Run["drush-en:${name}"]) {
    Drush::Run["drush-dl:${name}"] {
      before +> Exec["drush-en:${name}"],
    }
  }
}

