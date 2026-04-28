
# Running Ansible Site Plays

This section describes how to run and test the `ansible-datacenter` site plays.

## Run tests from ansible control node

```
echo "foobarpass" > ~/.vault_pass
chmod 600 ~/.vault_pass
ansible-playbook report-windows-facts.yml -i inventory/DEV/hosts.yml -t untagged,report-windows-facts --vault-password-file ~/.vault_pass
```

## Run molecule tests

```shell
$ git clone https://github.com/lj020326/ansible-datacenter.git
$ cd ansible-datacenter
$ export MOLECULE_IMAGE_LABEL=redhat7-systemd-python
$ molecule login
$ molecule --debug test -s bootstrap_linux_package
$ molecule destroy
$ MOLECULE_IMAGE_LABEL=redhat8-systemd-python molecule --debug test -s bootstrap_linux_package
$ MOLECULE_IMAGE_LABEL=redhat8-systemd-python molecule login
$ molecule destroy
$ MOLECULE_IMAGE_LABEL=redhat8-systemd-python molecule converge
$ molecule destroy
$ MOLECULE_IMAGE_LABEL=centos8-systemd-python molecule --debug converge
$ molecule destroy
$ MOLECULE_IMAGE_LABEL=ubuntu2204-systemd-python molecule --debug converge

```

### To log into molecule created container

```shell
$ MOLECULE_IMAGE_LABEL=redhat8-systemd-python molecule create
$ MOLECULE_IMAGE_LABEL=redhat8-systemd-python molecule login
$ molecule destroy
```

## Other useful 

### To run/debug the VM template create playbook on packer created VM

```shell
# find the temp dir used for the ansible-local provisioner from the packer log 
$ cd /tmp/packer-provisioner-ansible-local/63b193ab-d1c4-b355-f4cf-9e9153570896
$ ansible-playbook bootstrap_vm_template.yml --vault-password-file=~/.vault_pass -c local -i vm_template.yml
```

### To run play on a group

```shell
$ ansible-playbook site.yml --tags bootstrap --limit dc_os_Ubuntu
```

### To build ansible control node

```shell
$ ansible-playbook site.yml --tags bootstrap-ansible --limit admin02
```

### To configure samba client node

```shell
$ ansible-playbook site.yml --tags bootstrap-samba-client
```

### To setup/configure linux users

```shell
$ ansible-playbook site.yml --tags bootstrap-user --vault-password-file ~/.vault_pass
```

### Using run-playbook.sh launch script

```shell
$ run-playbook.sh site.yml -t bootstrap-docker-stack -l admin01
$ run-playbook.sh bootstrap-ntp.yml -l testgroup_lnx
```

### To setup/configure iscsi client node

```shell
$ ansible-playbook site.yml --tags iscsi-client
```

## Command Line Usage

### Display/Debug any vars

```shell
ansible-config dump
ansible-config dump |grep DEFAULT_MODULE_PATH

ansible-inventory --graph output -i inventory/
ansible-inventory --graph output -i inventory/ ntp
ansible-inventory --graph output -i inventory/ ntp_server
ansible-inventory --graph output -i inventory/DEV/
ansible-inventory --graph output -i inventory/PROD/ ntp
ansible-inventory -i inventory/ --graph ntp
ansible-inventory -i inventory/DEV/ --graph ntp
ansible-inventory -i inventory/QA/ --graph output
ansible-inventory -i inventory/PROD/ --graph output group
ansible-inventory -i inventory/PROD/ --graph output ntp
ansible-inventory -i inventory/PROD/ --list ntp
ansible-inventory -i inventory/PROD/ntp.yml --graph output
ansible-inventory -i inventory/DEV/site1.yml --graph output

ansible-playbook -i ./inventory display-ntp-servers.yml 
ansible-playbook -i ./inventory/ display-ntp-servers.yml
ansible-playbook -i ./inventory/ playbook.yml
ansible-playbook -i ./inventory/dmz display-ntp-servers.yml 
ansible-playbook -i ./inventory/internal display-ntp-servers.yml
ansible-playbook -i ./inventory/internal display-ntp-servers.yml 

ansible all -m debug -a var=groups['ca_domain']
ansible -i inventory/DEV/hosts.yml  windows -m debug -a var=ansible_port
ansible -i inventory/DEV/hosts.yml  windows -m debug -a var=ansible_winrm_transport
ansible -i inventory/DEV/hosts.yml  windows -m debug -a var=ansible_host,ansible_port
```


