
ansible-datacenter
------

This is an ansible playbook that will configure your datacenter based on roles on Ubuntu/Centos linux servers.

Prerequisites
-------------

1.  Clone this Ansible deployment playbook
```
git clone https://github.com/lj020326/ansible-datacenter.git
```

2. Setup galaxy roles to be used: *This is internally performed by run-remote.sh script if using to run on remote ansible/control node

```
ansible-galaxy install --force -r requirements.yml
```

3. Add host info to hosts.ini inventory and ping the nodes

```bash
ansible -i inventory/hosts.ini all -m ping -b -vvvv
```

4. Create the vault file used to protect important data in source control.
    For more information go here (http://docs.ansible.com/playbooks_vault.html)

The vault file used has to have the name private_vars.yml. Ensure your editor environment variable is set or it defaults to vim.

    # create private file
    ansible-vault create vars/secrets.yml

Running the command above will ask you for a password to encrypt with, and open an editor. In that file set the variables highlighted in the secrets.yml.example file.


Usage
-----

# Setup and Run the datacenter playbook roles

## Run playbooks

Run site-setup play:

`ansible-playbook site.yml`

Run site-setup play with a tag:

```
ansible-playbook site.yml --tags docker-media-node
```


Run plays for specific configuration needed

Use run-remote.sh to run ansible commands from a remote ansible/control node:

```bash
run-remote.sh ansible -v -m ping
run-remote.sh ansible -m ping ubuntu18
```

Run a simple play test

```bash
run-remote.sh ansible-playbook site.yml --tags display-hostvars --limit admin01
```

Run a play for a specific group of nodes:

```bash
run-remote.sh ansible-playbook site.yml -t display-envvars -e "pattern=os_CentOS"
```

E.g., Run site setup play on control node with a tag from windows/msys shell.

```
run-remote.sh ansible-playbook site.yml --tags deploy-vm
run-remote.sh ansible-playbook site.yml --tags docker-control-node
run-remote.sh ansible-playbook site.yml --tags docker-media-node
```

Run play for specific node:

```
./run-remote.sh ansible-playbook site.yml --tags install-cacerts --limit media01.example.int
```

With debug:

```
bash -x ./run-remote.sh ansible-playbook site.yml.yml --tags docker-media-node
```

Setup vsphere dc
```bash
run-remote.sh ansible-playbook site.yml --tags deploy-vsphere-dc
```

Deploy VMs
```bash
run-remote.sh ansible-playbook site.yml --tags deploy-vm
```

Bootstrap VM nodes if needed
Note: This is not used any longer since this is now performed from the jenkins pipeline.
The jenkins pipeline is responsible for building VM template images using packer.
The vm image build pipeline source is located here [here](https://github.com/lj020326/pipeline-automation-lib/blob/public/vars/buildVmTemplate.groovy).

```bash
run-remote.sh ansible-playbook site.yml --tags bootstrap-node --limit admin02
```

Bootstrap node network config *should not be necessary since this is mostly done in deploy-VM
```bash
run-remote.sh ansible-playbook site.yml --tags bootstrap-node-network --limit node01
```

Docker stack plays
```bash
run-remote.sh ansible-playbook site.yml --tags docker-admin-node
run-remote.sh ansible-playbook site.yml --tags docker-media-node
```

Useful commands to build/update/configure datacenter:

```bash
run-remote.sh ansible-playbook site.yml --tags bootstrap-bind
run-remote.sh ansible-playbook site.yml --tags bootstrap-docker
run-remote.sh ansible-playbook site.yml --tags bootstrap-node-core
run-remote.sh ansible-playbook site.yml --tags bootstrap-openstack
run-remote.sh ansible-playbook site.yml --tags bootstrap-openstack-cloud
run-remote.sh ansible-playbook site.yml --tags bootstrap-user
run-remote.sh ansible-playbook site.yml --tags bootstrap-vmware-esxi
run-remote.sh ansible-playbook site.yml --tags build-docker-images
run-remote.sh ansible-playbook site.yml --tags cacerts-deploy
run-remote.sh ansible-playbook site.yml --tags deploy-vm
run-remote.sh ansible-playbook site.yml --tags deploy-vsphere-dc
run-remote.sh ansible-playbook site.yml --tags display-hostvars
run-remote.sh ansible-playbook site.yml --tags docker-admin-node
run-remote.sh ansible-playbook site.yml --tags docker-media-node
run-remote.sh ansible-playbook site.yml --tags fetch-osimages
run-remote.sh ansible-playbook site.yml --tags iscsi-client
run-remote.sh ansible-playbook site.yml --tags nfs-service
run-remote.sh ansible-playbook site.yml --tags vmware-remount-datastores
run-remote.sh ansible-playbook site.yml --tags vmware-upgrade-esxi
```

Other useful commands
---------------------

To run play on a group

```bash
run-remote.sh ansible-playbook site.yml --tags bootstrap --limit os_Ubuntu
```

To build ansible control node

```bash
run-remote.sh ansible-playbook site.yml --tags bootstrap-ansible --limit admin02
```

To build docker images from source repos
Note: this is performed from jenkins docker build pipeline and not performed directly using ansible unless necessary 
The docker image build pipeline source is located here [here](https://github.com/lj020326/pipeline-automation-lib/blob/public/vars/buildDockerImage.groovy).

```bash
run-remote.sh ansible-playbook site.yml --tags bootstrap-docker-images --limit admin02
```

To setup/configure samba server node
Note: We now use the samba docker container to run the samba server and no longer build on the VM.

```bash
run-remote.sh ansible-playbook site.yml --tags bootstrap-samba-server
```

To configure samba client node

```bash
run-remote.sh ansible-playbook site.yml --tags samba-client
```

To configure linux users

```bash
run-remote.sh ansible-playbook site.yml --tags bootstrap-user
```

To setup/configure iscsi client node

```bash
run-remote.sh ansible-playbook site.yml --tags iscsi-client
```

working with openstack deploy node setup

```bash
run-remote.sh ansible -i inventory/hosts.ini openstack -m ping
run-remote.sh ansible -i inventory/hosts-openstack.ini openstack -m ping

run-remote.sh ansible-playbook site.yml --tags bootstrap-node --limit ubuntu18
run-remote.sh ansible-playbook site.yml --tags bootstrap-node-network --limit node01
run-remote.sh ansible-playbook site.yml --tags bootstrap-openstack
run-remote.sh ansible-playbook site.yml --tags bootstrap-openstack-deploy-node
run-remote.sh ansible-playbook site.yml --tags bootstrap-user --limit ubuntu18
run-remote.sh ansible-playbook site.yml --tags openstack-deploy-node
run-remote.sh ansible-playbook site.yml --tags openstack-osclient

run-remote.sh kolla-ansible -v -i inventory/hosts-openstack.ini bootstrap-servers
run-remote.sh kolla-ansible -v -i inventory/hosts-openstack.ini prechecks
run-remote.sh kolla-ansible -v -i inventory/hosts-openstack.ini deploy
run-remote.sh kolla-ansible -v -i inventory/hosts-openstack.ini post-deploy

```


working with openstack node cleanup/destroy/reset

```bash
run-remote.sh kolla-ansible -v -i inventory/hosts-openstack.ini destroy
run-remote.sh kolla-ansible -v -i inventory/hosts-openstack.ini destroy --yes-i-really-really-mean-it

```

working with openstack env setup

```bash
run-remote.sh scripts/kolla-ansible/init-runonce.sh
run-remote.sh ansible-playbook site.yml --tags bootstrap-openstack-cloud
run-remote.sh openstack server create --image cirros --flavor m1.tiny --key-name mykey --network demo-net demo1

```



Other useful plays
```bash
run-remote.sh ansible-playbook site.yml --tags bootstrap-node-mounts --limit media
run-remote.sh ansible-playbook site.yml --tags bootstrap-openstack
run-remote.sh ansible-playbook site.yml --tags bootstrap-openstack-cloud
run-remote.sh ansible-playbook site.yml --tags bootstrap-openstack-deploy-node
```

Openstack plays
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

Other useful tests

```bash
run-remote.sh ansible -u administrator -e ansible_password=${ANSIBLE_SSH_PASSWORD} -m ping ubuntu18
run-remote.sh ansible -v -u administrator -e ansible_password=${ANSIBLE_SSH_PASSWORD} -e ansible_pyth/bin/python3 -i inventory/hosts.ini -m ping ubuntu18
```


```bash
run-remote.sh ansible-playbook site.yml --tags display-vars -l control01
run-remote.sh ansible-playbook site.yml --tags display-domain-vars -l control01
run-remote.sh ansible-playbook site.yml --tags display-domain-vars -l nas02
run-remote.sh ansible-playbook site.yml --tags display-domain-vars -l control01
run-remote.sh ansible all -m debug -a var=groups['ca_domain']

run-remote.sh ansible-playbook site.yml --tags bootstrap-bind
run-remote.sh ansible-playbook site.yml --tags bootstrap-cacerts
run-remote.sh ansible-playbook site.yml --tags deploy-cacerts
run-remote.sh ansible-playbook site.yml --tags docker-control-node
run-remote.sh ansible-playbook site.yml --tags docker-admin-node
run-remote.sh ansible-playbook site.yml --tags docker-media-node
gethist | grep remote | uniq >> ./README.md 
```
