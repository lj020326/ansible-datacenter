
Openstack kolla setup:

```bash

#run-remote.sh ansible-playbook site.yml --tags openstack-deploy-node
run-remote.sh ansible-playbook site.yml --tags bootstrap-openstack
run-remote.sh kolla-ansible -i inventory/hosts-openstack.ini bootstrap-servers
run-remote.sh kolla-ansible -i inventory/hosts-openstack.ini prechecks
run-remote.sh kolla-ansible -i inventory/hosts-openstack.ini deploy

## running post-deploy creates the /etc/kolla/openrc.sh
## ref: https://github.com/openstack/kolla-ansible/blob/master/ansible/post-deploy.yml
run-remote.sh kolla-ansible -i inventory/hosts-openstack.ini post-deploy

## setup osclient configs if necessary
## NOTE: not necessary to run this since it is included in bootstrap-openstack-cloud play
#run-remote.sh ansible-playbook site.yml --tags openstack-osclient

openstack image list
openstack service list
openstack network list
openstack router list
openstack server list
openstack compute service list
openstack dns service list
openstack zone list

## if the above works - then can run custom cloud config
run-remote.sh ansible-playbook site.yml --tags bootstrap-openstack-cloud

## to reconfigure kolla-ansible configure based on latest changes
run-remote.sh kolla-ansible -i inventory/hosts-openstack.ini reconfigure

## to reconfigure a specific service, e.g., nova, neutron, etc
run-remote.sh kolla-ansible -i inventory/hosts-openstack.ini reconfigure --tags nova
docker ps -f name=compute

run-remote.sh kolla-ansible -i inventory/hosts-openstack.ini reconfigure --tags neutron
docker ps -f name=neutron

run-remote.sh kolla-ansible -i inventory/hosts-openstack.ini reconfigure --tags designate
docker ps -f name=designate

#openstack zone create --email admin@openstack.example.int openstack.example.int.
openstack zone create --email admin@example.int openstack.example.int.


## or per (https://ask.openstack.org/en/question/113699/kolla-ansible-how-to-managemodify-configuration-files/)
run-remote.sh kolla-ansible -i inventory/hosts-openstack.ini genconfig ## (and restart manually the containers)

./inventory/openstack_inventory.py --list

## to destroy/reset everything back to the beginning for the inventory:
run-remote.sh kolla-ansible -i inventory/hosts-openstack.ini destroy --yes-i-really-really-mean-it

```

Adding a compute node:

	ref: https://greatbsky.github.io/kolla-for-openstack-in-docker/en.html
	sometime you neeed add or remove a computer node or controller node, you should modify /usr/share/kolla/ansible/inventory/multinode, then execute:

    ```
    kolla-ansible upgrade -i inventory/hosts-openstack.ini
    ```

Setting up designate:

    ref: https://blog.egonzalez.org/openstack/index/deploy-openstack-designate-with-kolla-ansible
    ref: https://elatov.github.io/2018/01/openstack-ansible-and-kolla-on-ubuntu-1604/
    ref: https://superuser.openstack.org/articles/deploying-openstack-designate-kolla/
    ref: https://opensource.com/article/19/4/getting-started-openstack-designate

    ```
    kolla-ansible -i inventory/hosts-openstack.ini reconfigure --tags designate
    ```

    ```
    openstack zone create --email admin@openstack.example.int openstack.example.int.
    ```


Using Openstack

```bash
(venv) administrator@admin2:[ansible-datacenter](master)$ openstack server list
+--------------------------------------+----------------+--------+--------------------------------------+--------+---------+
| ID                                   | Name           | Status | Networks                             | Image  | Flavor  |
+--------------------------------------+----------------+--------+--------------------------------------+--------+---------+
| da63ebaf-697e-4e47-9897-86370ab59477 | admin-cirros-2 | ACTIVE | admin-net=10.10.0.208, 192.168.30.24 | cirros | m1.nano |
| 6530d6ba-5a9c-4ba3-8fc1-9c11c5d39025 | admin-cirros-1 | ACTIVE | admin-net=10.10.0.158, 192.168.30.98 | cirros | m1.nano |
+--------------------------------------+----------------+--------+--------------------------------------+--------+---------+
(venv) administrator@admin2:[ansible-datacenter](master)$
(venv) administrator@admin2:[ansible-datacenter](master)$ openstack server show admin-cirros-1
+-------------------------------------+----------------------------------------------------------+
| Field                               | Value                                                    |
+-------------------------------------+----------------------------------------------------------+
| OS-DCF:diskConfig                   | MANUAL                                                   |
| OS-EXT-AZ:availability_zone         | nova                                                     |
| OS-EXT-SRV-ATTR:host                | node01                                                   |
| OS-EXT-SRV-ATTR:hypervisor_hostname | node01.example.int                                     |
| OS-EXT-SRV-ATTR:instance_name       | instance-00000001                                        |
| OS-EXT-STS:power_state              | Running                                                  |
| OS-EXT-STS:task_state               | None                                                     |
| OS-EXT-STS:vm_state                 | active                                                   |
| OS-SRV-USG:launched_at              | 2020-04-14T19:37:04.000000                               |
| OS-SRV-USG:terminated_at            | None                                                     |
| accessIPv4                          |                                                          |
| accessIPv6                          |                                                          |
| addresses                           | admin-net=10.10.0.158, 192.168.30.98                     |
| config_drive                        |                                                          |
| created                             | 2020-04-14T19:36:44Z                                     |
| flavor                              | m1.nano (fefdaa22-23d9-443f-a664-a06afad2e327)           |
| hostId                              | b2edd57cf149581ae4317cf34921e2bd2c8e81eeec804d463612fd9b |
| id                                  | 6530d6ba-5a9c-4ba3-8fc1-9c11c5d39025                     |
| image                               | cirros (f06264f1-ed0a-47a9-a1b0-80844c133ef7)            |
| key_name                            | ansible_key                                              |
| name                                | admin-cirros-1                                           |
| progress                            | 0                                                        |
| project_id                          | 414aef5587b244ac87db78240cf80bdb                         |
| properties                          | RestartOnFail='True'                                     |
| security_groups                     | name='admin-secgrp'                                      |
| status                              | ACTIVE                                                   |
| updated                             | 2020-04-15T14:44:09Z                                     |
| user_id                             | 10932fb31edd4218ae798dcf13c535be                         |
| volumes_attached                    |                                                          |
+-------------------------------------+----------------------------------------------------------+
(venv) administrator@admin2:[ansible-datacenter](master)$
(venv) administrator@admin2:[ansible-datacenter](master)$ openstack router list
+--------------------------------------+--------------+--------+-------+----------------------------------+-------------+-------+
| ID                                   | Name         | Status | State | Project                          | Distributed | HA    |
+--------------------------------------+--------------+--------+-------+----------------------------------+-------------+-------+
| 129c21b0-aa4c-4c73-8942-e9f8aa09fc3e | demo-router  | ACTIVE | UP    | 4b792ac483ad407989fbeafdab3e9e81 | False       | False |
| 584fca5d-b1a1-4e8f-8067-a1083a59ebe3 | admin-router | ACTIVE | UP    | 414aef5587b244ac87db78240cf80bdb | False       | False |
+--------------------------------------+--------------+--------+-------+----------------------------------+-------------+-------+
(venv) administrator@admin2:[ansible-datacenter](master)$

```