### Setup and Run the datacenter playbook roles

## Run playbooks

Run site-setup play:

`ansible-playbook site.yml`

Run site-setup play with a tag:

```
ansible-playbook site.yml --tags docker-media-node
```


Run plays for specific configuration needed

To run ansible commands from ansible/control node:

```shell
ansible -v -m ping
ansible -m ping ubuntu18
ansible all -m debug -a var=groups['ca_domain']
```

Run play for specific node:

```shell
ansible-playbook site.yml --tags display-hostvars --limit admin01
ansible-playbook site.yml --tags install-cacerts --limit media01
```


Run a play for a specific group of nodes:

```shell
ansible-playbook site.yml --tags install-cacerts --limit windows
ansible-playbook site.yml --tags install-cacerts --limit dc_os_ubuntu
ansible-playbook site.yml -t display-hostvars -l dc_os_centos
ansible-playbook site.yml -t display-hostvars -l docker
```

E.g., Run site setup play on control node with a tag from windows/msys shell.

```
ansible-playbook site.yml --tags bootstrap-ansible
ansible-playbook site.yml --tags bootstrap-bind
ansible-playbook site.yml --tags bootstrap-cacert
ansible-playbook site.yml --tags bootstrap-caroot
ansible-playbook site.yml --tags bootstrap-cicd
ansible-playbook site.yml --tags bootstrap-docker-stack
ansible-playbook site.yml --tags bootstrap-idrac
ansible-playbook site.yml --tags bootstrap-jenkins-agent
ansible-playbook site.yml --tags bootstrap-keyring
ansible-playbook site.yml --tags bootstrap-kvm
ansible-playbook site.yml --tags bootstrap-ldap-client
ansible-playbook site.yml --tags bootstrap-linux
ansible-playbook site.yml --tags bootstrap-linux-core
ansible-playbook site.yml --tags bootstrap-docker
ansible-playbook site.yml --tags bootstrap-linux-firewalld
ansible-playbook site.yml --tags configure-linux-firewall
ansible-playbook site.yml --tags bootstrap-mergerfs
ansible-playbook site.yml --tags bootstrap-ntp
ansible-playbook site.yml --tags bootstrap-openstack
ansible-playbook site.yml --tags bootstrap-openstack-cloud
ansible-playbook site.yml --tags bootstrap-postfix
ansible-playbook site.yml --tags bootstrap-proxmox
ansible-playbook site.yml --tags bootstrap-stepcli
ansible-playbook site.yml --tags bootstrap-user
ansible-playbook site.yml --tags bootstrap-vmware-esxi
ansible-playbook site.yml --tags build-docker-images
ansible-playbook site.yml --tags deploy-cacerts
ansible-playbook site.yml --tags deploy-vm
ansible-playbook site.yml --tags deploy-vsphere-dc
ansible-playbook site.yml --tags display-hostvars
ansible-playbook site.yml --tags docker-admin-node
ansible-playbook site.yml --tags docker-control-node
ansible-playbook site.yml --tags docker-media-node
ansible-playbook site.yml --tags docker-samba-node
ansible-playbook site.yml --tags deploy-nfs-service
ansible-playbook site.yml --tags vmware-remount-datastores
ansible-playbook site.yml --tags upgrade-vmware-esxi
```

Setup vsphere dc
```shell
ansible-playbook site.yml --tags deploy-vsphere-dc
```

## Deploy VMs

```shell
ansible-playbook site.yml --tags deploy-vm
```

## Bootstrap VM hosts

```shell
ansible-playbook site.yml --tags bootstrap-linux --limit admin02
```

A jenkins pipeline is responsible for building VM template images used to create VM instances.

The template creation pipeline invokes the `bootstrap-linux` play tag on the newly created virtual machine instance used to create the template.

