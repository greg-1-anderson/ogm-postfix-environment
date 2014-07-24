class ogm (
  $mail_user = 'ogm',
  $mail_users_group = 'ogm',
  $mail_user_id = 444,
  $mail_user_gid = 444,
) {

  package { 'procmail': ensure => installed }

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

  file { "/home/$mail_user/.procmailrc":
    require          => User[$mail_user],
    ensure           => file,
    content          => "MAILDIR = mail
LOGFILE = proc-log
SHELL=/bin/sh

# Pull out the domain from the X-Original-To header
DOMAIN=`formail -cXX-Original-To: | sed -e 's/^[^@]*@//'`

# Send every message to the ogm deliver script
:0
|/home/$mail_user/bin/deliver $DOMAIN
",
    owner            => $mail_user,
    group            => $mail_users_group,
    mode             => 700,
  }

}