```
openstack server set --property RestartOnFail=True admin-cirros-1

## OPTIONAL:
## running init-runonce will:
## 1) load a cirrus image and 
## 2) create public and demo networks / subnets
## 3) create a router to connect the 2 networks 
## 4) create security groups to allow ingress network activity to specific ports
## 5) generates ssh key if not already present in ~/.ssh/id_rsa
## 6) add the public key as a nova compute public key
## 7) add quotas for the admin project
## 8) add default flavors, if they don't already exist
## 9) displays openstack command to start a new compute server instance using the newly loaded cirrus image
##
## ref: https://github.com/openstack/kolla-ansible/blob/master/tools/init-runonce 
run-remote.sh scripts/kolla-ansible/init-runonce.sh

run-remote.sh openstack server create --image cirros --flavor m1.tiny --key-name mykey --network demo-net demo1

source /etc/kolla/admin-openrc.sh
## or
source ~/openrc

openstack image list
openstack service list
openstack network list
openstack router list
openstack server list
openstack compute service list

./inventory/openstack_inventory.py --list

## test OVS networks
run-remote.sh bash -x scripts/kolla-ansible/test_ovs_networks.sh
run-remote.sh bash -x scripts/kolla-ansible/set_ovs_netenvs.sh


grep -E keystone_admin_password /etc/kolla/passwords.yml
grep -vE '^$|^#' /etc/kolla/globals.yml

## to destroy/reset everything back to the beginning for the inventory:
run-remote.sh kolla-ansible -i inventory/hosts-openstack.ini destroy --yes-i-really-really-mean-it

## to set latest changes to /etc/kolla/globals.yml
run-remote.sh ansible-playbook site.yml --tags bootstrap-openstack-deploy-node

## (optional - since included in next play) must run kolla-ansible deploy before doing this
#run-remote.sh ansible-playbook site.yml --tags bootstrap-openstack-osclient

## if the above works (ping/ssh to VM) - then can run custom cloud config
run-remote.sh ansible-playbook site.yml --tags bootstrap-openstack-cloud

## to reconfigure kolla-ansible configure based on latest changes
run-remote.sh kolla-ansible -i inventory/hosts-openstack.ini reconfigure

## or per (https://ask.openstack.org/en/question/113699/kolla-ansible-how-to-managemodify-configuration-files/)
run-remote.sh kolla-ansible -i inventory/hosts-openstack.ini genconfig ## (and restart manually the containers)
```

run on the target node to check docker container status:
```
docker images -a --filter "label=kolla_version" | wc -l
docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Names}}"
```

Debugging/Testing Openstack dynamic inventory group_vars
ref: https://github.com/ansible/ansible/issues/11238

```bash
#ansible tag_Name_Demo -vvvvv -m debug -a var=ansible_ssh_user
#ansible image-cirros -vvvvv -m debug -a var=ansible_ssh_user
#ansible -i openstack_inventory.py image-cirros -m debug -a var=ansible_ssh_user

ansible -i inventory/openstack_inventory.py image-cirros -m debug -a var=ansible_ssh_user
ansible -i inventory/openstack_inventory.py list

ansible image-cirros -m debug -a var=ansible_ssh_user

ansible image-cirros -m ping

```

working with openstack deploy node setup

```bash
run-remote.sh ansible -i inventory/hosts.ini all -m ping
run-remote.sh ansible -i inventory/hosts.ini -m ping
run-remote.sh ansible -i inventory/hosts.ini openstack -m ping
run-remote.sh ansible -i inventory/hosts-openstack.ini openstack -m ping

## to bootstrap the openstack deploy node for network and general ansible related dependencies:
#run-remote.sh ansible-playbook site.yml --tags bootstrap-node --limit node01
run-remote.sh ansible-playbook site.yml --tags bootstrap-node-network --limit node01
run-remote.sh ansible-playbook site.yml --tags bootstrap-user --limit node01

## to bootstrap the openstack deploy node for openstack:
#run-remote.sh ansible-playbook site.yml --tags bootstrap-openstack-deploy-node
run-remote.sh ansible-playbook site.yml --tags openstack-deploy-node
run-remote.sh ansible-playbook site.yml --tags openstack-osclient

## to bootstrap openstack:
run-remote.sh ansible-playbook site.yml --tags bootstrap-openstack-deploy-node

## optionally pull latest images:
run-remote.sh kolla-ansible -i inventory/hosts-openstack.ini pull

run-remote.sh kolla-ansible -i inventory/hosts-openstack.ini bootstrap-servers
run-remote.sh kolla-ansible -i inventory/hosts-openstack.ini prechecks
run-remote.sh kolla-ansible -i inventory/hosts-openstack.ini deploy
run-remote.sh kolla-ansible -i inventory/hosts-openstack.ini post-deploy

run-remote.sh scripts/kolla-ansible/init-runonce.sh
run-remote.sh openstack server create --image cirros --flavor m1.tiny --key-name mykey --network demo-net demo1

## if the above works (ping/ssh to VM) - then can run custom cloud config
run-remote.sh ansible-playbook site.yml --tags bootstrap-openstack-cloud

```

Making OpenStack Changes after the Kolla Deployment

to reconfigure components
E.g., I decided to use qemu (added one more option since it was mentioned here), here are the configs:

```bash
mkdir -p /etc/kolla/config/nova
cat << EOF > /etc/kolla/config/nova/nova-compute.conf
[libvirt]
virt_type=qemu
cpu_mode=none
EOF
```

Good reconfigure/custom config use case using designate for DNS:

    https://superuser.openstack.org/articles/deploying-openstack-designate-kolla/
    https://elatov.github.io/2018/01/openstack-ansible-and-kolla-on-ubuntu-1604/

To reconfigure nova:

    ref: https://superuser.openstack.org/articles/deploying-openstack-designate-kolla/

```bash
run-remote.sh kolla-ansible -i inventory/hosts-openstack.ini reconfigure --tags nova
```

working with openstack node stop/cleanup/destroy/reset

```bash
run-remote.sh kolla-ansible -i inventory/hosts-openstack.ini stop --yes-i-really-really-mean-it
run-remote.sh kolla-ansible -i inventory/hosts-openstack.ini destroy --yes-i-really-really-mean-it
```

