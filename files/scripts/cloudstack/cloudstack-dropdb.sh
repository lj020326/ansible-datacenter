#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
echo "SCRIPT_DIR=[${SCRIPT_DIR}]"

source ${SCRIPT_DIR}/.env

#/etc/init.d/cloud-management stop
systemctl stop cloudstack-agent
systemctl stop cloudstack-management

mysql -uroot -p${CSRootPassword} -e 'drop database cloud'
mysql -uroot -p${CSRootPassword} -e 'drop database cloud_usage'

echo "Finished: dropped cloudstack db"

exit ${?}
