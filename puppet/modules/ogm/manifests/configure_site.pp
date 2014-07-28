define ogm::configure_site(
  $drupal_path,
  $host = 'default',
  $post_url = 'unused',
  $validation_string = 'unused',
) {
  $libraries_dir = "$drupal_path/sites/all/libraries"

  file { "$libraries_dir/phpmailer":
    source  => "/usr/share/php/libphp-phpmailer",
    recurse => true,
    require => [ Package["libphp-phpmailer"], File[$libraries_dir], ],
  }
}
