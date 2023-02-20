
# CentOS 8.3 - How to switch a PHP installation from Remi to AppStream?

Currently, running PHP 7.4 from Remi. It was a modular dnf installation that replaced PHP 7.2 AppStream packages back when 7.2 was the newest PHP available from CentOS. In other words, Remi packages are the _system PHP_ configured with /etc/php.ini -- as opposed to an additional PHP installation that uses /opt/remi/PHP74/php.ini.

Lately however, CentOS AppStream provides PHP 7.4 and I would like to replace Remi packages with equivalent AppStream packages. How should I go about this?

```shell
# dnf module list php

CentOS Linux 8 - AppStream
Name             Stream                   Profiles                               Summary
php              7.2 [d]                  common [d], devel, minimal             PHP scripting language
php              7.3                      common [d], devel, minimal             PHP scripting language
php              7.4                      common [d], devel, minimal             PHP scripting language

Remi's Modular repository for Enterprise Linux 8 - x86_64
Name             Stream                   Profiles                               Summary
php              remi-7.2                 common [d], devel, minimal             PHP scripting language
php              remi-7.3                 common [d], devel, minimal             PHP scripting language
php              remi-7.4 [e]             common [d], devel, minimal             PHP scripting language
php              remi-8.0                 common [d], devel, minimal             PHP scripting language

Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled
```

I'm familiar with _dnf modularity_ to some extent but I'm doubting it's smart enough to wrangle everything cleanly using a shortcut method of any kind that avoids uninstalling and reinstalling PHP and all its modules from scratch. Suggestions on a path of least resistance would be much appreciated.

## Solution #1 (Best)

(RHEL 8.4+) The same way you switch any other module to a different stream:

```
dnf module switch-to php:7.4
```

Note that this will fail if you used any remi packages that are not in the new module stream, and the solution there is to remove PHP entirely from your system manually, and then switch the module stream, and then reinstall PHP.

## Solution #2

dnf does indeed have a satisfactory short method that avoids the tedium of removing and reinstalling PHP from scratch. There's plenty of prep to do but the essentials involve three commands.

```shell
dnf module reset php
dnf module install php:7.4
dnf distro-sync
```

As a heads up before running `dnf distro-sync`, leave the remi-modular repo enabled to retain certain modules such as _php-pecl-redis5_, _php-pecl-msgpack_, _php-pecl-imagick_ and so on (see below).

After a slew of transactions with no errors aside from \*.rpmnew files leaving existing \*.conf files intact, I ran a couple extra commands out of curiosity.

```shell
# dnf upgrade php\*
Last metadata expiration check: 1:09:55 ago on Fri 28 May 2021 02:05:10 PM EDT.
Dependencies resolved.
Nothing to do.
Complete!

# dnf remove --duplicates
Last metadata expiration check: 1:10:37 ago on Fri 28 May 2021 02:05:10 PM EDT.
Error: No duplicated packages found for removal.
```

Everything starts and runs as before with no obvious problems. There's just one rub to be aware of: a handful of modules from remi-modular were not replaced by CentOS or EPEL repos, which is [best explained in this Serverfault Q&A](https://serverfault.com/questions/997028/where-is-the-redis-module-for-php-on-centos-8-php-pecl-redis). Take note of [Issue 75](https://pagure.io/epel/issue/75) and @RemiCollet's interesting comments.

Noteworthy is the previous answer about switching streams. If RHEL is release 8.4 (and presumably the same for 8.4 releases of CentOS & Stream, AlmaLinux and Rocky Linux), `dnf module switch-to php:7.4` is a newer alternative to `dnf module reset` combined with `dnf distro-sync`.


## Reference

* https://serverfault.com/questions/1064562/centos-8-3-how-to-switch-a-php-installation-from-remi-to-appstream
* https://access.redhat.com/solutions/265523
* https://www.linuxunit.com/how-to-subscribe-to-rhel7-optional-channel/
* https://linuxopsys.com/topics/remove-packages-using-dnf
* https://unix.stackexchange.com/questions/704616/remove-all-dnf-modules-currently-installed
* https://support.shells.net/hc/en-us/articles/360060397794-Using-DNF-to-install-remove-and-update-packages-on-Fedora
* 