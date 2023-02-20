
# MSYS2 Notes

## How to enable symlinks in msys2

If using windows and want symlinks to work correctly as in linux, I always use an msys2 shell with the symlinks enabled feature set in the shell wrapper start:

```ini
winsymlinks:nativestrict
```

So your mingw64.ini would look something like this:

```ini
MSYS=winsymlinks:nativestrict
#MSYS2_PATH_TYPE=inherit
MSYSTEM=MINGW64
```

Or you can enable in the msys2_shell.cmd located in the msys2 app bin dir:

```batch
@echo off
setlocal

set "WD=%__CD__%"
if NOT EXIST "%WD%msys-2.0.dll" set "WD=%~dp0usr\bin\"
set "LOGINSHELL=bash"

rem To activate windows native symlinks uncomment next line
set MSYS=winsymlinks:nativestrict

rem To export full current PATH from environment into MSYS2 use '-use-full-path' parameter
rem or uncomment next line
rem set MSYS2_PATH_TYPE=inherit
...

```

Also, note that for the `ln -s somedir` command to work, you will need to start your msys shells as the elevated administrator user on the windows machine.

I simply configure the quicklaunch shortcut to start my msys shells as administrator since a number of similar use cases exist.

ref: https://stackoverflow.com/questions/61594025/symlink-in-msys2-copy-or-hard-link

## How to get ansible-vault to work on msys64

```shell
	pacman -S ansible
	pip install pycryptodome
	
	## does not work
	###pacman -S mingw-w64-x86_64-python-pycryptodome
```

## How to run dos command

How to run dos command:

```shell
	cmd //c command_to_run
```

## How to start shell without window

How to start shell without window:

```shell
	C:/apps/msys64/msys2_shell.cmd -defterm -here -no-start -mingw64 -lc "ssh administrator@media01.johnson.int"
```

## How to integrate msys64 with ms windows terminal

How to integrate msys64 with ms windows terminal:

	https://www.msys2.org/docs/terminals/

	```json
		...
            {
                "guid": "{17da3cac-b318-431e-8a3e-7fcdefe6d114}",
                "name": "MINGW64 / MSYS2",
                "commandline": "C:/apps/msys64/msys2_shell.cmd -defterm -here -no-start -mingw64",
                "startingDirectory": "C:/apps/msys64/home/%USERNAME%",
                "icon": "C:/apps/msys64/mingw64.ico",
                "fontFace": "Lucida Console",
                "fontSize": 9
            },
		...
	```


	https://superuser.com/questions/1486054/windows-terminal-predefined-tabs-on-startup
	https://freshman.tech/windows-terminal-guide/
	https://www.thomasmaurer.ch/2020/04/my-customized-windows-terminal-settings-json/

	https://www.howtogeek.com/673729/heres-why-the-new-windows-10-terminal-is-amazing/

	https://docs.microsoft.com/en-us/windows/wsl/install-win10#simplified-installation-for-windows-insiders
	https://www.microsoft.com/en-us/p/windows-terminal/9n0dx20hk701?rtc=1&activetab=pivot:overviewtab

Docker for windows:

	https://docs.docker.com/docker-for-windows/wsl/

## How to update ca cert bundle

How to update ca cert bundle:

	https://packages.msys2.org/package/ca-certificates?repo=msys&variant=x86_64

	1) install ca-certificates package:

		pacman -S ca-certificates

	2) put domain cacerts into distribution pki dir:

		cp -p mycert.pem /etc/pki/ca-trust/source/anchors/mycert.crt

	3) fetch SSL cert(s) from site url(s) into msys2 distribution dir:

		https://gitea.media.johnson.local/gitadmin/ansible-datacenter/src/branch/master/scripts/certs/import-cacert-msys2.sh

	4) run cacert update:

		/usr/bin/update-ca-trust

## How to setup ansible on msys2

How to setup ansible on msys2:

See install scripts:
	- [python2-install-ansible-script](python2-install-ansible-on-msys2.sh)
	- [python3-install-ansible-script](python2-install-ansible-on-msys2.sh)

	ref: https://gist.github.com/DaveB93/db94a6b310e08c928c0778f766562ab0

## How to upgrade to python3

If need to upgrade to python3:

```shell
	pacman -S python3-appdirs python3-attrs python3-packaging python3-pip python3-pyparsing python3-setuptools python3-six 
```

## How to use pacman packages

Using packages:

	https://github.com/msys2/msys2/wiki/Using-packages

## How to setup MSYS dev env

How to setup MSYS dev env:

1. Run `pacman -S --needed base-devel msys2-devel`

