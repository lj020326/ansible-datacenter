#!/usr/bin/env bash

## ref: https://www.ovirt.org/documentation/how-to/hosted-engine/

echo "stopping services"
service vdsmd stop 2>/dev/null
service supervdsmd stop 2>/dev/null
initctl stop libvirtd 2>/dev/null

echo "removing packages"
yum remove \*ovirt\* \*vdsm\* \*libvirt\*

rm -fR /etc/*ovirt* /etc/*vdsm* /etc/*libvirt* /etc/pki/vdsm

FILES=" /etc/init/libvirtd.conf"
FILES+=" /etc/libvirt/nwfilter/vdsm-no-mac-spoofing.xml"
FILES+=" /etc/ovirt-hosted-engine/answers.conf"
FILES+=" etc/vdsm/vdsm.conf"
FILES+=" etc/pki/vdsm/*/*.pem"
FILES+=" etc/pki/CA/cacert.pem"
FILES+=" etc/pki/libvirt/*.pem"
FILES+=" etc/pki/libvirt/private/*.pem"
for f in $FILES
do
   [ ! -e $f ] && echo "? $f already missing" && continue
   echo "- removing $f"
   rm -f $f && continue
   echo "! error removing $f"
   exit 1
done

DIRS="/etc/ovirt-hosted-engine /var/lib/libvirt/ /var/lib/vdsm/ /var/lib/ovirt-hosted-engine-* /var/log/ovirt-hosted-engine-setup/ /var/cache/libvirt/"
for d in $DIRS
do
   [ ! -d $f ] && echo "? $d already missing" && continue
   echo "- removing $d"
   rm -fR $d && continue
   echo "! error removing $d"
   exit 1
done

