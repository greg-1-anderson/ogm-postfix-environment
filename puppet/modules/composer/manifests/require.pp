# Question: where should we install global composer commands?
# /root/.composer is not good; we do not want to add +x to /root.
# For that matter, we don't really want to require +x on any /home
# directory, nor do we want to stipulate that there must be a particular
# user who 'owns' all of the composer components.
#
# How about /usr/local/composer/vendor/bin, then?
define composer::require (
  $version = 'dev-master',
  $home = $::composer::composer_home,
) {
  include composer

  exec { $title:
    command      => "composer global require $title:$version",
    path         => '/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin',
    environment  => ["COMPOSER_HOME=$home"],
    require      => [ Exec['composer-fix-permissions'], Exec['create-composer-home'], ],
  }
}
