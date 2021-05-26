
```bash
gethist | grep remote | sort | uniq

run-remote.sh ansible-playbook -v site.yml --tags bootstrap-docker-admin-node
run-remote.sh ansible-playbook -v site.yml --tags bootstrap-docker
run-remote.sh ansible-playbook -v site.yml --tags bootstrap-env
run-remote.sh ansible-playbook -v site.yml --tags bootstrap-node
run-remote.sh ansible-playbook -v site.yml --tags bootstrap-user
run-remote.sh ansible-playbook -v site.yml --tags cacerts
run-remote.sh ansible-playbook -v site.yml --tags cicd-node
run-remote.sh ansible-playbook -v site.yml --tags cloudmonkey
run-remote.sh ansible-playbook -v site.yml --tags cloudstack-master
run-remote.sh ansible-playbook -v site.yml --tags deploy-docker-registry-certs
run-remote.sh ansible-playbook -v site.yml --tags docker-admin-node
run-remote.sh ansible-playbook -v site.yml --tags docker-media-node
run-remote.sh ansible-playbook -v site.yml --tags docker-ml-node
run-remote.sh ansible-playbook -v site.yml --tags docker-samba-node
run-remote.sh ansible-playbook -v site.yml --tags webmin
run-remote.sh ansible-playbook -v site.yml --tags cicd-node
run-remote.sh ansible-playbook -v site.yml --tags cloudmonkey

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