2. Set up $HOME
	Under "Environment Variables > User variables", add HOME -> %USERPROFILE%
	
	Also, SSH insists on using MSYS' /home, but you can get around that by adding this line to /etc/fstab:
	C:/Users /home ntfs binary,noacl,auto 1 1

	run `echo "C:/Users /home ntfs binary,noacl,auto 1 1" >> /etc/fstab; mount -a`

3. Install configure context menus and other nice-to-haves:
	how to setup home to point to c:/users:
	https://github.com/valtron/llvm-stuff/wiki/Set-up-Windows-dev-environment-with-MSYS2

4. Other tips (how to setup home to point to c:/users):
	https://github.com/valtron/llvm-stuff/wiki/Set-up-Windows-dev-environment-with-MSYS2
	https://github.com/mintty/mintty/wiki/Tips

5. How to debug ssh:
	ref: https://sourceforge.net/p/msys2/tickets/111/

	ssh administrator@admin2.johnson.local -v

Not needed:
	How to setup ssh-agent on msys:
	https://github.com/OULibraries/msys2-setup/blob/master/02-ssh.md
	https://github.com/OULibraries/msys2-setup/blob/master/ssh-agent.sh
	https://gist.github.com/bsara/5c4d90db3016814a3d2fe38d314f9c23
	https://gist.github.com/JanTvrdik/33df5554d981973fce02
	https://sites.google.com/site/axusdev/tutorials/createsshkeysinmsys

## How to update msys packages

Update msys packages:

```shell
pacman -Syu
```

Install base dev toolchain:
ref: https://www.devdungeon.com/content/install-gcc-compiler-windows-msys2-cc

```
pacman -S base-devel gcc vim cmake
pacman -S development
```

## how to run batch scripts

ref: https://sourceforge.net/p/mingw/bugs/1902/

```shell
cmd //c batch_script_name
```

## howto install msys2

https://msys2.github.io/
https://sourceforge.net/p/msys2/wiki/MSYS2%20installation/
https://sourceforge.net/p/msys2/mailman/msys2-users/?limit=250&page=3

## if getting the `./config.guess: No such file or directory` error

source: http://stackoverflow.com/questions/4810996/how-to-resolve-configure-guessing-build-type-failure

if getting the following error:

```shell
checking build system type... /bin/sh: ./config.guess: No such file or directory
configure: error: cannot guess build type; you must specify one
```

then search for /usr/share/automake*/config.guess

Check the latest version of automake

```shell
$ which automake
$ automake --version
```

find the appropriate automake folder in /usr/share/automake.1.11.1/config.guess

replace config.guess from your build tree with /usr/share/automake.1.11.1/config.guess

(The same may/is usually needed for config.sub.)

Note - for some reason cmake adds "x64-86" as a C FLAG
This causes compile issues since the gcc compiler does not accept this flag.
Use the following config to override this behavior in order to get cmake to work:

```shell
cmake -G"MSYS Makefiles" -DCMAKE_C_FLAGS= -DCMAKE_BUILD_TYPE=Debug --debug-output ..
```

then

```shell
make
```

## How to update msys2 mirrors

How to update msys2 mirrors
see: https://github.com/Alexpux/MINGW-packages/issues/702

```shell
wget http://repo.msys2.org/msys/x86_64/pacman-mirrors-20150722-1-any.pkg.tar.xz
pacman -U pacman-mirrors-20150722-1-any.pkg.tar.xz
```

## another option/possibility for installing mingw

https://sourceforge.net/projects/mingw/files/Installer/mingw-get/

To install mingw-get, visit the MinGW files repository at: 
http://sourceforge.net/projects/mingw/files 

then, from the "Installer" folder, download and run mingw-get-setup.exe, 
and select your choices from the options presented [*], to install mingw-get. 

get too many connection timeout messages - in the form of "too slow"
so config pacman to use external wget using the Xfer command 
add the following line in the pacman.conf

```ini
XferCommand = /usr/bin/wget --timeout=20 --tries=3 -c -O %o %u
```

## to install msys2
see: http://blog.johannesmp.com/2015/09/01/installing-clang-on-windows-pt3/

Download and install MSYS2 64 bit: Download Link 
you'd never need to download the 32 bit version, since the 64 bit version can install 32 bit packages

After the installer completes and the MSYS2 shell appears 
to re-open it, the batch file is located in C:\msys64\msys2_shell.bat. 
We Need to update its packages:

1) First, update the core packages: 

```shell
pacman --needed -Sy bash pacman pacman-mirrors msys2-runtime
```

IMPORTANT: close the shell and re-open it here before doing anything else.

2) Now we can update all packages with: 

```shell
pacman -Su
```

3) Install the 64 bit version of MinGW-w64 and Clang (currently gcc is version 5.2.0 and clang is version 3.6.2): 

```shell
pacman -S mingw-w64-x86_64-clang mingw-w64-i686-clang
```