working with openstack cloud env setup

```bash
run-remote.sh scripts/kolla-ansible/init-runonce.sh
run-remote.sh ansible-playbook site.yml --tags bootstrap-openstack-cloud

```

Ansible Openstack Modules:

    https://docs.ansible.com/ansible/latest/modules/list_of_cloud_modules.html#openstack

Useful commands:

    ref: https://sudomakeinstall.com/uncategorized/openstack-ansible-kolla-on-centos-7-with-python-virtual-env

/usr/share/kolla-ansible/tools/cleanup-containers 
venv/share/kolla-ansible/tools/cleanup-containers 

    used to remove deployed containers from the system. 
    This can be useful when you want to do a new clean deployment. 
    It will preserve the registry and the locally built images in the registry, 
    but will remove all running Kolla containers from the local Docker daemon. 
    It also removes the named volumes.

/usr/share/kolla-ansible/tools/cleanup-host 
venv/share/kolla-ansible/tools/cleanup-host 

    used to remove remnants of network changes triggered on the Docker host when the neutron-agents containers are launched. 
    This can be useful when you want to do a new clean deployment, particularly one changing the network topology.

/usr/share/kolla-ansible/tools/cleanup-images --all 

    used to remove all Docker images built by Kolla from the local Docker cache.

kolla-ansible -i INVENTORY deploy 

    used to deploy and start all Kolla containers.

kolla-ansible -i INVENTORY destroy
kolla-ansible -i inventory/hosts-openstack.ini destroy --yes-i-really-really-mean-it

    used to clean up containers and volumes in the cluster.

kolla-ansible -i INVENTORY mariadb_recovery 

    used to recover a completely stopped mariadb cluster.

kolla-ansible -i INVENTORY prechecks 

    used to check if all requirements are meet before deploy for each of the OpenStack services.

kolla-ansible -i INVENTORY post-deploy 

    used to do post deploy on deploy node to get the admin openrc file.

kolla-ansible -i INVENTORY pull 

    used to pull all images for containers.

kolla-ansible -i INVENTORY reconfigure 

    used to reconfigure OpenStack service.

kolla-ansible -i INVENTORY genconfig 

    this regenerates config from included custom configs
    used when making custom config changes

    After adding your custom configs, you then need to:

        1) kolla-ansible reconfigure (Apply change and restart required containers)
        2) kolla-ansible genconfig 
        3) restart the containers manually

    for changes into the hosts volume, if you do a 
        1) reconfigure
        2) upgrade
        3) deploy
        4) genconfig

        The config options will be overriden, proper way is using /etc/kolla/config in deploy hosts

    ref: https://ask.openstack.org/en/question/113699/kolla-ansible-how-to-managemodify-configuration-files/

kolla-ansible -i INVENTORY upgrade 

    used to upgrade existing OpenStack Environment.

kolla-ansible -i INVENTORY check 

    used to do post-deployment smoke tests


Commented configs:

    https://opendev.org/openstack/kolla-ansible/blame/branch/master/ansible/group_vars/all.yml

To run kolla-ansible equivalent command using ansible-playbook:

    kolla-ansible -i inventory/hosts-openstack.ini reconfigure ==>
        ansible-playbook -i inventory/hosts-openstack.ini \
            -e @/etc/kolla/globals.yml \
            -e @/etc/kolla/passwords.yml \
            -e CONFIG_DIR=/etc/kolla \
            -e kolla_action=reconfigure \
            -e kolla_serial=0 \
#            /home/administrator/repos/ansible/ansible-datacenter/venv/share/kolla-ansible/ansible/site.yml  \
            /opt/openstack/share/kolla-ansible/ansible/site.yml  \
            --verbose
 

After instance is deployed, try testing:

    ref: https://elatov.github.io/2018/01/openstack-ansible-and-kolla-on-ubuntu-1604/

```bash
administrator@admin2:[ansible-datacenter](master)$
administrator@admin2:[ansible-datacenter](master)$ . /opt/openstack/bin/activate
(openstack) administrator@admin2:[ansible-datacenter](master)$ which openstack
/opt/openstack/bin/openstack
(openstack) administrator@admin2:[ansible-datacenter](master)$
(openstack) administrator@admin2:[ansible-datacenter](master)$ . /etc/kolla/admin-openrc.sh
(openstack) administrator@admin2:[ansible-datacenter](master)$ openstack console log show demo1 | tail -40
Cores/Sockets/Threads: 1/1/1
Virt-type:
RAM Size: 488MB
Disks:
NAME  MAJ:MIN       SIZE LABEL         MOUNTPOINT
vda   253:0   1073741824
vda1  253:1   1064287744 cirros-rootfs /
vda15 253:15     8388608
=== sshd host keys ===
-----BEGIN SSH HOST KEY KEYS-----
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxh8RQhRvgWRq39ypdt9Kh4mCciaPn6BsVQY6HKLQt6eDpt9DQoK2ADKoj8Imf1YtsmTP0SV8zb9PdhOPYYAWzWQ2ckElBhed4/+Vl0QrnudY0bRI9XWBmj549B+J4yk1LaossI3Yp0XIBA5dKhsk9pc9+Cah+k5uYRjO9XBdS2Q9bdofGiMe5rofw5f77BrAgywAA1rRw4r8w4fOjrCmOJh+YY7XTX/FRXizVULwYaJVAPHhQL+rUCTxjJ+i4P4RaLOP3dgJGGRpf7+305B5RI8iSehAvEkXGiHuiFI//b7f0nYdXlZXevsaPNMUxER/eqkAPAnjeXqaiND5zcjFz root@demo1
ssh-dss AAAAB3NzaC1kc3MAAACBANbpJAL3LJ/AmlXvTnCie8BHZy2RbuLggnZk8GWKN0yN3w/luJz8gxlzJvZfbTl39Q59Kt29RVLP3ekP5lL+H6tHwqr/q3Ytp8YXjl4K8yRt6aSGJd0Y2urscs+YkgGR4KbW5EfQZ4GJxN+OHNdIhVKF5+q33mR/N+QBQ/N8Mb67AAAAFQDOBqNIDWaw1sbabeswAeYBb2PaLwAAAIA0USWOBnsBldOI4S0zJBGy6SApAjV0EoPpZ7rVcyG+Ap3Qybnxniw0yMD6j4mhiD0ZDn40q3ycPNytHUslwCw98S/Td90Unu2G/J8GZLijX5NYGiR6K7HFwm4F9kaWzzihbcwYhErRV79GMrdaentJ8sbPvPmOvLcqrvuG6DNBNgAAAIAwgMw2n7dGq4PemoqkUr7rUeR+k5rJZZ/NN+d94nO1+Rh1p11oGf3QBupXRgd6t8WWTLtdxGW9/qA04XcXEE6O8tBFj3mugiHm6lR2UBEYj41aaqCrQe2LD9mVlBUA3rCY730yhR8YODRAUQrfIYr6TMK5DjJ1MgKkEpspQqVUxQ== root@demo1
-----END SSH HOST KEY KEYS-----
=== network info ===
if-info: lo,up,127.0.0.1,8,,
if-info: eth0,up,10.0.0.230,24,fe80::f816:3eff:fe63:37a4/64,
ip-route:default via 10.0.0.1 dev eth0
ip-route:10.0.0.0/24 dev eth0  src 10.0.0.230
ip-route:169.254.169.254 via 10.0.0.2 dev eth0
ip-route6:fe80::/64 dev eth0  metric 256
ip-route6:unreachable default dev lo  metric -1  error -101
ip-route6:ff00::/8 dev eth0  metric 256
ip-route6:unreachable default dev lo  metric -1  error -101
=== datasource: ec2 net ===
instance-id: i-00000001
name: N/A
availability-zone: nova
local-hostname: demo1.novalocal
launch-index: 0
=== cirros: current=0.4.0 uptime=9.16 ===
  ____               ____  ____
 / __/ __ ____ ____ / __ \/ __/
/ /__ / // __// __// /_/ /\ \
\___//_//_/  /_/   \____/___/
   http://cirros-cloud.net


login as 'cirros' user. default password: 'gocubsgo'. use 'sudo' for root.
demo1 login: /dev/root resized successfully [took 5.36s]
[   27.176026] random: nonblocking pool is initialized
(openstack) administrator@admin2:[ansible-datacenter](master)$

```

