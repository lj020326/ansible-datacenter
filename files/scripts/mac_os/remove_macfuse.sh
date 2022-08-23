#!/bin/bash

## ref: http://hints.macworld.com/article.php?story=20070121150939976
## ref: https://code.google.com/archive/p/macfuse/issues/36

cd /usr/local/bin
rm sshfs
sudo rm glib*
sudo rm pkg-config
sudo rm *gettext*
sudo rm *mount*

cd /usr/local/include
sudo rm -r fuse*
sudo rm -r glib-2.0
sudo rm gettext-po.h

cd /usr/local/lib
sudo rm -r pkgconfig
sudo rm -r glib*
sudo rm -r libg*
sudo rm -r *fuse*
sudo rm -r *gettext*

cd /usr/local/share
sudo rm -r glib*
sudo rm -r gettext

# Note: revised the target dir.
# previously was this dir which was incorrect:
# cd /System/Library/Extensions
# correct dir seems to be this one:
cd /Library/Extensions
sudo rm -r fusefs.kext

cd /System/Library/Filesystems
sudo rm -r fusefs.fs

sudo touch /System/Library/Extensions
# Note: Removed this line:
# shutdown -r now
# replaced it with a prompt at end of script telling user to restart:
echo " "
echo "PLEASE RESTART YOUR COMPUTER NOW..."
