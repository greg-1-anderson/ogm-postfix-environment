# == Class: procmail::install
#
# Installs $::procmail::package, duh.
#
class procmail::install {
  package { $::procmail::package:
    ensure => latest
  }
}