From the controller host - ping/ssh to the VM:

```bash
openstack router list
NETNS_QROUTER_ID=qrouter-$(openstack router list | awk '/admin-router/ {print $2}')
NETNS_QROUTER_ID=$(ip netns ls | awk '/qrouter/ {print $1}')
NETNS_QROUTER_ID=$(ip netns ls | awk '/qrouter/ {print $1}' | head -1)
NETNS_QROUTER_ID=$(ip netns ls | awk '/qrouter/ {print $1}' | tail -1)
NETNS_QDHCP_ID=$(ip netns ls | awk '/qdhcp/ {print $1}')
echo "NETNS_QROUTER_ID=${NETNS_QROUTER_ID}"
ip netns exec ${NETNS_QROUTER_ID} ping 1.1.1.1
ip netns exec ${NETNS_QROUTER_ID} ping 10.0.0.230
ip netns exec ${NETNS_QROUTER_ID} ssh cirros@10.0.0.230
ip netns exec ${NETNS_QROUTER_ID} ssh ubuntu@192.168.30.66

ip netns exec ${NETNS_QROUTER_ID} ip a
ip netns exec ${NETNS_QROUTER_ID} ip link
ip netns exec ${NETNS_QROUTER_ID} route -n
ip netns exec ${NETNS_QROUTER_ID} iptables -L -t nat
ip netns exec ${NETNS_QROUTER_ID} ping 1.1.1.1

ip netns exec ${NETNS_QDHCP_ID} ip a
ip netns exec ${NETNS_QDHCP_ID} ip link
ip netns exec ${NETNS_QDHCP_ID} route -n

ip netns exec ${NETNS_QROUTER_ID} ping 193.168.0.183
ip netns exec ${NETNS_QROUTER_ID} ping 10.0.0.230
ip netns exec ${NETNS_QROUTER_ID} ssh cirros@10.0.0.230

```


