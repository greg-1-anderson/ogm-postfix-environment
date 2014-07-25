# procmail

## Overview

This module installs `procmail` and creates `.procmailrc` files for users
though the `procmail::conf` type.

## Usage

First classify the node with the module:

    include procmail

Then for example in Hiera:

    procmail::configs:
      'jasper':
        extra_vars:
          'lockfile': '/home/jasper/.lockmail'
        rules:
          - comment:   'spam spam spam'
            condition: '^X-Spam-Status: Yes'
            action:    '$MAILDIR/Spam/'

This will then create `/home/jasper/.procmailrc` with the following contents:

    PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11R6/bin:/usr/local/bin:/usr/local/sbin
    MAILDIR=/home/jasper/Maildir
    DEFAULT=/var/mail/jasper
    LOCKFILE=/home/jasper/.lockmail

    #
    # spam spam spam
    #
    :0
    * ^X-Spam-Status: Yes
    $MAILDIR/Spam/

    #
    # Match every remaining mail.
    #
    :0
    * .*
    $MAILDIR/

If you ommit the `action` parameter:

    rules:
      - comment:   'Spam'
        condition: '^X-Spam-Status: Yes'

a default action rule will be created:

    #
    # Spam
    #
    :0
    * ^X-Spam-Status: Yes
    $MAILDIR/Spam/

## Copyright

2014 Jasper Lievisse Adriaanse <jasper@humppa.nl>
Released under the terms of the MIT license, please see [LICENSE](./LICENSE)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
