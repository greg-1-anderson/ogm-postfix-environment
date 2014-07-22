class drush::defaults {

  $version    = 'dev-master'
  $drush_user = 'root'
  $drush_home = '/root'
  $site_alias = ''
  $options    = ''
  $arguments  = ''
  $site_path  = undef
  $log        = undef
  $creates    = undef
  $paths      = [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', "$::composer::composer_home/vendor/bin" ]

}