The VM template build pipeline source is located here [here](https://github.com/lj020326/pipeline-automation-lib/blob/main/vars/buildVmTemplate.groovy).


## Docker stack plays

```shell
ansible-playbook site.yml --tags docker-stack-node --limit docker_stack_prod
## OR to run specific stacks
ansible-playbook site.yml --tags docker-admin-node
ansible-playbook site.yml --tags docker-media-node
```

## Other useful bootstrap plays

Useful `site.yml` tag based plays to build/update/configure datacenter:

```shell
ansible-playbook site.yml --tags bootstrap-bind
ansible-playbook site.yml --tags bootstrap-docker
ansible-playbook site.yml --tags bootstrap-linux-core
ansible-playbook site.yml --tags bootstrap-docker
ansible-playbook site.yml --tags bootstrap-linux-firewalld
ansible-playbook site.yml --tags bootstrap-openstack
ansible-playbook site.yml --tags bootstrap-openstack-cloud
ansible-playbook site.yml --tags bootstrap-user
ansible-playbook site.yml --tags bootstrap-vmware-esxi
ansible-playbook site.yml --tags build-docker-images
ansible-playbook site.yml --tags cacerts-deploy
ansible-playbook site.yml --tags deploy-vm
ansible-playbook site.yml --tags deploy-vsphere-dc
ansible-playbook site.yml --tags display-hostvars
ansible-playbook site.yml --tags docker-admin-node
ansible-playbook site.yml --tags docker-media-node
ansible-playbook site.yml --tags fetch-osimages
ansible-playbook site.yml --tags iscsi-client
ansible-playbook site.yml --tags nfs-service
ansible-playbook site.yml --tags vmware-remount-datastores
ansible-playbook site.yml --tags upgrade-vmware-esxi
ansible-playbook site.yml --tags display-vars -l control01
ansible-playbook site.yml --tags display-domain-vars -l os_linux
ansible-playbook site.yml --tags display-domain-vars -l nas02
ansible-playbook site.yml --tags display-domain-vars -l control01
ansible-playbook site.yml --tags bootstrap-bind
ansible-playbook site.yml --tags bootstrap-cacerts
ansible-playbook site.yml --tags deploy-cacerts
ansible-playbook site.yml --tags docker-control-node
ansible-playbook site.yml --tags docker-admin-node
ansible-playbook site.yml --tags docker-media-node
gethist | grep remote | uniq >> ./README.md 
```

## Example inventory checks

```shell
ansible -v all --list-hosts
ansible -i ./inventory/PROD/hosts.yml -m debug -a var=cacert_keystore_host admin03
ansible -i ./inventory/PROD/hosts.yml -m debug -a var=jenkins_swarm_agent_controller admin01
ansible -i ./inventory/PROD/hosts.yml -m debug -a var=jenkins_swarm_agent_labels admin01
ansible -i ./inventory/PROD/hosts.yml -m debug -a var=jenkins_swarm_agent_controller admin01
ansible -i inventory/ -m debug -a var=service_route_internal_root_domain vcontrol01
ansible -i inventory/ -m debug -a var=ca_domain vcontrol01
ansible -i inventory/ -m debug -a var=service_route_internal_root_domain vcontrol01
ansible -i inventory/hosts.yml -m debug -a var=ca_domain vcontrol01
ansible -i inventory/hosts.yml -m debug -a var=group_names admin01
ansible -i inventory/hosts.yml -m debug -a var=internal_root_domain vcontrol01
ansible -i inventory/hosts.yml -m debug -a var=jenkins_swarm_agent_controller admin01
ansible -i inventory/hosts.yml -m debug -a var=service_route_internal_root_domain vcontrol01
ansible -i inventory/PROD/ -m debug -a var=ansible_host vcenter7
ansible -i inventory/PROD/ -m debug -a var=bootstrap_docker__script_dirs admin03
ansible -i inventory/PROD/ -m debug -a var=bootstrap_docker__swarm_managers admin03
ansible -i inventory/PROD/ -m debug -a var=bootstrap_docker__swarm_remote_addrs admin03
ansible -i inventory/PROD/ -m debug -a var=ca_domain admin01
ansible -i inventory/PROD/ -m debug -a var=ca_domain vcontrol01
ansible -i inventory/PROD/ -m debug -a var=docker_stack_internal_domain admin03
ansible -i inventory/PROD/ -m debug -a var=docker_stack_internal_root_domain admin03
ansible -i inventory/PROD/ -m debug -a var=group_names admin01
ansible -i inventory/PROD/ -m debug -a var=group_names vcenter7
ansible -i inventory/PROD/ -m debug -a var=group_names vcontrol01
ansible -i inventory/PROD/ -m debug -a var=internal_domain vcenter7
ansible -i inventory/PROD/ -m debug -a var=internal_domain vcontrol01
ansible -i inventory/PROD/ -m debug -a var=internal_root_domain vcenter7
ansible -i inventory/PROD/ -m debug -a var=internal_subdomain vcontrol01
ansible -i inventory/PROD/ -m debug -a var=service_route_internal_root_domain admin01
ansible -i inventory/PROD/hosts.yml -m debug -a var=jenkins_swarm_agent_controller admin01
ansible-inventory --help
ansible-inventory -h
ansible-inventory -i ./inventory/PROD/hosts.yml --graph 
ansible-inventory -i inventory/PROD/ --graph vmware_vcenter
```

## Example test playbook runs

```shell
## for control node certs - skip apply_ping_test
$ runme.sh -t bootstrap-ca-certs -l ca_keystore site.yml
$ runme.sh -t deploy-ca-certs --skip-tags=always site.yml
## no vault ca certs setup
$ runme.sh -t bootstrap-certs -l ca_keystore site.yml
$ runme.sh -t deploy-certs --skip-tags=always -l admin01 site.yml
$ runme.sh -t bootstrap-linux -l admin01 site.yml
$ runme.sh -t bootstrap-pip -l admin01 site.yml
$ runme.sh -t bootstrap-webmin -l admin01 site.yml
$ runme.sh -t bootstrap-docker -l admin01 site.yml
$ runme.sh -t bootstrap-docker-stack -l admin01 site.yml
$ runme.sh -t bootstrap-docker-stack -l docker_stack_control site.yml
$ runme.sh -t bootstrap-docker-stack -l docker_stack_openldap site.yml
$ runme.sh -t bootstrap-docker-stack -l docker_stack_jenkins_jcac site.yml
$ runme.sh -t bootstrap-docker-stack -l docker_stack_media site.yml
$ runme.sh -t bootstrap-jenkins-agent -l admin01 site.yml
$ runme.sh -vvv -t bootstrap-docker -l admin01 site.yml
```

## Using run-ansible.sh launch script

Using the run-ansible.sh script to automatically first install all dependencies then run the command

The [run-ansible.sh script](run-ansible.sh) is available that upon execution will: 

1) install [collection requirements](collections/requirements.yml), 
2) prints debug
3) start ssh agent
4) adds necessary ansible arguments (includes necessary playbook vaulted vars and vault credential)
5) runs the command specified

