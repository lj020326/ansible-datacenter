#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
echo "SCRIPT_DIR=[${SCRIPT_DIR}]"

source ${SCRIPT_DIR}/.env

echo "archiving cloudstack api config"
snap_date=$(date +%Y%m%d_%H%M)

if [ -e ~/.cloudstack.ini ]; then
  mv ~/.cloudstack.ini ~/.cloudstack.ini.${snap_date}
fi

## ref: https://gist.github.com/CrackerJackMack/2972401
##
#/etc/init.d/cloud-management stop
systemctl stop cloudstack-agent cloudstack-management

mysql -p${CSRootPassword} -e 'drop database cloud'
mysql -p${CSRootPassword} -e 'drop database cloud_usage'

#/usr/bin/cloudstack-setup-databases cloud:password@localhost --deploy-as=root:password \
/usr/bin/cloudstack-setup-databases ${CSCloudDBUser}:${CSCloudDBPass}@localhost \
    --deploy-as=root:${CSRootPassword} \
    -m ${CSRootPassword} \
    -k ${CSCloudDBPass}

rm -rf /var/log/cloudstack/management/*
rm -rf /etc/cloudstack/agent/*.crt
rm -rf /etc/cloudstack/agent/*.csr
rm -rf /etc/cloudstack/agent/*.jks
rm -rf /etc/cloudstack/agent/*.key

/usr/bin/cloudstack-setup-management

#/etc/init.d/cloud-management start
systemctl start cloudstack-management

max_attempts=40
attempt_counter=0

## ref: https://stackoverflow.com/questions/11904772/how-to-create-a-loop-in-bash-that-is-waiting-for-a-webserver-to-respond
echo "waiting for cloudstack management server to bootstrap before starting agent"
until $(curl --output /dev/null --silent --head --max-time 5 --fail http://localhost:8080/client); do
    if [ ${attempt_counter} -eq ${max_attempts} ]; then
      echo "Max attempts reached"
      exit 1
    fi
    printf '.'
    attempt_counter=$(($attempt_counter+1))
    sleep 5
done
printf '\n'

echo "Finished: cloudstack management server ready"
#systemctl start cloudstack-agent

exit ${?}
