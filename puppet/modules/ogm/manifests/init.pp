class ogm (
  $mail_user = 'ogm',
  $mail_users_group = 'ogm',
  $mail_user_id = 444,
  $mail_user_gid = 444,
  $root_user = 'root',
  $procmail_rules = undef,
  $download_cache_dir = '/tmp',
  $sites = undef,
) {
  group { $mail_users_group:
    ensure           => 'present',
    gid              => $mail_user_id,
  }

  package { [ "php-mail-mimedecode", "php5-imap", "libphp-phpmailer", ]:
    ensure => latest,
  }

  user { $mail_user:
    require          => Group[$mail_users_group],
    ensure           => 'present',
    comment          => 'og_mailinglist proxy user',
    gid              => $mail_user_gid,
    home             => "/home/$mail_user",
    password         => false,
    shell            => '/bin/false',
    uid              => $mail_user_id,
  }

  file { "/home/$mail_user":
    require          => User[$mail_user],
    ensure           => directory,
    owner            => $mail_user,
    group            => $mail_users_group,
    mode             => '0750',
  }

  file { "/home/$mail_user/bin":
    require          => User[$mail_user],
    ensure           => directory,
    owner            => $mail_user,
    group            => $mail_users_group,
    mode             => '0750',
  }

  procmail::conf { $mail_user:
    maildir          => "/home/$mail_user/mail",
    extra_vars       => {
      "DOMAIN" => "`formail -cXX-Original-To: | sed -e 's/^[^@]*@//'`",
    },
    rules            => $procmail_rules,
    fallthrough      => {
      comment => "Everything else goes to the ogm delivery script",
      action => "|$delivery_binary \$DOMAIN",
    },
    require          => File["/home/$mail_user"],
  }

  if $sites {
    $site_keys = keys($sites)
    $first_site_key = $site_keys[0]

    $drupal_root = $sites[$first_site_key]['drupal_path']
    $ogm_delivery_source = "$drupal_root/sites/all/modules/og_mailinglist/backends/postfix_og_mailinglist/og_mailinglist_postfix_transport.php"
    $delivery_binary = "/home/$mail_user/bin/deliver"
    $site_info = "/home/$mail_user/bin/site_info.php"

    file { $delivery_binary:
      ensure => present,
      source => $ogm_delivery_source,
      require => File["$drupal_root/sites/all/libraries"],
    }

    file { $site_info:
      ensure => file,
      owner => $mail_user,
      group => $mail_users_group,
      mode => '0644',
      content => template("ogm/site_info.php.erb"),
    }
    $defaults = {
      root_user => $root_user,
    }
    create_resources('ogm::configure_site', $sites, $defaults)
  }
}
