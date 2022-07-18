
# FIXING THE DREADED “ERRORS WERE ENCOUNTERED WHILE PROCESSING” ERRORS

_For the past week or two, every time I installed new software into Ubuntu, I was greeted with the “Errors were encountered while processing:” blah, blah, blah speech._

_Up until yesterday, that error was just a battle scar my computer had earned attempting to install a few software packages. I didn’t need them, my computer wasn’t bothered by them not being fully installed so after trying to fix them many times I thought f#ck it! No real problem. But yesterday, when a few more packages failed to install, and this time they stopped my computer from updating itself and prevented me from using Synaptic, I decided enough is enough, I’m going to fix it once and for all. So, I tooled up, got out my best keyboard, readied my fastest mouse, donned my Linux badges and set out on my quest to kill the Big Bad Bug, save the princess and live happily ever after…. sorry, got a little carried away there._

_Today, I completed my quest – I squished that bug and watched his juices spit all over my computer’s insides as it made that squelchy noise only squished bugs know how to make so well._

The next time you find you cannot add software into your Ubuntu distro because you’re getting errors that look like or totally unlike this one:

```
Reading package lists... Done
Building dependency tree
Reading state information... Done
0 upgraded, 0 newly installed, 0 to remove and 38 not upgraded.
4 not fully installed or removed.
Need to get 0B/590kB of archives.
After this operation, 0B of additional disk space will be used.
WARNING: The following packages cannot be authenticated!
python-distutils-extra scons
Authentication warning overridden.
Selecting previously deselected package python-distutils-extra.
(Reading database ... 458474 files and directories currently installed.)
Preparing to replace python-distutils-extra 2.12 (using .../python-distutils-extra_2.12_all.deb) ...
dpkg (subprocess): unable to execute old pre-removal script: Exec format error
dpkg: warning: old pre-removal script returned error exit status 2
dpkg - trying script from the new package instead ...
Traceback (most recent call last):
File "/usr/bin/pycentral", line 2196, in <module>
main()
File "/usr/bin/pycentral", line 2190, in main
rv = action.run(global_options)
File "/usr/bin/pycentral", line 1645, in run
pkg = DebPackage('package', self.args[0], oldstyle=False)
File "/usr/bin/pycentral", line 381, in __init__
self.read_pyfiles()
File "/usr/bin/pycentral", line 414, in read_pyfiles
self.pkgconfig.set('pycentral', 'include-links', '0')
File "/usr/lib/python2.6/ConfigParser.py", line 669, in set
ConfigParser.set(self, section, option, value)
File "/usr/lib/python2.6/ConfigParser.py", line 377, in set
raise NoSectionError(section)
ConfigParser.NoSectionError: No section: 'pycentral'
dpkg: error processing /var/cache/apt/archives/python-distutils-extra_2.12_all.deb (--unpack):
subprocess new pre-removal script returned error exit status 1
dpkg (subprocess): unable to execute installed post-installation script: Exec format error
dpkg: error while cleaning up:
subprocess installed post-installation script returned error exit status 2
Preparing to replace scons 1.2.0-2ubuntu1 (using .../scons_1.2.0-2ubuntu1_all.deb) ...
dpkg (subprocess): unable to execute old pre-removal script: Exec format error
dpkg: warning: old pre-removal script returned error exit status 2
dpkg - trying script from the new package instead ...
Traceback (most recent call last):
File "/usr/bin/pycentral", line 2196, in <module>
main()
File "/usr/bin/pycentral", line 2190, in main
rv = action.run(global_options)
File "/usr/bin/pycentral", line 1645, in run
pkg = DebPackage('package', self.args[0], oldstyle=False)
File "/usr/bin/pycentral", line 381, in __init__
self.read_pyfiles()
File "/usr/bin/pycentral", line 414, in read_pyfiles
self.pkgconfig.set('pycentral', 'include-links', '0')
File "/usr/lib/python2.6/ConfigParser.py", line 669, in set
ConfigParser.set(self, section, option, value)
File "/usr/lib/python2.6/ConfigParser.py", line 377, in set
raise NoSectionError(section)
ConfigParser.NoSectionError: No section: 'pycentral'
dpkg: error processing /var/cache/apt/archives/scons_1.2.0-2ubuntu1_all.deb (--unpack):
subprocess new pre-removal script returned error exit status 1
dpkg (subprocess): unable to execute installed post-installation script: Exec format error
dpkg: error while cleaning up:
subprocess installed post-installation script returned error exit status 2
Errors were encountered while processing:
/var/cache/apt/archives/python-distutils-extra_2.12_all.deb
/var/cache/apt/archives/scons_1.2.0-2ubuntu1_all.deb
E: Sub-process /usr/bin/dpkg returned an error code (1)
```