```bash
root@node01:[network-scripts]$
root@node01:[network-scripts]$ ip netns ls
qrouter-35d7155e-5608-44cc-91e6-0b8271c3ae5d (id: 6)
qdhcp-02c07974-ebb8-47b2-82fe-0131ba2e46d2 (id: 5)
root@node01:[network-scripts]$
root@node01:[network-scripts]$ ip netns exec qrouter-35d7155e-5608-44cc-91e6-0b8271c3ae5d ping 1.1.1.1
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
From 192.168.0.183 icmp_seq=1 Destination Host Unreachable
From 192.168.0.183 icmp_seq=2 Destination Host Unreachable
From 192.168.0.183 icmp_seq=3 Destination Host Unreachable
From 192.168.0.183 icmp_seq=4 Destination Host Unreachable
^C
--- 1.1.1.1 ping statistics ---
5 packets transmitted, 0 received, +4 errors, 100% packet loss, time 4000ms
pipe 4
root@node01:[network-scripts]$

root@node01:[network-scripts]$ ip netns exec qrouter-35d7155e-5608-44cc-91e6-0b8271c3ae5d ssh cirros@10.0.0.230
The authenticity of host '10.0.0.230 (10.0.0.230)' can't be established.
ECDSA key fingerprint is SHA256:ovm0EMg9TKV4XF8RmgMRiC6fzwsY9LpPaAlDrrg0+V4.
ECDSA key fingerprint is MD5:59:16:ed:3a:aa:84:07:c1:65:53:22:4b:ef:36:c1:44.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '10.0.0.230' (ECDSA) to the list of known hosts.
$
ip -4 a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue qlen 1
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc pfifo_fast qlen 1000
    inet 10.0.0.230/24 brd 10.0.0.255 scope global eth0
       valid_lft forever preferred_lft forever
$
$
ip l
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc pfifo_fast qlen 1000
    link/ether fa:16:3e:63:37:a4 brd ff:ff:ff:ff:ff:ff
$
ping -c 1 google.com
^C
exit
root@node01:[network-scripts]$ 
root@node01:[network-scripts]$ 
root@node01:[network-scripts]$ ip route add 10.0.0.0/24 dev cloudbr1
root@node01:[network-scripts]$ ping 10.0.0.130

root@node01:[network-scripts]$ ip a | grep -e mgtbr0 -e cloudbr0 -e cloudbr1
root@node01:[network-scripts]$ ip a | grep -e mgtbr0 -e cloudbr
root@node01:[network-scripts]$ brctl show

root@node01:[network-scripts]$ ip route
root@node01:[network-scripts]$ ip route delete 10.0.0.0/24 dev cloudbr1
root@node01:[network-scripts]$ ip route delete 192.168.0.1/24 dev cloudbr0
root@node01:[network-scripts]$ ip route add 192.168.2.0/24 via 192.168.2.254 dev eth0
root@node01:[network-scripts]$ ip route add 192.168.30.0/24 via 192.168.2.254 dev eth0
root@node01:[network-scripts]$ ip route add 192.168.30.0/24 via 192.168.30.104 dev cloudbr1

## ref: https://doc.ilabt.imec.be/ilabt/virtualwall/tutorials/openstack.html
root@node01:[network-scripts]$ ip route add 192.168.30.0/24 dev cloudbr1

## ref: https://github.com/Murray-LIANG/forgetful/wiki/openstack-kolla-ansible
#root@node01:[network-scripts]$ ip addr add 192.168.30.1/16 brd 192.168.255.255 dev cloudbr1
#root@node01:[network-scripts]$ ip addr add 192.168.30.1/24 brd 192.168.30.255 dev cloudbr1
root@node01:[network-scripts]$ ip route add 192.168.30.0/24 brd 192.168.30.255 dev cloudbr1

## flush cache if necessary - usually after delete route but route remains in cache
## ref: https://linoxide.com/how-tos/how-to-flush-routing-table-from-cache/
ip route flush cache

ip addr add 192.168.30.0/24 brd 192.168.30.255 dev cloudbr1

ip addr add 192.168.0.250 dev mgtbr0
ip addr add 192.168.0.250 brd 192.168.0.255 dev mgtbr0

## ref: https://www.cyberciti.biz/faq/ip-route-add-network-command-for-linux-explained/
root@node01:[network-scripts]$ ip route add 192.168.30.0/24 via 192.168.30.148 dev cloudbr1

root@node01:[network-scripts]$ ip route
root@node01:[network-scripts]$ route -n
root@node01:[network-scripts]$ iptables -L
root@node01:[network-scripts]$ arp
root@node01:[network-scripts]$ tcpdump -i cloudbr1 -n ip proto gre
root@node01:[network-scripts]$ tcpdump -i cloudbr0 -n ip proto gre
root@node01:[network-scripts]$ tcpdump -i cloudbr1 -n arp or icmp
root@node01:[network-scripts]$ ip netns list

root@node01:[network-scripts]$ ip route get 192.168.30.104
root@node01:[network-scripts]$ ip route get 1.1.1.1

root@node01:[network-scripts]$ ip netns
root@node01:[network-scripts]$ NETNS_QROUTER_ID=$(ip netns ls | awk '/qrouter/ {print $1}')
root@node01:[network-scripts]$ NETNS_QDHCP_ID=$(ip netns ls | awk '/qdhcp/ {print $1}')
root@node01:[network-scripts]$ echo "NETNS_QROUTER_ID=${NETNS_QROUTER_ID}"
root@node01:[network-scripts]$ echo "NETNS_QDHCP_ID=${NETNS_QDHCP_ID}"

root@node01:[network-scripts]$ ip netns exec ${NETNS_QROUTER_ID} ip a
root@node01:[network-scripts]$ ip netns exec ${NETNS_QROUTER_ID} ip link
root@node01:[network-scripts]$ ip netns exec ${NETNS_QROUTER_ID} route -n
root@node01:[network-scripts]$ ip netns exec ${NETNS_QROUTER_ID} iptables -L -t nat
root@node01:[network-scripts]$ ip netns exec ${NETNS_QROUTER_ID} ping 1.1.1.1

root@node01:[network-scripts]$ ip netns exec ${NETNS_QROUTER_ID} ping 193.168.0.183
root@node01:[network-scripts]$ ip netns exec ${NETNS_QROUTER_ID} ping 10.0.0.230
root@node01:[network-scripts]$ ip netns exec ${NETNS_QROUTER_ID} ssh cirros@10.0.0.230

root@node01:[network-scripts]$ ip netns exec ${NETNS_QROUTER_ID} ip route get 192.168.0.1
root@node01:[network-scripts]$ ip netns exec ${NETNS_QROUTER_ID} ip route get 1.1.1.1

```

Debugging OVS router:

```bash

root@node01:[network-scripts]$ docker ps | grep openvswitch
root@node01:[network-scripts]$ docker exec -it openvswitch_vswitchd bash
(openvswitch-vswitchd)[root@node01 /]#
(openvswitch-vswitchd)[root@node01]# ovs-vsctl list-br
(openvswitch-vswitchd)[root@node01]# ovs-vsctl show
(openvswitch-vswitchd)[root@node01]# list-ports br-ex
(openvswitch-vswitchd)[root@node01]# list-ports br-int
(openvswitch-vswitchd)[root@node01]# list-ports br-tun
(openvswitch-vswitchd)[root@node01]# list-br
(openvswitch-vswitchd)[root@node01]# list-ports br-ex
(openvswitch-vswitchd)[root@node01]# list-ports br-tun
(openvswitch-vswitchd)[root@node01]# list-ports br-int

(openvswitch-vswitchd)[root@node01]# cd /var/log/kolla/neutron
(openvswitch-vswitchd)[root@node01 neutron]# pwd
/var/log/kolla/neutron
(openvswitch-vswitchd)[root@node01]# ovs-vsctl show
(openvswitch-vswitchd)[root@node01]# ll /etc
(openvswitch-vswitchd)[root@node01]# alias la='ls -alrt'
(openvswitch-vswitchd)[root@node01]# la /etc
(openvswitch-vswitchd)[root@node01]# la /etc/openvswitch/
(openvswitch-vswitchd)[root@node01]# cat /etc/openvswitch/default.conf
(openvswitch-vswitchd)[root@node01]# ll /var/lib/kolla/
(openvswitch-vswitchd)[root@node01]# ll /var/lib/kolla/config_files/
(openvswitch-vswitchd)[root@node01]# cd /var/log/kolla/
(openvswitch-vswitchd)[root@node01]# cd openvswitch/
(openvswitch-vswitchd)[root@node01]# la
(openvswitch-vswitchd)[root@node01]# tail -50 ovs-vswitchd.log
(openvswitch-vswitchd)[root@node01]# tail -50 ovsdb-server.log
(openvswitch-vswitchd)[root@node01]# cd /var/log/kolla/
(openvswitch-vswitchd)[root@node01]# la
(openvswitch-vswitchd)[root@node01]# cd neutron/
(openvswitch-vswitchd)[root@node01]# la
(openvswitch-vswitchd)[root@node01]# tail -50 neutron-openvswitch-agent.log
(openvswitch-vswitchd)[root@node01]# la
(openvswitch-vswitchd)[root@node01]# tail -50 neutron-server.log
(openvswitch-vswitchd)[root@node01]# tail -100 neutron-server.log
(openvswitch-vswitchd)[root@node01]# tail -200 neutron-server.log | more
(openvswitch-vswitchd)[root@node01]# tail -200 neutron-server.log | more
(openvswitch-vswitchd)[root@node01]# la
(openvswitch-vswitchd)[root@node01]# tail -50 dnsmasq.log
(openvswitch-vswitchd)[root@node01]# tail -50 neutron-l3-agent.log

```

Running OVS related diagnostic checks:

    ref: https://ask.openstack.org/en/question/111420/how-does-kolla-configure-br-ex/
    ref: https://www.reddit.com/r/openstack/comments/99lpr3/the_vms_cannot_access_the_internet_after/

