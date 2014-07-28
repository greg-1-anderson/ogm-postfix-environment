define ogm::configure_site(
  $drupal_path,
  $host = undef,
  $post_url = 'unused',
  $validation_string = 'unused',
  $root_user = 'root',
  $add_test_content = false,
) {
  $libraries_dir = "$drupal_path/sites/all/libraries"

  if $host { $site_url = $host }
  else { $site_url = $name }

  file { "$libraries_dir/phpmailer":
    source  => "/usr/share/php/libphp-phpmailer",
    recurse => true,
    require => [ Package["libphp-phpmailer"], File[$libraries_dir], ],
  }

  if $add_test_content {
    drush::en { "$site_url:og_example_prereqs":
      arguments => "views_content, entity_token, rules, panels, page_manager, message, message_notify, entityreference_prepopulate",
      options => "--root=/srv/www/$site_url/drupal",
      drush_user => $root_user,
      require => Drush::En["${site_url}:enable"],
    }

    drush::en { "$site_url:og_example":
      arguments => "og_example",
      options => "--root=/srv/www/$site_url/drupal",
      drush_user => $root_user,
      require => Drush::En["${site_url}:og_example_prereqs"],
    }

    drush::run { "$site_url:create_group":
      command => "ev",
      arguments => "'\$node = new stdClass();
\$node->type = \"group\";
node_object_prepare(\$node);
\$node->title = \"Example\";
\$node->language = LANGUAGE_NONE;
\$node->uid = 1;
\$node->group_email[\$node->language][] = array( \"value\" => \"example\", );
\$node->body[\$node->language][0] = array( \"value\" => \"This is an example group with a group mailing list.\", \"format\" => \"plain_text\", );
node_save(\$node); return \$node'",
      options => "--root=/srv/www/$site_url/drupal",
      drush_user => $root_user,
      require => Drush::En["${site_url}:og_example"],
    }
  }
}
