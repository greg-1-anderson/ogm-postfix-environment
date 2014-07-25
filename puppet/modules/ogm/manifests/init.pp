class ogm (
  $mail_user = 'ogm',
  $mail_users_group = 'ogm',
  $mail_user_id = 444,
  $mail_user_gid = 444,
  $procmail_rules = undef,
) {

  group { $mail_users_group:
    ensure           => 'present',
    gid              => $mail_user_id,
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
    mode             => 750,
  }

  procmail::conf { $mail_user:
    maildir          => "/home/$mail_user/mail",
    extra_vars       => {
      "DOMAIN" => "`formail -cXX-Original-To: | sed -e 's/^[^@]*@//'`",
    },
    rules            => $procmail_rules,
    fallthrough      => {
      comment => "Everything else goes to the ogm delivery script",
      action => "|/home/$mail_user/bin/deliver \$DOMAIN",
    },
    require          => File["/home/$mail_user"],
  }
}