```bash
root@node01:[network-scripts]$ docker ps | grep openvswitch
root@node01:[network-scripts]$ docker exec openvswitch_vswitchd ovs-vsctl list-br
br-ex
br-int
br-tun
root@node01:[network-scripts]$ docker exec openvswitch_vswitchd ovs-vsctl list-ports br-ex
cloudbr1
phy-br-ex
root@node01:[network-scripts]$ docker exec openvswitch_vswitchd ovs-vsctl list-ports br-tun
patch-int
root@node01:[network-scripts]$ docker exec openvswitch_vswitchd ovs-vsctl list-ports br-int
int-br-ex
patch-tun
qg-5406b94d-35
qr-1acb5c57-98
tap2656db8c-83
root@node01:[network-scripts]$ 



```

OVS configure bridge logic:

    https://github.com/openstack/kolla/blob/master/docker/openvswitch/openvswitch-db-server/ovs_ensure_configured.sh


Very useful Network Debug command list:

	ref: https://kashyapc.fedorapeople.org/virt/openstack/neutron/neutron-diagnostics.html

Neutron networks info
On Controller node:

```
docker exec -it neutron_server bash
neutron net-list
neutron subnet-list
neutron net
neutron port-list
neutron router-list
```

IP and route info
On Controller node & Compute nodes:

```
ip addr
route -n
iptables -L
cat /etc/sysconfig/iptables
iptables -nL
```

Network Namespaces
On controller node (assuming all Neutron services are running), commands look like:

```
ip netns
NETNS_QROUTER_ID=$(ip netns ls | awk '/qrouter/ {print $1}')
NETNS_QDHCP_ID=$(ip netns ls | awk '/qdhcp/ {print $1}')
echo "NETNS_QROUTER_ID=${NETNS_QROUTER_ID}"
echo "NETNS_QDHCP_ID=${NETNS_QDHCP_ID}"

ip netns exec ${NETNS_QROUTER_ID} ip a
ip netns exec ${NETNS_QROUTER_ID} ip link
ip netns exec ${NETNS_QROUTER_ID} route -n
ip netns exec ${NETNS_QROUTER_ID} iptables -L -t nat
ip netns exec ${NETNS_QROUTER_ID} ping 1.1.1.1

ip netns exec ${NETNS_QDHCP_ID} ip a
ip netns exec ${NETNS_QDHCP_ID} ip link
ip netns exec ${NETNS_QDHCP_ID} route -n

ip netns exec ${NETNS_QROUTER_ID} ping 193.168.0.183
ip netns exec ${NETNS_QROUTER_ID} ping 10.0.0.230
ip netns exec ${NETNS_QROUTER_ID} ssh cirros@10.0.0.230
```

Obvious note, Substitute the 'UUID' value accordingly. I omitted it here for brevity.

Open vSwitch info - OVS db and datapath contents
On both Controller & Compute nodes:

```
docker exec -it openvswitch_vswitchd bash
ovs-vsctl show
ovs-dpctl show
ovs-dpctl dump-flows
ovs-ofctl dump-flows br-tun
ovs-ofctl dump-flows br-tun table=21
ovs-ofctl dump-flows br-int
```

tcpdump diagnostics
On various network devices in play:: OVS bridges, linux bridges, tap devices and veth pairs on compute host, qr, qg interfaces inside network namespaces, physical interfaces, etc.

Some sample commands on various interfaces (not all corner cases are included):

```
#EXT_NET_DEV=eth0
EXT_NET_DEV=cloudbr1

tcpdump -envi ${EXT_NET_DEV} | grep -i gre

# Run tcpdump on physical link used by GRE tunnels (on Controller
# node). This may isolate the problem to the compute node or the
# network node.
tcpdump -i ${EXT_NET_DEV} -n ip proto gre

tcpdump -envi br-int
tcpdump -envi br-tun

NETNS_QROUTER_ID=$(ip netns ls | awk '/qrouter/ {print $1}')
ip netns exec ${NETNS_QROUTER_ID} ip link
## get the two interface names (internal/external) from last command for next 2 commands
ip netns exec ${NETNS_QROUTER_ID} tcpdump -nn -i qr-63ea2815-b5 icmp
ip netns exec ${NETNS_QROUTER_ID} tcpdump -nn -i qg-e7110dba-a9 icmp

QR_INTID=$(ip netns exec ${NETNS_QROUTER_ID} ip a | awk '/: qr-/ {print $2}')
QG_INTID=$(ip netns exec ${NETNS_QROUTER_ID} ip a | awk '/: qg-/ {print $2}')
QR_INTID=${QR_INTID::-1}
QG_INTID=${QG_INTID::-1}
echo "QR_INTID=${QR_INTID}"
echo "QG_INTID=${QG_INTID}"

ip netns exec ${NETNS_QROUTER_ID} tcpdump -nn -i ${QR_INTID} icmp
ip netns exec ${NETNS_QROUTER_ID} tcpdump -nn -i ${QG_INTID} icmp

tcpdump -envi 192.168.122.163
tcpdump -envi br-ex
tcpdump -i ${EXT_NET_DEV} -n arp or icmp
tcpdump -i ${EXT_NET_DEV} -ne ip proto 47
tcpdump -i br-ex -n icmp
tcpdump -i ${EXT_NET_DEV} -n icmp
tcpdump -i any  -n icmp
tcpdump -i tape7110dba-a9 -n icmp
tcpdump -envi ${EXT_NET_DEV} -n arp or icmp
tcpdump -i ${EXT_NET_DEV} -n not port 22
tcpdump -i ${EXT_NET_DEV} -n not port 22 and not port amqp
```

On physical host:

```
# Check traffic from Compute host (which is running on
# 192.169.142.49)
tcpdump -nn -i virbr1 host 192.169.142.49
```

To debug OVS network:

