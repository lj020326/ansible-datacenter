
Debugging/Testing variables
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

ansible setup/testing notes/history:

```bash

cdansible
gitpull
la /var/log/
tail -50 /var/log/syslog
sudo su
exit
sudo su
exit
cat .ssh/
ll .ssh/
cat .ssh/authorized_keys
ll | grep ssh
exit
ll ~/.ssh/
exit
sudo su
sudo su
exit
sudo su
exit
net getlocalsid
sudo su
exit
sudo su
ansible-galaxy list
la
cat .ansible_galaxy
cdansible
ansible-galaxy list
ll
ll ~/.local/
ll ~/.local/bin/
ll ~/.local/lib/
ll ~/.local/lib/python3.6/
ll ~/.local/lib/python3.6/site-packages/
la /etc
la /etc/ansible/
la /etc/ansible/roles/
ansible-galaxy list
ll ~/.ansible/roles/
ll ~/.ansible/roles/geerlingguy.git/
ll ~/.ansible/roles/geerlingguy.git/meta/
cat ~/.ansible/roles/geerlingguy.git/meta/.galaxy_install_info
cat ~/.ansible/roles/geerlingguy.git/meta/main.yml
ansible-galaxy list
cat requirements.yml
ansible-galaxy install --force requirements.yml
ansible-galaxy install --force -r requirements.yml
gitpull
ansible-galaxy install --force -r requirements.yml
ansible-galaxy list
cat ~/.ansible/roles/geerlingguy.git/meta/.galaxy_install_info
top
exit
cdrepos
ll
cd /opt/
ll
cd containerd/
ll
sudo su
exit
sudo su
sudo su
exit
cdansible
~/.local/bin/ansible -vvvv -u administrator -e ansible_password=${ANSIBLE_SSH_PASSWORD} -e ansible_pyth/bin/python3 -i inventory/hosts.ini -m ping ubuntu18
run-remote.sh ansible -v -u administrator -e ansible_password=${ANSIBLE_SSH_PASSWORD} -e ansible_pyth/bin/python3 -i inventory/hosts.ini -m ping ubuntu18
run-remote.sh ansible -vvvv -u administrator -e ansible_password=${ANSIBLE_SSH_PASSWORD} -e ansible_pyth/bin/python3 -i inventory/hosts.ini -m ping ubuntu18
sudo su
exit
cdansible
exit
history
gethist

```

```bash
run-remote.sh 
run-remote.sh ansible -i inventory/hosts.ini all -m ping
run-remote.sh ansible -i inventory/hosts.ini -m ping
run-remote.sh ansible -i inventory/hosts.ini openstack -m ping
run-remote.sh ansible -m ping
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
