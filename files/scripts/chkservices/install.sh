#!/bin/sh

BINARY=chkservices
BINARY_TARGET=/usr/bin
INITSCRIPT=init.d/chkservices
INITSCRIPT_TARGET=/etc/init.d
CONFIG=chkservices.conf
CONFIG_TARGET=/etc/chkservices

cp "$BINARY" "$BINARY_TARGET"
cp "$INITSCRIPT" "$INITSCRIPT_TARGET"

if [ ! -e "$CONFIG_TARGET" ]
then
    mkdir -p "$CONFIG_TARGET"
fi

if [ -e $CONFIG_TARGET/$CONFIG ]
then
    echo
    echo "-------------------------------------------------------------------"
    echo "Existing configuration found. Creating $CONFIG_TARGET/$CONFIG.new."
    echo "Update your existing configuration file with the new one or WFS may"
    echo "not operate properly due to changes. Press enter to continue."
    echo "-------------------------------------------------------------------"
    read
    cp "$CONFIG" "$CONFIG_TARGET/$CONFIG.new"
else
    cp "$CONFIG" "$CONFIG_TARGET/$CONFIG"
fi

chmod 755 "$BINARY_TARGET/$BINARY"
chmod 755 "$INITSCRIPT_TARGET/`basename $INITSCRIPT`"

##chkconfig chkservices on
## ref: https://stackoverflow.com/questions/20680050/how-do-i-install-chkconfig-on-ubuntu
systemctl status chkservices
systemctl enable chkservices
