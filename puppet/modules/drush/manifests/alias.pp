define drush::alias (
  $aliasname = undef,
  $uri = undef,
  $root = undef,
  $ensure = present,
) {
  if !$aliasname {
    $aliasname_real = $name
  }
  else {
    $aliasname_real = $aliasname
  }

  file { "/etc/drush/${aliasname_real}.alias.drushrc.php":
    ensure  => $ensure,
    content => template('drush/alias.drushrc.php.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

}
