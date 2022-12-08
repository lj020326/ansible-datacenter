#!/bin/sh
for a in /sys/devices/system/memory/memory*/state;
do
    echo 'online' > "$a"
done