Use these steps to fix them:

Firstly, make a note of the applications that refuse to install then try one or more of the usual hit-n-stab gambits before pulling out your longsword and making more extensive blood letting cuts into your system:

1.  **ensure that the shared libraries are properly registered (also fixes some GCC/G++ errors)**

```
sudo ldconfig
```

1.  **try to remove the package (replace ‘your-app’ with the name of the dodgy application)**

```
sudo dpkg -r YOUR-APP
```

1.  **check your package cache**

```
sudo apt-get check
```

1.  **update your package list**

```
sudo apt-get update
```

1.  **ensure package downloads were properly completed when the system last updated**

```
sudo apt-get upgrade --fix-missing
```

1.  **try to upgrade the system (sometimes an updated package version fixes the issue)**

```
sudo apt-get upgrade
sudo apt-get dist-upgrade
```

1.  **try to reconfigure all applications that failed to install**

```
sudo dpkg --configure -a
```

1.  **try to reconfigure specific applications that failed to install**

```
sudo dpkg --configure YOUR-APP
```

1.  **try to fix broken packages**

```
sudo apt-get install -f
```

1.  **try to fix a specific broken package**

```
sudo apt-get install YOUR-APP -f
```

1.  **try to install the dependencies that an application requires for it to install successfully**

```
sudo apt-get build-dep YOUR-APP
```

1.  **re-try to install the failed apps**

```
sudo apt-get install
```

If none of the above fix it, try this:

1.  **Go to the website that maintains the failed package. In most cases, this will be [Launchpad.net](https://launchpad.net/ "Launchpad.net") (for Ubuntu flavors, go [here](https://launchpad.net/ubuntu/ "Ubuntu Packages at Launchpad")); users of Debian distros (inc. Ubuntu) can download source code packages from [Debian.org](https://www.debian.org/distrib/packages "Download Debian Source Codes from Debian.org") and a lot of packages for all distros are maintained through [Gna](http://gna.org/ "Download Free Software from Gna"). If you’re really stuck, Google it;**
2.  **Search for the failed package then re-download it and re-install it. First try the deb package that is pre-built for your OS version then, if that doesn’t work, download the source code and build it from scratch;**
    
    1.  Most packages ship with installation instructions written in a Readme or Installation file (it’s important to read them). Most build with either
    
    ```
    ./configure
    make
    make install
    ```
    
    1.  else
    
    ```
    python setup.py install
    ```
    
    1.  Ensure any shared libraries are properly registered
    
    ```
    sudo ldconfig
    ```
    

**If you struggle to install the downloaded source code you can read this [Linux Software Installation EasyGuide](https://journalxtra.com/2010/03/linux-software-installation-easyguide/ "Linux Software Installation EasyGuide"). The downside to installing from source code (i.e not through Apt, Aptitude, Yum or dpkg) is that your regular package manager will not know that the software has been installed. Just re-install it through your regular package manager once it is functioning properly.**

If you are still battling away after trying the above then you have no choice but to bring out your longsword and start swinging at dpkg’s bowels:

1.  **backup your dpkg status file with**

```
sudo cp /var/lib/dpkg/status status.bckup
```

1.  **just for reference, if you need to restore the backup version of the status file, type**

```
sudo mv status.bckup > /var/lib/dpkg/status
```

1.  **edit your dpkg status file**
    
    1.  KDE Users
    
    ```
    kdesudo kate /var/lib/dpkg/status
    ```
    
    1.  Gnome users
    
    ```
    gksu gedit /var/lib/dpkg/status
    ```
    
2.  **search for the problem package(s) by name (press Ctrl+F),**
3.  **edit the line that reads**

```
Status: install reinstreq half-configured
```

to replace it with

```
Status: install ok installed
```

and save it,

1.  **then either uninstall the package(s) then/or re-install it(them) with either**

```
sudo apt-get remove YOUR-APP
```

1.  **else**

```
sudo apt-get install YOUR-APP
```

1.  **If the problem persists, re-edit /var/lib/dpkg/status but this time search for the failed package by name and delete its details from**
    
    ```
    Package....
    ```
    
    **to**
    
    ```
    Description....
    ```
    
    **Delete from the open line above package to the open line below its description that leads on to the next package’s details. Here is an example of the complete package listing for ‘lsb-core’:**
    
    ```
    Package: lsb-core
    Status: install ok installed
    Priority: extra
    Section: misc
    Installed-Size: 196
    Maintainer: Ubuntu Core Developers <ubuntu-devel-discuss@lists.ubuntu.com>
    Architecture: amd64
    Source: lsb
    Version: 4.0-0ubuntu5
    Replaces: lsb (<< 2.0-2)
    Provides: lsb-core-amd64, lsb-core-noarch
    Depends: lsb-release, libc6 (>> 2.3.5), libz1, libncurses5, libpam0g, postfix | mail-transport-agent, at, bc, binutils, bsdmainutils, bsdutils, cpio, cron, ed, file, libc6-dev | libc-dev, locales, cups-bsd | lpr, lprng | cups-client, m4, mailx | mailutils, make, man-db, mawk | gawk, ncurses-term, passwd, patch, pax, procps, psmisc, rsync, alien (>= 8.36), python, python-central (>= 0.6.11), debconf (>= 0.5) | debconf-2.0, libc6-i386, lib32z1, lsb-base, time
    Conflicts: lsb (<< 2.0-2)
    Description: Linux Standard Base 4.0 core support package
    The Linux Standard Base (http://www.linuxbase.org/) is a standard
    core system that third-party applications written for Linux can
    depend upon.
    .
    This package provides an implementation of the core of version 4.0 of
    the Linux Standard Base for Debian on the Intel x86, Intel ia64
    (Itanium), IBM S390, and PowerPC 32-bit architectures with the Linux
    kernel. Future revisions of the specification and this package may
    support the LSB on additional architectures and kernels.
    .
    The intent of this package is to provide a best current practice way
    of installing and running LSB packages on Debian GNU/Linux. Its
    presence does not imply that Debian fully complies
    with the Linux Standard Base, and should not be construed as a
    statement that Debian is LSB-compliant.
    Homepage: http://www.linux-foundation.org/en/LSB
    Original-Maintainer: Chris Lawrence <lawrencc@debian.org>
    Python-Version: all
    ```
    
    That whole section would be deleted were lsb-core an issue on your system.
    
2.  **When you update your package list you will notice that those packages with their details removed from dpkg’s status file will not now show as installed by dpkg. Rest assured, those packages are still installed/semi-installed but dpkg is no longer aware of them. At this point you can choose to either ‘re-install’ the badly installed package or just leave it hanging on your system as an undetected badly installed package which you should try to re-install at a later time. I recommend you try to re-install immediately. If you leave it as an undetected package, dpkg will not automatically update it and will try to re-install it should it be a dependency of other packages that you later try to install.**

If none of those steps fix it then the likelihood is that nothing will but search the net before you decide to re-install your operating system.

As a word of caution, never, ever delete your dpkg (apt) status file. If someone tells you to type

```
sudo rm /var/lib/dpkg/status
```

Ignore them or your computer will explode! You can open it up, look at it and edit it but you must never, ever delete it. It contains all the data dpkg requires to update and uninstall packages. If you delete it you will not be able to properly remove or upgrade the packages installed prior to it being removed and you might have problems when you try to install new packages into your system.

**Bootnote: You can use Aptitude to “Hold” partially installed packages and packages that prevent others from being installed. Open a terminal, type “sudo aptitude”, press “Ctrl+T” then “Return”, use the arrow keys to navigate to the suspect package, press the “equals” key i.e “=” (the package to be held should now change color), press Ctrl+T then press return and any packages that are ready to install but were stuck due to the (now) held package will now install.**

## Reference

* https://journalxtra.com/linux/fixing-the-dreaded-errors-were-encountered-while-processing-errors/
