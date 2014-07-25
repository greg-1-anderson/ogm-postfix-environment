# == Class: procmail
#
# Module to install procmail and manage user's .procmailrc
#
# === Parameters
#
# [*package*]
#   String, default value `procmail`; name of the procmail package.
#
# [*configs*]
#   Hash, used to create `procmail::conf` resources from Hiera.
#
# === Examples
#
#  include procmail
#
# === Authors
#
# Jasper Lievisse Adriaanse <jasper@humppa.nl>
#
# === Copyright
#
# Copyright 2014 Jasper Lievisse Adriaanse
#
class procmail (
  $package = $::procmail::defaults::package,
  $configs = {},
) inherits ::procmail::defaults {
  validate_hash($configs)
  validate_string($package)

  include ::procmail::install

  create_resources('procmail::conf', $configs)
}
