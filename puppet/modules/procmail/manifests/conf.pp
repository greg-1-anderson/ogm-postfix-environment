# == Type: procmail::conf
#
# Defined type to manage a user's ~/.procmailrc.
#
# === Parameters
#
# [*user*]
#   String, default value `$name`; name of user.
#
# [*rcpath*]
#   String, default value `/home/${name}/.procmailrc; full path to
#   the procmailrc.
#
# [*owner*]
#   String, default value `$name`; owner for `${rcpath}`.
#
# [*group*]
#   String, default value `$name`; group for `${rcpath}`.
#
# [*path*]
#   String, default value `$::path`; Full path to record as $PATH.
#
# [*maildir*]
#   String, default value `/home/${name}/Maildir`; value of `$MAILDIR`.
#
# [*default*]
#   String, default value `/var/mail/${name}`; value of `$DEFAULT`.
#
# [*extra_vars*]
#   Hash, default value `{}`; additional variables to write out.
#
# [*rules*]
#   Array, default value `[]`; array of hashes containing actual rules.
#   Valid fields are: `comment`, `flags`, `condition`, `action` and
#   `multi_action`.
#   All fields are a String, except for `multi_action` which is an array
#   which can be used for multiple action lines.
#   If `action` is ommitted, the following action line will be generated:
#   `$MAILDIR/value_of_comment_field`
#
# [*fallthrough*]
#   Hash, default value `{comment => 'Match every remaining mail.',
#   condition => '.*', action => '$MAILDIR/'}`; Fallthrough rule.
#
# === Examples
#
#  To create the following procmailrc:
#
#  PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11R6/bin:/usr/local/bin:/usr/local/sbin
#  MAILDIR=/home/jasper/Maildir
#  DEFAULT=/var/mail/jasper
#  LOCKFILE=/home/jasper/.lockmail
#
#  #
#  # spam spam spam
#  #
#  :0
#  * ^X-Spam-Status: Yes
#  $MAILDIR/Spam/
#
#  #
#  # Match every remaining mail.
#  #
#  :0
#  * .*
#  $MAILDIR/
#
#  Use a Hiera configuration such as:
#
#  procmail::configs:
#    'jasper':
#      extra_vars:
#        'lockfile': '/home/jasper/.lockmail'
#      rules:
#        - comment:   'spam spam spam'
#          condition: '^X-Spam-Status: Yes'
#          action:    '$MAILDIR/Spam/'
#
# === Authors
#
# Jasper Lievisse Adriaanse <jasper@humppa.nl>
#
# === Copyright
#
# Copyright 2014 Jasper Lievisse Adriaanse
#
define procmail::conf (
  $user        = $name,
  $rcpath      = "/home/${name}/.procmailrc",
  $owner       = $name,
  $group       = $name,
  $path        = $::path,
  $maildir     = "/home/${name}/Maildir",
  $default     = "/var/mail/${name}",
  $extra_vars  = {},
  $rules       = [],
  $fallthrough = {
    comment   => 'Match every remaining mail.',
    condition => '.*',
    action    => '$MAILDIR/'
  },
) {
  validate_absolute_path($rcpath)
  validate_absolute_path($maildir)
  validate_absolute_path($default)
  validate_array($rules)
  validate_hash($extra_vars)
  validate_hash($fallthrough)
  validate_string($user)
  validate_string($owner)
  validate_string($group)
  validate_string($maildir)
  validate_string($default)

  file { $rcpath:
    ensure  => file,
    owner   => $owner,
    group   => $group,
    mode    => '0644',
    content => template('procmail/procmailrc.erb'),
  }
}