and more:
ref: https://github.com/deeplearning4j/libnd4j/blob/master/windows.md

```shell
pacman -S mingw-w64-x86_64-gcc mingw-w64-x86_64-cmake mingw-w64-x86_64-extra-cmake-modules make pkg-config grep sed gzip tar mingw64/mingw-w64-x86_64-openblas mingw-w64-x86_64-lz4
```

## How to install/reinstall msys2

To install/reinstall msys2:
	see: https://sourceforge.net/p/msys2/wiki/MSYS2%20re-installation/

Overview: 

1. Run your existing MSYS2 installation via msys2_shell.bat.
2. Make a list of installed packages:

```shell
pacman -Qqe | xargs echo > /c/packages.txt ; exit
```

3. Rename your msys?? folder to msys??.old.
4. Run the installer (or untar the base package, run msys2_shell.bat, then exit it).
5. To save server bandwidth and your time, move your old cached packages directory to the new installation. 

Remove the empty msys??\var\cache\pacman\pkg folder, then replace it with msys??.old\var\cache\pacman\pkg.
6. Run the new MSYS2 installation via msys2_shell.bat.
7. Update the package databases:

```shell
pacman -Sy
```

8. Update the core packages:

```shell
pacman --needed -S bash pacman pacman-mirrors msys2-runtime
```

9. If any packages got updated during step 8, you MUST restart MSYS2, otherwise you can get fork errors in the next step. 
   You need to exit all MSYS2 shells (and if using MSYS2 32bit, run autorebase.bat) then re-launch msys2_shell.bat.

10. Re-install your old packages, by entering:

```shell
pacman -S --needed --force $(cat /c/packages.txt)
```

You may also want to compare your new $HOME folder with your old one and merge across your dotfiles and other files.

## How to check what packages avail via pacman
To check what packages avail via pacman

```shell
pacman -Ss xxx
```

## How to install packages via pacman

To install packages via pacman

```shell
pacman -S xxx
```

INSTALL INSTRUCTS at
 https://sourceforge.net/p/msys2/wiki/MSYS2%20installation/

Since pacman 5.0.1.6403, you can just
Repeat this step until it says there are no packages to update.

```shell
pacman -Syuu
```

Open MSYS2 64-bit shell
following should display MINGW64

```shell
echo $MSYSTEM

pacman -S base-devel
pacman -S git tar binutils autoconf make \
	libtool automake python2 p7lib patch gcc
```

## How to install mingw g++ toolchain

To install mingw g++ toolchain
ref: http://stackoverflow.com/questions/30069830/how-to-install-mingw-w64-and-msys2

### 64-bit g++
 
```shell
pacman -S mingw-w64-x86_64-gcc
```

### 32-bit g++
 
```shell
pacman -S mingw-w64-i686-gcc
```

## install any libraries/tools you may need. You can search the repositories by doing

```shell
pacman -Ss package_name_of_something_i_want_to_install
```

Open a MinGW-w64 shell:

a) To build 32-bit things, open the "MinGW-w64 32-bit Shell"
 
b) To build 64-bit things, open the "MinGW-w64 64-bit Shell"

Verify that the compiler is working by doing

```shell
gcc -v
```

If you want to use the toolchains (with installed libraries) outside of the MSYS2 environment, all you need to do is add <MSYS2 root>/mingw32/bin or <MSYS2 root>/mingw64/bin to your PATH.

Deprecated:
should not be necessary
Since pacman 4.2.1.6187, there's an update-core script

* Note: now just run pacman update

```shell
update-core

pacman -Syu

pacman -S git tar binutils autoconf make \
	libtool automake python2 p7lib patch gcc

pacman -S mingw-w64-x86_64-cmake
pacman -S mingw-w64-x86_64-clang
```

If pacman fails due to "too slow" message
manually download package from repo site at:
http://repo.msys2.org/msys/x86_64/

Then run pacman on the downloaded file

```shell
pacman -U ~/Downloads/*.xy
```

The mingw64 "console" is just the same as the msys2 console but with the mingw64 `bin` directory at the front of the PATH, so the mingw64 binaries are found first. It also sets some environment variables (`MSYSTEM` for instance) but that's basically it. (source: https://sourceforge.net/p/msys2/mailman/msys2-users/thread/CAOYw7duyHhz5bn82v0YDyFg9dNmxyBJjCssu9ykR_rJG_GhAaw%40mail.gmail.com/#msg33650889)

## How to completely remove package

ref: https://wiki.archlinux.org/index.php/pacman

To completely remove package:
```shell
pacman -Rsn <name>
```

## How to install silver searcher
ref: https://github.com/ggreer/the_silver_searcher

To install the silver searcher:

```shell
pacman -S mingw64/mingw-w64-x86_64-ag
```
