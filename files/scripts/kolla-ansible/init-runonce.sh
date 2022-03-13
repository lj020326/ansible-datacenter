#!/usr/bin/env bash

set -o errexit

# This script is meant to be run once after running start for the first
# time.  This script downloads a cirros image and registers it.  Then it
# configures networking and nova quotas to allow 40 m1.small instances
# to be created.

ARCH=$(uname -m)
IMAGE_PATH=/opt/cache/files/
IMAGE_URL=http://download.cirros-cloud.net/0.4.0/
IMAGE=cirros-0.4.0-${ARCH}-disk.img
IMAGE_NAME=cirros
IMAGE_TYPE=linux

# This EXT_NET_CIDR is your public network,that you want to connect to the internet via.
ENABLE_EXT_NET=${ENABLE_EXT_NET:-1}
#EXT_NET_CIDR='10.0.2.0/24'
#EXT_NET_RANGE='start=10.0.2.150,end=10.0.2.199'
#EXT_NET_GATEWAY='10.0.2.1'
#EXT_NET_CIDR='192.168.0.0/24'
#EXT_NET_RANGE='start=192.168.0.150,end=192.168.0.199'
#EXT_NET_GATEWAY='192.168.0.1'
EXT_NET_CIDR='192.168.30.0/24'
EXT_NET_RANGE='start=192.168.30.20,end=192.168.30.200'
EXT_NET_GATEWAY='192.168.30.1'
#EXT_NET_GATEWAY='192.168.0.15'

PHYSICAL_NETWORK=physnet1
## ref: https://ask.openstack.org/en/question/111356/cannot-ssh-or-ping-instance-floating-ips-in-openstack/
#PHYSICAL_NETWORK=extnet

#EXT_NET_NAME=public1
EXT_NET_NAME=public01


# Sanitize language settings to avoid commands bailing out
# with "unsupported locale setting" errors.
unset LANG
unset LANGUAGE
LC_ALL=C
export LC_ALL
for i in curl openstack; do
    if [[ ! $(type ${i} 2>/dev/null) ]]; then
        if [ "${i}" == 'curl' ]; then
            echo "Please install ${i} before proceeding"
        else
            echo "Please install python-${i}client before proceeding"
        fi
        exit
    fi
done

# Test for credentials set
if [[ "${OS_USERNAME}" == "" ]]; then
    echo "No Keystone credentials specified. Try running source /etc/kolla/admin-openrc.sh command"
    exit
fi

# Test to ensure configure script is run only once
if openstack image list | grep -q cirros; then
    echo "This tool should only be run once per deployment."
    exit
fi

echo Checking for locally available cirros image.
# Let's first try to see if the image is available locally
# nodepool nodes caches them in $IMAGE_PATH
if ! [ -f "${IMAGE_PATH}/${IMAGE}" ]; then
    IMAGE_PATH='./'
    if ! [ -f "${IMAGE_PATH}/${IMAGE}" ]; then
        echo None found, downloading cirros image.
        curl -L -o ${IMAGE_PATH}/${IMAGE} ${IMAGE_URL}/${IMAGE}
    fi
else
    echo Using cached cirros image from the nodepool node.
fi

echo Creating glance image.
openstack image create --disk-format qcow2 --container-format bare --public \
    --property os_type=${IMAGE_TYPE} --file ${IMAGE_PATH}/${IMAGE} ${IMAGE_NAME}

echo Configuring neutron.
if [[ $ENABLE_EXT_NET -eq 1 ]]; then
    openstack network create --external --provider-physical-network ${PHYSICAL_NETWORK} \
        --provider-network-type flat ${EXT_NET_NAME}

    ## ref: https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/10/html/networking_guide/sec-connect-instance
    openstack subnet create --no-dhcp \
        --allocation-pool ${EXT_NET_RANGE} --network ${EXT_NET_NAME} \
        --subnet-range ${EXT_NET_CIDR} --gateway ${EXT_NET_GATEWAY} ${EXT_NET_NAME}-subnet
fi

openstack network create --provider-network-type vxlan demo-net
openstack subnet create --subnet-range 10.0.0.0/24 --network demo-net \
    --gateway 10.0.0.1 --dns-nameserver 8.8.8.8 demo-subnet

openstack router create demo-router
openstack router add subnet demo-router demo-subnet
if [[ $ENABLE_EXT_NET -eq 1 ]]; then
  openstack router set --external-gateway ${EXT_NET_NAME} demo-router
fi

# Get admin user and tenant IDs
ADMIN_USER_ID=$(openstack user list | awk '/ admin / {print $2}')
ADMIN_PROJECT_ID=$(openstack project list | awk '/ admin / {print $2}')
ADMIN_SEC_GROUP=$(openstack security group list --project ${ADMIN_PROJECT_ID} | awk '/ default / {print $2}')

# Sec Group Config
openstack security group rule create --ingress --ethertype IPv4 \
    --protocol icmp ${ADMIN_SEC_GROUP}
openstack security group rule create --ingress --ethertype IPv4 \
    --protocol tcp --dst-port 22 ${ADMIN_SEC_GROUP}
# Open heat-cfn so it can run on a different host
openstack security group rule create --ingress --ethertype IPv4 \
    --protocol tcp --dst-port 8000 ${ADMIN_SEC_GROUP}
openstack security group rule create --ingress --ethertype IPv4 \
    --protocol tcp --dst-port 8080 ${ADMIN_SEC_GROUP}

if [ ! -f ~/.ssh/id_rsa.pub ]; then
    echo Generating ssh key.
    ssh-keygen -t rsa -f ~/.ssh/id_rsa
fi
if [ -r ~/.ssh/id_rsa.pub ]; then
    echo Configuring nova public key and quotas.
    openstack keypair create --public-key ~/.ssh/id_rsa.pub mykey
fi

# Increase the quota to allow 40 m1.small instances to be created

# 40 instances
openstack quota set --instances 40 ${ADMIN_PROJECT_ID}

# 40 cores
openstack quota set --cores 40 ${ADMIN_PROJECT_ID}

# 96GB ram
openstack quota set --ram 96000 ${ADMIN_PROJECT_ID}

# add default flavors, if they don't already exist
if ! openstack flavor list | grep -q m1.tiny; then
    openstack flavor create --id 1 --ram 512 --disk 1 --vcpus 1 m1.tiny
    openstack flavor create --id 2 --ram 2048 --disk 20 --vcpus 1 m1.small
    openstack flavor create --id 3 --ram 4096 --disk 40 --vcpus 2 m1.medium
    openstack flavor create --id 4 --ram 8192 --disk 80 --vcpus 4 m1.large
    openstack flavor create --id 5 --ram 16384 --disk 160 --vcpus 8 m1.xlarge
fi

cat << EOF

Done.

To deploy a demo instance, run:

openstack server create \\
    --image ${IMAGE_NAME} \\
    --flavor m1.tiny \\
    --key-name mykey \\
    --network demo-net \\
    demo1
EOF
