
How to run pacman install silently / without confirmations:

    ## ref: https://bbs.archlinux.org/viewtopic.php?id=121792
    ## pacman -S --help | grep confirm
    
    pacman -S --noconfirm


How to run install using package/requirements file

    ## ref: https://unix.stackexchange.com/questions/587630/how-to-install-packages-with-pacman-from-a-list-contained-in-a-text-file
    
    cat input_file | cut "-d " -f1 |  xargs pacman -S --noconfirm

    cat save/pacman-python-upgrade-fix.txt | xargs pacman -S --noconfirm


## Set up SSH Agent

Fetch our ssh-agent.sh script and wire it up to work with your new MSYS2 install with the following multi-line command:

```
curl -OL https://github.com/OULibraries/msys2-setup/raw/master/ssh-agent.sh && \
chmod +x ssh-agent.sh && \
mv ssh-agent.sh /etc/profile.d/
```

This script checks to make sure that the ssh-agent key manager is running and has access to your keys when you open a new MSYS2 shell. Once you've installed it, quit and restart MSYS2. You should get asked to enter your the passphrase required to uncock the key that you just created, after which your key will be available to ssh.

### [](https://github.com/OULibraries/msys2-setup/blob/master/02-ssh.md#set-up-your-ssh-key-at-github)

## If having issues with install

	ref: https://github.com/msys2/MSYS2-packages/issues/2058

	See the news https://www.msys2.org/news/#2020-06-29-new-packagers

	## Try 
	pacman-key --init
	pacman-key --populate

	## If possible, try newer version of msys2-installer.


## howto install msys2
https://msys2.github.io/
https://sourceforge.net/p/msys2/wiki/MSYS2%20installation/
https://sourceforge.net/p/msys2/mailman/msys2-users/?limit=250&page=3

## if getting the following error:
checking build system type... /bin/sh: ./config.guess: No such file or directory
configure: error: cannot guess build type; you must specify one

## then:
## source: http://stackoverflow.com/questions/4810996/how-to-resolve-configure-guessing-build-type-failure
search for /usr/share/automake*/config.guess

check the latest version of automake

$ which automake
$ automake --version

find the appropriate automake folder in /usr/share/automake.1.11.1/config.guess

replace config.guess from your build tree with /usr/share/automake.1.11.1/config.guess

(The same may/is usually needed for config.sub.)


## Note - for some reason cmake adds "x64-86" as a C FLAG
## this causes compile issues since the gcc compiler does not accept this flag
## use the following config to override this behavior
## in order to get cmake to work:
cmake -G"MSYS Makefiles" -DCMAKE_C_FLAGS= -DCMAKE_BUILD_TYPE=Debug --debug-output ..

## then
make

## to update msys2 mirrors
## see: https://github.com/Alexpux/MINGW-packages/issues/702
wget http://repo.msys2.org/msys/x86_64/pacman-mirrors-20150722-1-any.pkg.tar.xz
pacman -U pacman-mirrors-20150722-1-any.pkg.tar.xz

## another possibility for installing mingw
https://sourceforge.net/projects/mingw/files/Installer/mingw-get/

## To install mingw-get, visit the MinGW files repository at: 
## http://sourceforge.net/projects/mingw/files 
## then, from the "Installer" folder, download and run mingw-get-setup.exe, 
## and select your choices from the options presented [*], to install mingw-get. 


## get too many connection timeout messages - in the form of "too slow"
## so config pacman to use external wget using the Xfer command 
## add the following line in the pacman.conf
XferCommand = /usr/bin/wget --timeout=20 --tries=3 -c -O %o %u

## to install msys2
## see: http://blog.johannesmp.com/2015/09/01/installing-clang-on-windows-pt3/

## Download and install MSYS2 64 bit: Download Link 
## you'd never need to download the 32 bit version, since the 64 bit version can install 32 bit packages
## After the installer completes and the MSYS2 shell appears 
## to re-open it, the batch file is located in C:\msys64\msys2_shell.bat. 
## We Need to update its packages:
## 1) First, update the core packages: 
pacman --needed -Sy bash pacman pacman-mirrors msys2-runtime

## IMPORTANT: close the shell and re-open it here before doing anything else.
## 2) Now we can update all packages with: 
pacman -Su

## 3) Install the 32 bit version of MinGW-w64 and Clang (currently gcc is version 5.2.0 and clang is version 3.6.2): 
pacman -S mingw-w64-x86_64-clang mingw-w64-i686-clang