```bash
arp
brctl show

cd /etc/kolla/neutron-openvswitch-agent/
cd /etc/kolla/neutron-server/
cd /etc/kolla/openvswitch-vswitchd/
cd /etc/sysconfig/network-scripts/
cd /home/adminuser/docker/
cd /var/log/kolla/neutron

cat /var/log/kolla/neutron/ml2_conf.ini

docker exec -it neutron_openvswitch_agent bash
docker exec -it neutron_server bash
docker exec -it openvswitch_vswitchd bash
docker images -a --filter "label=kolla_version"
docker images -a --filter "label=kolla_version" --format "{{.ID}}"
docker info|grep -i runtime
docker network ls
docker network create traefik-public
docker node ls
docker ps

. ~/.local/bin/set_ovs_netenvs.sh

ip a
ip addr add 192.168.30.0/24 brd 192.168.30.255 dev cloudbr1
ip addr add 192.168.30.1/16 brd 192.168.255.255 dev cloudbr1
ip addr add 192.168.0.5/16 dev cloudbr1
ip addr add brd 192.168.30.255 dev cloudbr1

ip a | grep 192.168.0
ip a | grep 192.168.10
ip a | grep -e mgt -e cloudbr
ip link ls
ip netns
ip netns exec cloudbr1 ip link
ip netns exec ${NETNS_QDHCP_ID} exec route -n
ip netns exec ${NETNS_QDHCP_ID} ip a
ip netns exec ${NETNS_QDHCP_ID} ip link
ip netns exec ${NETNS_QDHCP_ID} route -n

ip netns exec ${NETNS_QROUTER_ID} arp -an
ip netns exec ${NETNS_QROUTER_ID} ip a
ip netns exec ${NETNS_QROUTER_ID} ip a | awk '/: qr-/ {print $2}'
ip netns exec ${NETNS_QROUTER_ID} ip a | awk '/: qg-/ {print $2}'
ip netns exec ${NETNS_QROUTER_ID} ip link
ip netns exec ${NETNS_QROUTER_ID} ip link list
ip netns exec ${NETNS_QROUTER_ID} ip link set dev ${QR_INTID} up
ip netns exec ${NETNS_QROUTER_ID} ip link set dev ${QG_INTID} up
ip netns exec ${NETNS_QROUTER_ID} ip route add 192.168.30.0/24 dev ${QG_INTID}
ip netns exec ${NETNS_QROUTER_ID} ip route delete 192.168.30.0/24 dev ${QG_INTID}
ip netns exec ${NETNS_QROUTER_ID} ip route delete 192.168.30.0
ip netns exec ${NETNS_QROUTER_ID} ip route delete 192.168.30.0/24
ip netns exec ${NETNS_QROUTER_ID} ip route list
ip netns exec ${NETNS_QROUTER_ID} ip route show
ip netns exec ${NETNS_QROUTER_ID} ip show route
ip netns exec ${NETNS_QROUTER_ID} iptables -L -t nat
ip netns exec ${NETNS_QROUTER_ID} netstat -rn
ip netns exec ${NETNS_QROUTER_ID} ping 10.0.0.1
ip netns exec ${NETNS_QROUTER_ID} ping 10.0.0.158
ip netns exec ${NETNS_QROUTER_ID} ping 10.0.0.2
ip netns exec ${NETNS_QROUTER_ID} ping 1.1.1.1
ip netns exec ${NETNS_QROUTER_ID} ping 192.168.0.1
ip netns exec ${NETNS_QROUTER_ID} ping 192.168.30.1
ip netns exec ${NETNS_QROUTER_ID} ping 192.168.30.115
ip netns exec ${NETNS_QROUTER_ID} ping 192.168.30.150
ip netns exec ${NETNS_QROUTER_ID} ping 193.168.0.1
ip netns exec ${NETNS_QROUTER_ID} ping 193.168.0.183
ip netns exec ${NETNS_QROUTER_ID} ping google,com
ip netns exec ${NETNS_QROUTER_ID} ping google.com
ip netns exec ${NETNS_QROUTER_ID} route -n
ip netns exec ${NETNS_QROUTER_ID} tcpdump -nn arp or icmp
ip netns exec ${NETNS_QROUTER_ID} tcpdump -nn -i ${QG_INTID} icmp
ip netns exec ${NETNS_QROUTER_ID} tcpdump -nn -i ${QR_INTID} arp or icmp
ip netns exec ${NETNS_QROUTER_ID} tcpdump -nn -i ${QR_INTID} icmp
ip netns list
ip netns ls
ip netns ls | awk '/qrouter/ {print $1}'
ip netns ${NETNS_ID} exec ip link
ip netns ${NETNS_ID} ip a
ip netns ${NETNS_ID} ip s

ip route
ip route add 0.0.0.0/24 via 192.168.0.1 dev cloudbr1
ip route add 0.0.0.0 default gw 192.168.0.1 dev cloudbr1
ip route add 192.168.0.0/24 dev cloudbr1
ip route add 192.168.0.0/24 via 192.168.0.1 dev cloudbr1
ip route add 192.168.0.0/24 via 192.168.30.148 dev cloudbr1
ip route add 192.168.30.0/24 brd 192.168.255.255 dev cloudbr1
ip route add 192.168.30.0/24 brd 192.168.30.255 dev cloudbr1
ip route add 192.168.30.0/24 dev cloudbr1
ip route add 192.168.30.0/24 via 192.168.30.104 dev cloudbr1
ip route add 192.168.30.0/24 via 192.168.30.61 dev cloudbr1
ip route add def 0.0.0.0/24 via 192.168.0.1 dev cloudbr1
ip route add default 0.0.0.0/24 via 192.168.0.1 dev cloudbr1
ip route add default 0.0.0.0 gw 192.168.0.1 dev cloudbr1
ip route add default 192.168.30.0/24 dev cloudbr1
ip route add default 192.168.30.104/32 dev cloudbr1
ip route add default gw 192.168.0.1 cloudbr1
ip route add default gw 192.168.0.1 dev cloudbr1
ip route add default via 192.168.0.1
ip route add default via 192.168.0.1 dev cloudbr1
ip route add default via 192.168.0.61 dev cloudbr1
ip route add def gw 192.168.0.1 dev cloudbr1
ip route add gw 192.168.0.1 cloudbr1
ip route add gw 192.168.0.1 dev cloudbr1
ip route delete 169.254.0.0/16
ip route delete 169.254.0.0/16 dev cloudbr1
ip route delete 192.168.0.0/16
ip route delete 192.168.30.0/16
ip route delete 192.168.30.0/24
ip route delete 192.168.30.0/24
ip route delete 192.168.30.0/24 dev cloudbr1
ip route delete 192.168.30.0/24 dev cloudbr1
ip route delete 192.168.30.0/24 via 192.168.30.61 dev cloudbr1
ip route delete default 192.168.30.0
ip route delete default 192.168.30.0/24
ip route delete default 192.168.30.0/24
ip route delete default 192.168.30.0/24 dev cloudbr1
ip route delete dev cloudbr1
ip route flush cache
ip route flush table main
ip route get 192.168.0.1
ip route get 192.168.30.104
ip route get 192.168.30.115
ip route get 8.8.4.4
ip route list
ip route -n
ip route show

iptables -L

NETNS_ID=$(ip netns ls | awk '/qrouter/ {print $1}')
NETNS_QDHCP_ID=$(ip netns ls | awk '/qdhcp/ {print $1}')
NETNS_QROUTER_ID=$(ip netns ls | awk '/qrouter/ {print $1}')
netstat -anlp | grep ":80"

nmcli conn reload
nmcli conn show
nmcli d
nmtui

. /opt/openstack/bin/activate
openstack instance list

ping 10.0.0.1
ping 10.0.0.2
ping 10.10.0.78
ping 192.168.0.1
ping 192.168.0.104
ping 192.168.0.156
ping 192.168.0.183
ping 192.168.0.188
ping 192.168.0.250
ping 192.168.20.2
ping 192.168.30.
ping 192.168.30.1
ping 192.168.30.104
ping 192.168.30.115
ping 192.168.30.152
ping 192.168.30.2
ping 192.168.30.61
ping 192.168.30.89
ping www.google.com
ps -ef | grep docker
ps -U0 -o 'tty,pid,comm' | grep ^?

QG_INTID=$(ip netns exec ${NETNS_QROUTER_ID} ip a | awk '/: qg-/ {print $2}')
QG_INTID=${QG_INTID::-1}
QR_INTID=$(ip netns exec ${NETNS_QROUTER_ID} ip a | awk '/: qr-/ {print $2}')
QR_INTID=${QR_INTID::-1}

readlink -f /var/log/kolla

route add default gw 192.168.0.1 cloudbr1
route -n

systemctl restart docker
systemctl restart network
systemctl restart sshd
systemctl status docker
systemctl status network
systemctl status sshd

tail -40f neutron-l3-agent.log
tail -40f neutron-openvswitch-agent.log
tail -40f neutron-server.log
tail -50f mariadb.log
tail -50f messages

tcpdump -envi 192.168.30.0
tcpdump -envi 192.168.30.1
tcpdump -envi 192.168.30.115
tcpdump -envi 192.168.30.254
tcpdump -envi 192.168.30.255
tcpdump -envi 192.168.30.61
tcpdump -envi br-int
tcpdump -envi br-tun
tcpdump -envi cloudbr1
tcpdump -envi ${EXT_NET_DEV} | grep -i gre
tcpdump -envi ${EXT_NET_DEV} -n arp or icmp
tcpdump -envi ${NETNS_QROUTER_ID} -n arp or icmp
tcpdump -envi ${QR_INTID} -n arp or icmp
tcpdump -envi tap7417a192-87
tcpdump -i cloudbr0 -n arp or icmp
tcpdump -i cloudbr1 -n arp or icmp
tcpdump -i ${EXT_NET_DEV} -n arp or icmp
tcpdump -i ${EXT_NET_DEV} -n ip proto gre
tcpdump -i ${EXT_NET_DEV} -n -s0 -e

virsh list
virsh destroy instance-00000001

which openstack
yum reinstall pam

```

