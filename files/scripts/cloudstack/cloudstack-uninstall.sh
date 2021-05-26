#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

${SCRIPT_DIR}/cloudstack-dropdb.sh

echo "archiving cloudstack api config"
snap_date=$(date +%Y%m%d_%H%M)

mv ~/.cloudstack.ini ~/.cloudstack.ini.${snap_date}

## ref: https://gist.github.com/CrackerJackMack/2972401
##
#/etc/init.d/cloud-management stop
systemctl stop cloudstack-management cloudstack-agent libvirtd

## for complete uninstall
## ref: https://www.shapeblue.com/virtualbox-test-env/
yum remove -y cloudstack-management \
    cloudstack-agent \
    mysql-server \
    libvirt \
    qemu-kvm \
    qemu-img

systemctl daemon-reload

exit ${?}

