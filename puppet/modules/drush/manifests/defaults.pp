class drush::defaults {

  $version    = 'dev-master'
  $drush_user = 'root'
  $drush_home = '/root'
  $site_alias = ''
  $options    = ''
  $arguments  = ''
  $site_path  = false
  $log        = false
  $creates    = undef
  $paths      = [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', "$::composer::composer_home/vendor/bin" ]

}