## and more:
## ref: https://github.com/deeplearning4j/libnd4j/blob/master/windows.md
pacman -S mingw-w64-x86_64-gcc mingw-w64-x86_64-cmake mingw-w64-x86_64-extra-cmake-modules make pkg-config grep sed gzip tar mingw64/mingw-w64-x86_64-openblas mingw-w64-x86_64-lz4

## to install/reinstall msys2
## see: https://sourceforge.net/p/msys2/wiki/MSYS2%20re-installation/
## also: 
## 1. Run your existing MSYS2 installation via msys2_shell.bat.
## 2. Make a list of installed packages:

pacman -Qqe | xargs echo > /c/packages.txt ; exit

## 3. Rename your msys?? folder to msys??.old.
## 4. Run the installer (or untar the base package, run msys2_shell.bat, then exit it).
## 5. To save server bandwidth and your time, move your old cached packages directory to the new installation. 
## 	In Explorer, remove the empty msys??\var\cache\pacman\pkg folder, then replace it with msys??.old\var\cache\pacman\pkg.
## 6. Run the new MSYS2 installation via msys2_shell.bat.
## 7. Update the package databases:
pacman -Sy
## 8. Update the core packages:
pacman --needed -S bash pacman pacman-mirrors msys2-runtime

## 9. If any packages got updated during step 8, you MUST restart MSYS2, otherwise you can get fork errors in the next step. 
## 	You need to exit all MSYS2 shells (and if using MSYS2 32bit, run autorebase.bat) then re-launch msys2_shell.bat.
## 10. Re-install your old packages, by entering:
pacman -S --needed --force $(cat /c/packages.txt)

## You may also want to compare your new $HOME folder with your old one and merge across your dotfiles and other files.


## to check what packages avail via pacman
pacman -Ss xxx

## to install packages via pacman
pacman -S xxx

## INSTALL INSTRUCTS at
## https://sourceforge.net/p/msys2/wiki/MSYS2%20installation/

## Since pacman 5.0.1.6403, you can just
## Repeat this step until it says there are no packages to update.
pacman -Syuu

## open MSYS2 64-bit shell
## following should display MINGW64
echo $MSYSTEM

pacman -S base-devel
pacman -S git tar binutils autoconf make \
	libtool automake python2 p7lib patch gcc

## how to install mingw 64 bit g++ toolchain
## see: http://stackoverflow.com/questions/30069830/how-to-install-mingw-w64-and-msys2
## Install a toolchain
## 
## a) for 32-bit:
## 
pacman -S mingw-w64-i686-gcc

## b) for 64-bit:
## 
pacman -S mingw-w64-x86_64-gcc

## install any libraries/tools you may need. You can search the repositories by doing

pacman -Ss package_name_of_something_i_want_to_install

## Open a MinGW-w64 shell:
## 
## a) To build 32-bit things, open the "MinGW-w64 32-bit Shell"
## 
## b) To build 64-bit things, open the "MinGW-w64 64-bit Shell"
## 
## Verify that the compiler is working by doing
## 

gcc -v

## If you want to use the toolchains (with installed libraries) outside of the MSYS2 environment, all you need to do is add <MSYS2 root>/mingw32/bin or <MSYS2 root>/mingw64/bin to your PATH.


## deprecated:
## should not be necessary
## Since pacman 4.2.1.6187, there's an update-core script
## now update
update-core

pacman -Syu

pacman -S git tar binutils autoconf make \
	libtool automake python2 p7lib patch gcc

pacman -S mingw-w64-x86_64-cmake
pacman -S mingw-w64-x86_64-clang


## if pacman fails due to "too slow" message
## manually download package from repo site at:
http://repo.msys2.org/msys/x86_64/

## then run pacman on the downloaded file
pacman -U ~/Downloads/*.xy

## The mingw64 "console" is just the same as the msys2 console but with the
## mingw64 `bin' directory at the front of the PATH, so the mingw64
## binaries are found first. It also sets some enviroment variables
## (MSYSTEM, for instance) but that's basically it.
## source: https://sourceforge.net/p/msys2/mailman/msys2-users/thread/CAOYw7duyHhz5bn82v0YDyFg9dNmxyBJjCssu9ykR_rJG_GhAaw%40mail.gmail.com/#msg33650889

## https://wiki.archlinux.org/index.php/pacman
## to completely remove package:
pacman -Rsn <name>

## install the silver searcher
## ref: https://github.com/ggreer/the_silver_searcher
pacman -S mingw64/mingw-w64-x86_64-ag