```shell
$ run-ansible.sh ansible -m win_ping -v win2012-01
$ run-ansible.sh ansible -i ./inventory/PROD -m win_shell -a "ipconfig" -v win2012-01
$ run-ansible.sh ansible-playbook --tags ping-test -l ca_domain site.yml
$ run-ansible.sh ansible-playbook --tags bootstrap-ansible-user -l control01 site.yml
$ run-ansible.sh ansible-playbook --tags bootstrap-ansible-user -l media01 site.yml
$ run-ansible.sh ansible-playbook --tags bootstrap-docker-stack -l media01 site.yml
$ run-ansible.sh ansible-playbook --tags bootstrap-linux -l control01 site.yml
$ run-ansible.sh ansible-playbook --tags bootstrap-linux -l media01 site.yml
$ run-ansible.sh ansible-playbook -i inventory/PROD/hosts.yml --tags bootstrap-mounts -l media01 site.yml
$ run-ansible.sh ansible-playbook -i inventory/PROD/hosts.yml --tags bootstrap-registry -l media01 site.yml
$ run-ansible.sh ansible-playbook -i inventory/PROD/hosts.yml --tags bootstrap-user -l control01 site.yml
$ run-ansible.sh ansible-playbook -i inventory/PROD/hosts.yml --tags bootstrap-user -l media01 site.yml
## install collections
$ INSTALL_GALAXY_COLLECTIONS=1 run-ansible.sh ansible-playbook site.yml --tags bootstrap-docker -l control01
## update collections
$ UPGRADE_GALAXY_COLLECTIONS=1 run-ansible.sh ansible-playbook site.yml --tags bootstrap-jenkins-agent -l control02
## if need to force update of collection(s) - usually in case where a specific collection version has been updated
$ FORCE_GALAXY_COLLECTIONS=1 UPGRADE_GALAXY_COLLECTIONS=1 run-ansible.sh ansible-playbook --tags bootstrap-docker-control -l control02 site.yml
```

## Openstack plays

