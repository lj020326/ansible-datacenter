#!/usr/bin/env bash

## ref: https://sysadminonline.net/deploy-cloudstack-management-server-using-ansible-part-ii-management-server/

#DIRS="basic-server-hardening deploy-authorized-keys epel-repository common management mariadb nfs kvm"
DIRS="deploy-authorized-keys epel-repository common management mariadb nfs kvm"
DIRS+=" iscsi-clients"
DIRS+=" webmin"

for dir in $DIRS
do
    echo "Create the roles for directory [$dir]"
    mkdir -p roles/${dir}/{tasks,handlers,templates,files,vars,defaults,meta}

    echo "Create the main.yml files for directory [$dir] in the different roles as below"
    touch roles/${dir}/{tasks,handlers,templates,files,vars,defaults,meta}/main.yml
done

tree

ROLES="debops.iscsi"
ROLES+=" ansible.iscsiadm"
ROLES+=" alban.andrieu.webmin"

ansible-galaxy install debops.iscsi
ansible-galaxy install ansible.iscsiadm
ansible-galaxy install alban.andrieu.webmin