```bash
run-remote.sh 
run-remote.sh ansible -i inventory/hosts.ini all -m ping
run-remote.sh ansible -i inventory/hosts.ini openstack -m ping
run-remote.sh ansible -m ping all
run-remote.sh ansible-playbook site.yml --tags bootstrap-node --limit admin2
run-remote.sh ansible-playbook site.yml --tags bootstrap-node-network --limit node01
run-remote.sh ansible-playbook site.yml --tags bootstrap-node-mounts --limit media
run-remote.sh ansible-playbook site.yml --tags bootstrap-openstack
run-remote.sh ansible-playbook site.yml --tags bootstrap-openstack-cloud
run-remote.sh ansible-playbook site.yml --tags bootstrap-openstack-deploy-node
run-remote.sh ansible-playbook site.yml --tags docker-admin-node
run-remote.sh ansible-playbook site.yml --tags docker-media-node
run-remote.sh ansible-playbook site.yml --tags docker-samba-node
run-remote.sh ansible-playbook site.yml --tags openstack-deploy-node
run-remote.sh ansible-playbook site.yml --tags openstack-osclient
run-remote.sh ansible-playbook site.yml --tags openstack-osclient-post
run-remote.sh bash -x scripts/kolla-ansible/init-runonce.sh
run-remote.sh bash -x scripts/kolla-ansible/test_ovs_network.sh
run-remote.sh bash -x scripts/kolla-ansible/test_ovs_networks.sh
run-remote.sh kolla-ansible -i inventory/hosts-openstack.ini bootstrap-servers
run-remote.sh kolla-ansible -i inventory/hosts-openstack.ini deploy
run-remote.sh kolla-ansible -i inventory/hosts-openstack.ini destroy --yes-i-really-really-mean-it
run-remote.sh kolla-ansible -i inventory/hosts-openstack.ini post-deploy
run-remote.sh kolla-ansible -i inventory/hosts-openstack.ini prechecks
run-remote.sh kolla-ansible -i inventory/hosts-openstack.ini pull
run-remote.sh kolla-ansible -i inventory/hosts-openstack.ini reconfigure
run-remote.sh kolla-ansible -i inventory/hosts-openstack.ini restart
run-remote.sh kolla-ansible -i inventory/hosts-openstack.ini stop
run-remote.sh kolla-ansible -i inventory/hosts-openstack.ini stop --yes-i-really-really-mean-it
run-remote.sh openstack server create --image cirros --flavor m1.tiny --key-name mykey --network demo-net demo1
run-remote.sh scripts/kolla-ansible/init-runonce.sh

gethist | grep run-remote | sort -n | uniq >> NOTES-ANSIBLE.md 
```

Pre-install deployment tools install/setup:

```bash
## ref: https://sudomakeinstall.com/uncategorized/openstack-ansible-kolla-on-centos-7-with-python-virtual-env
##
## perform following on the target node (e.g., node01)
#Install deps
yum install epel-release -y
yum install ansible python-pip python-virtualenv python-devel libffi-devel gcc openssl-devel libselinux-python -y

virtualenv --system-site-packages /opt/openstack/
#virtualenv --python=python3.7 --system-site-packages /opt/openstack

## NOTE: you might need to upgrade virtualenv if getting the following virtualenv requests error:
## ImportError: cannot import name requests
## ref: https://stackoverflow.com/posts/54100356/timeline
#pip install --upgrade virtualenv

source /opt/openstack/bin/activate
pip install -U pip
#Install kolla-ansible for our release
pip install --upgrade kolla-ansible==7.0.0
pip install decorators python-openstackclient
cp -r /opt/openstack/share/kolla-ansible/etc_examples/kolla /etc/
cp -r /opt/openstack/share/kolla-ansible/ansible/inventory/* ~
echo "ansible_python_interpreter: /opt/openstack/bin/python" >> /etc/kolla/globals.yml
kolla-genpwd
```

refs: 

    https://docs.openstack.org/project-deploy-guide/kolla-ansible/latest/quickstart.html
    https://sudomakeinstall.com/uncategorized/openstack-ansible-kolla-on-centos-7-with-python-virtual-env
    https://www.linuxjournal.com/content/build-versatile-openstack-lab-kolla
    https://elatov.github.io/2018/01/openstack-ansible-and-kolla-on-ubuntu-1604/

To get the current config:

    grep -vE '^$|^#' /etc/kolla/globals.yml

Run ping:

    run-remote.sh ansible -i inventory/hosts-openstack.ini openstack -m ping