```shell
ansible -i inventory/hosts.yml openstack -m ping
ansible -i inventory/hosts-openstack.ini openstack -m ping

ansible-playbook site.yml --tags bootstrap-linux --limit os_linux
ansible-playbook site.yml --tags bootstrap-linux-firewalld --limit vmub2201
ansible-playbook site.yml --tags bootstrap-docker --limit docker
ansible-playbook site.yml --tags bootstrap-network --limit node01
ansible-playbook site.yml --tags bootstrap-openstack
ansible-playbook site.yml --tags bootstrap-openstack-deploy-node
ansible-playbook site.yml --tags bootstrap-user --limit ubuntu18
ansible-playbook site.yml --tags openstack-deploy-node
ansible-playbook site.yml --tags openstack-osclient

kolla-ansible -v -i inventory/hosts-openstack.ini bootstrap-servers
kolla-ansible -v -i inventory/hosts-openstack.ini prechecks
kolla-ansible -v -i inventory/hosts-openstack.ini deploy
kolla-ansible -v -i inventory/hosts-openstack.ini post-deploy

```

### Openstack host instance cleanup/destroy/reset

```shell
kolla-ansible -v -i inventory/hosts-openstack.ini destroy
kolla-ansible -v -i inventory/hosts-openstack.ini destroy --yes-i-really-really-mean-it

```

### Openstack env setup

```shell
scripts/kolla-ansible/init-runonce.sh
ansible-playbook site.yml --tags bootstrap-openstack-cloud
openstack server create --image cirros --flavor m1.tiny --key-name mykey --network demo-net demo1

```

### Other useful openstack related plays

```shell
ansible-playbook site.yml --tags bootstrap-linux-mounts --limit os_linux
ansible-playbook site.yml --tags bootstrap-linux-mounts --limit dc_os_centos_7
ansible-playbook site.yml --tags bootstrap-linux-mounts --limit postgres
ansible-playbook site.yml --tags bootstrap-linux-mounts --limit media
ansible-playbook site.yml --tags bootstrap-openstack
ansible-playbook site.yml --tags bootstrap-openstack-cloud
ansible-playbook site.yml --tags bootstrap-openstack-deploy-node
```

## .Openstack bootstrap plays

```shell
#ansible-playbook site.yml --tags openstack-deploy-node
ansible-playbook site.yml --tags bootstrap-openstack
kolla-ansible -i inventory/hosts-openstack.ini bootstrap-servers
kolla-ansible -i inventory/hosts-openstack.ini prechecks
kolla-ansible -i inventory/hosts-openstack.ini deploy

## running post-deploy creates the /etc/kolla/openrc.sh
## ref: https://github.com/lj020326/kolla-ansible/blob/main/ansible/post-deploy.yml
kolla-ansible -i inventory/hosts-openstack.ini post-deploy

## setup osclient configs if necessary
## NOTE: not necessary to run this since it is included in bootstrap-openstack-cloud play
#ansible-playbook site.yml --tags openstack-osclient

openstack image list
openstack service list
openstack network list
openstack router list
openstack server list
openstack compute service list
openstack dns service list
openstack zone list

## if the above works - then can run custom cloud config
ansible-playbook site.yml --tags bootstrap-openstack-cloud

## to reconfigure kolla-ansible configure based on latest changes
kolla-ansible -i inventory/hosts-openstack.ini reconfigure

## to reconfigure a specific service, e.g., nova, neutron, etc
kolla-ansible -i inventory/hosts-openstack.ini reconfigure --tags nova
docker ps -f name=compute

kolla-ansible -i inventory/hosts-openstack.ini reconfigure --tags neutron
docker ps -f name=neutron

kolla-ansible -i inventory/hosts-openstack.ini reconfigure --tags designate
docker ps -f name=designate

#openstack zone create --email admin@openstack.example.int openstack.example.int.
openstack zone create --email admin@example.int openstack.example.int.


## or per (https://ask.openstack.org/en/question/113699/kolla-ansible-how-to-managemodify-configuration-files/)
kolla-ansible -i inventory/hosts-openstack.ini genconfig ## (and restart manually the containers)

./inventory/openstack_inventory.py --list

## to destroy/reset everything back to the beginning for the inventory:
kolla-ansible -i inventory/hosts-openstack.ini destroy --yes-i-really-really-mean-it

```

## Other useful connectivity tests

```shell
ansible -u administrator -e ansible_password=${ANSIBLE_SSH_PASSWORD} -m ping ubuntu18
ansible -v -u administrator -e ansible_password=${ANSIBLE_SSH_PASSWORD} -e ansible_pyth/bin/python3 -i inventory/hosts.yml -m ping ubuntu18
```
