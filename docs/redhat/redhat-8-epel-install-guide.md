
# How To enable the EPEL Repository on RHEL 8 / CentOS 8 Linux

Although it’s been a while since the release of Red Hat Enterprise Linux 8, the corresponding version of the `EPEL` repository (Extra Packages for Enterprise Linux) was only released few days ago. The repository contains packages that are not provided by the official software sources, as for example `extundelete`, an utility to recover deleted files from ext3/4 filesystems. Until now the solution to install those software was to build it from source or to use the previous version of EPEL (less than ideal). In this tutorial we will see how to add EPEL8 to [RHEL 8](chrome-extension://pcmpcfapbekmbjjkdalcgopdkipoggdi/how-to-install-rhel-8) / CentOS 8.

**In this tutorial you will learn:**

-   How to add the EPEL8 repository to RHEL 8 / CentOS 8
-   How to check all the packages contained in the EPEL8 repository

## Software Requirements and Conventions Used

Software Requirements and Linux Command Line Conventions
| Category | Requirements, Conventions or Software Version Used |
| --- | --- |
| System | Rhel/CentOS |
| Software | No specific software is needed to follow this tutorial |
| Other | Administrative privileges to install and configure the repository |
| Conventions | **#** – requires given [linux commands](chrome-extension://pcmpcfapbekmbjjkdalcgopdkipoggdi/linux-commands) to be executed with root privileges either directly as a root user or by use of `sudo` command  
**$** – requires given [linux commands](chrome-extension://pcmpcfapbekmbjjkdalcgopdkipoggdi/linux-commands) to be executed as a regular non-privileged user |

## Installing the configuration package

Enabling the `EPEL8` repository on RHEL 8 / CentOS 8 is very simple: all we need to do is to download and install the configuration package which contains the repository files.  The file is available for download at the following [address](https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm). For the sake of this tutorial I will assume we are operating from the command line interface. We don’t need to download the [package to install](chrome-extension://pcmpcfapbekmbjjkdalcgopdkipoggdi/how-to-install-packages-on-redhat-8) it: we can perform the operation directly using `dnf` package manager:

```
$ sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
```

We just use `dnf` with the `install` sub-command, and provide the `URL` of the package (in this case we used the `https` protocol). Once we run the command above an overview of the operations that would be performed is displayed, and we are prompted to confirm that we want to install the package:

```
================================================================================
 Package              Arch           Version         Repository            Size
================================================================================
Installing:
 epel-release         noarch         8-5.el8         @commandline          21 k

Transaction Summary
================================================================================
Install  1 Package

Total size: 21 k
Installed size: 30 k
Is this ok [y/N]: y

```

If we confirm by typing “y” and pressing enter, the package will be installed. It contains the files needed to configure the additional software sources. To see where those files have been installed, we can run the following command:

```
$ sudo rpm -ql epel-release
```

In the command above, the `-q` option is the short for `--query`, while `-l` is short for `--list`, and is used to list the files contained in a package. The command above produces the following output:

```
/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-8
/etc/yum.repos.d/epel-playground.repo
/etc/yum.repos.d/epel-testing.repo
/etc/yum.repos.d/epel.repo
/usr/lib/systemd/system-preset/90-epel.preset
/usr/share/doc/epel-release
/usr/share/doc/epel-release/GPL
/usr/share/doc/epel-release/README-epel-8-packaging.md
```

Apart from the documentation files and the repository public `gpg key`, we can see that three repository configuration files have been installed, they are the files with the `.repo` extension: `epel`, `epel-playground` and `epel-testing`. The first one is the main repository, the one which is enabled by default, the other two contain experimental version of software packages and must be enabled explicitly. To verify that the `EPEL` repository has been enabled we can run:

```
$ sudo dnf repolist -v
```

The command, if invoked as above, displays a list of all repositories enabled in the system (it can also be used to display only the disabled ones or all the repositories existing in the system). By providing the `-v` option, (short for `--verbose`), we can obtain a more detailed report:

```
Repo-id      : epel
Repo-name    : Extra Packages for Enterprise Linux 8 - x86_64
Repo-revision: 1566008900
Repo-updated : Sat 17 Aug 2019 04:28:41 AM CEST
Repo-pkgs    : 332
Repo-size    : 110 M
Repo-metalink:
https://mirrors.fedoraproject.org/metalink?repo=epel-8&arch=x86_64&infra=$infra&content=$contentdir
  Updated    : Sat 17 Aug 2019 02:08:39 PM CEST
Repo-baseurl : rsync://ftp.nluug.nl/fedora-epel/8/Everything/x86_64/ (78 more)
Repo-expire  : 172,800 second(s) (last: Sat 17 Aug 2019 02:08:39 PM CEST)
Repo-filename: /etc/yum.repos.d/epel.repo

Repo-id      : rhel-8-for-x86_64-appstream-rpms
Repo-name    : Red Hat Enterprise Linux 8 for x86_64 - AppStream (RPMs)
Repo-revision: 1565891235
Repo-updated : Thu 15 Aug 2019 07:47:15 PM CEST
Repo-pkgs    : 5,759
Repo-size    : 8.5 G
Repo-baseurl : https://cdn.redhat.com/content/dist/rhel8/8/x86_64/appstream/os
Repo-expire  : 86,400 second(s) (last: Thu 01 Jan 1970 01:00:00 AM CET)
Repo-filename: /etc/yum.repos.d/redhat.repo

Repo-id      : rhel-8-for-x86_64-baseos-rpms
Repo-name    : Red Hat Enterprise Linux 8 for x86_64 - BaseOS (RPMs)
Repo-revision: 1565191031
Repo-updated : Wed 07 Aug 2019 05:17:11 PM CEST
Repo-pkgs    : 2,097
Repo-size    : 1.9 G
Repo-baseurl : https://cdn.redhat.com/content/dist/rhel8/8/x86_64/baseos/os
Repo-expire  : 86,400 second(s) (last: Thu 01 Jan 1970 01:00:00 AM CET)
Repo-filename: /etc/yum.repos.d/redhat.repo
Total packages: 8,188

```

As we can see from the output of the command, the repository has been correctly activated, it is the first one in the list.

<iframe loading="lazy" src="https://www.youtube.com/embed/QgjDikRi4IQ" width="720" height="405" frameborder="0" allowfullscreen="allowfullscreen"></iframe>

## List the packages contained in the EPEL8 repository

Once we install and enable the `EPEL` repository, we can take advantage of the additional software packages it provides, installing them as usual. But what if we want to know all the packages contained in the repository? Once again, all we must do is to use `dnf` providing the `repo_id` of the repository we want to inspect, “epel” in this case:

```
$ sudo dnf repository-packages epel list
```

Here is an excerpt of the command result:

```
$ sudo dnf repository-packages epel list
Updating Subscription Management repositories.
Last metadata expiration check: 0:17:42 ago on Sat 17 Aug 2019 02:08:43 PM
CEST.
Available Packages
Available Packages
amavisd-new.noarch                                                              2.12.0-1.el8                                                       epel
amavisd-new-doc.noarch                                                          2.12.0-1.el8                                                       epel
amavisd-new-snmp.noarch                                                         2.12.0-1.el8                                                       epel
apachetop.x86_64                                                                0.19.7-1.el8                                                       epel
arj.x86_64                                                                      3.10.22-30.el8                                                     epel
beecrypt.x86_64                                                                 4.2.1-23.el8                                                       epel
beecrypt-apidocs.x86_64                                                         4.2.1-23.el8                                                       epel
beecrypt-devel.x86_64                                                           4.2.1-23.el8                                                       epel
bgpdump.x86_64                                                                  1.6.0-2.el8                                                        epel
bird.x86_64                                                                     2.0.4-1.el8                                                        epel
bird-doc.noarch                                                                 2.0.4-1.el8                                                        epel
bodhi-client.noarch                                                             4.0.2-2.el8.1                                                      epel
bodhi-composer.noarch                                                           4.0.2-2.el8.1                                                      epel
bodhi-server.noarch                                                             4.0.2-2.el8.1                                                      epel
cc1541.x86_64                                                                   2.0-3.el8                                                          epel
cc65.x86_64                                                                     2.18-8.el8                                                         epel
cc65-devel.noarch                                                               2.18-8.el8                                                         epel
cc65-doc.noarch                                                                 2.18-8.el8                                                         epel
cc65-utils.x86_64                                                               2.18-8.el8                                                         epel
cfitsio.x86_64                                                                  3.47-1.el8                                                         epel
cfitsio-devel.x86_64                                                            3.47-1.el8                                                         epel
cfitsio-docs.noarch                                                             3.47-1.el8                                                         epel
cfitsio-static.x86_64                                                           3.47-1.el8                                                         epel
[...]
```

As we can see from the output of the command, a lot of software usually provided by the `EPEL` channel is still missing from the repository, as for example packages needed to install alternative desktop environments like `Xfce4` or utilities like phpMyAdmin (check our [tutorial](https://linuxconfig.org/how-to-install-phpmyadmin-on-redhat-8) about installing it from source, as an alternative). Those packages will be probably provided in the future.

## Conclusion

In this tutorial we learned how to install and enable the EPEL8 repository on RHEL 8 / CentOS 8. We saw how to install the auto-configuration package which provides the “.repo” files which contain the repository configuration. We also learned how to verify that the new software source has been added to the system, and how to list all the package provided by it.

Although it’s been a while since the release of Red Hat Enterprise Linux 8, the corresponding version of the `EPEL` repository (Extra Packages for Enterprise Linux) was only released few days ago. The repository contains packages that are not provided by the official software sources, as for example `extundelete`, an utility to recover deleted files from ext3/4 filesystems. Until now the solution to install those software was to build it from source or to use the previous version of EPEL (less than ideal). In this tutorial we will see how to add EPEL8 to [RHEL 8](chrome-extension://pcmpcfapbekmbjjkdalcgopdkipoggdi/how-to-install-rhel-8) / CentOS 8.

## Reference

* https://linuxconfig.org/redhat-8-epel-install-guide
* 