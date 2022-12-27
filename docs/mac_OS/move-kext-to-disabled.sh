#!/usr/bin/env bash

# mount the drive as read/write
mount -rw /

# create a directory for "disabled" extensions
mkdir /Volumes/MAC\ HD`/Library/ExtensionsDisabled

# view files that exist in your Extensions folder but not the recovery partition
kexts=`comm -23 <(ls /Volumes/MAC\ HD`/Library/Extensions|sort) <(ls /Library/Extensions|sort)`
echo $kexts

# move "extra" kext files to the "disabled" directory
for kext in $kexts; do
    mv /Volumes/MAC\ HD`/Library/Extensions/$kext /Volumes/MAC\ HD`/Library/ExtensionsDisabled/$kext;
done

exit
