
# Tests

## Prepare test environment

### Create symbolic links to the develop branch tower-inventory repo

In the developer environment, the 'tower-inventory' repo should be located in the same base directory as the 'ansible-datacenter' project repo.

In the project tests directory, create a symbolic link to the 'tower-inventory' `develop` test inventory directory.

```shell
$ cd ~/repos/ansible/ansible-datacenter/tests
$ ln -s ../../tower-inventory/develop inventory
```

### Create symbolic links to the internal develop branch collections

In `requirements_collections`, setup symbolic link to any internal shared collections:

```shell
$ cd ~/repos/ansible/
$ mkdir -p requirements_collections/ansible_collections
$ cd requirements_collections/ansible_collections
$ ln -s ../../infra-collections/collections/ansible_collections/infra-collections
$ ls -Fla
total 0
drwxr-xr-x 3 username staff 96 Nov 16 08:42 ./
drwxr-xr-x 3 username staff 96 Nov 16 08:41 ../
lrwxr-xr-x 1 username staff 87 Nov 16 08:42 infra-collections -> ../../infra-collections/collections/ansible_collections/infra-collections/
$ cd ~/repos/ansible
$ git clone https://github.com/lj020326/ansible-datacenter.git
$ cd ansible-datacenter/tests
$ PROJECT_DIR="$( git rev-parse --show-toplevel )"
$ WORKDIR="${PROJECT_DIR}/.."
$ export ANSIBLE_COLLECTIONS_PATH=${PROJECT_DIR}/collections:${WORKDIR}/requirements_collections

```

As an example: 
```shell
$ cd ~/repos/ansible/
$ ls -1
ansible-test-automation
infra-collections
ansible-datacenter
requirements_collections
tower-inventory
tower-management
```

The runme.sh shell script can be used to run test playbooks.  It sets the ANSIBLE_COLLECTIONS_PATH variable to include the 'requirements_collections' directory.

### Use [create_test_symlinks.sh script](./create_test_symlinks.sh) to automate creation of test symbolic links (symlinks)

Use the following script to set up the symbolic links used for testing.

```shell
$ cd ~/repos/ansible/ansible-datacenter/tests
$ create_test_symlinks.sh
```

## Run Tests Locally

## Check test inventory

### Check correct hosts appear in the test hosts/groups 

```shell
ansible-inventory -i inventory/hosts.yml --host vmlnxtestd1s1
ansible-inventory -i inventory/prod/hosts.yml --yaml --host vmlnxtestd1s1
ansible-inventory -i inventory/prod/hosts.yml --yaml --host ntpq1s1
ansible-inventory -i inventory/prod/hosts.yml --graph docker_stack
ansible-inventory -i inventory/prod/hosts.yml --graph docker_stack_control
ansible-inventory -i inventory/prod/hosts.yml --graph docker_stack_openldap
ansible-inventory -i inventory/prod/hosts.yml --graph docker_stack_jenkins_jcac
ansible-inventory -i inventory/prod/hosts.yml --graph docker_stack_media
ansible-inventory -i inventory/prod/hosts.yml --graph testgroup_ntp
ansible-inventory -i inventory/prod/hosts.yml --graph dmz
```

### Check the host variable values are correctly set  

Variable value/state query based on group:

```shell
$ ansible -i inventory/hosts.yml -m debug -a var=group_names control01
$ ansible -i inventory/prod/hosts.yml -m debug -a var=docker_stack_internal_root_domain docker_stack
$ ansible -i inventory/prod/hosts.yml -m debug -a var=docker_stack_service_groups__openldap docker_stack_openldap
$ ansible -i inventory/prod/hosts.yml -m debug -a var=group_names docker_stack
$ ansible -i inventory/prod/hosts.yml -m debug -a var=group_names testgroup_docker
$ ansible -i inventory/prod/hosts.yml -m debug -a var=group_names testgroup_ntp
$ ansible -i inventory/prod/hosts.yml -m debug -a var=group_names testgroup_ntp_server
$ ansible -i inventory/prod/hosts.yml -m debug -a var=bootstrap_ntp_servers testgroup_ntp
$ ansible -i inventory/prod/hosts.yml -m debug -a var=bootstrap_ntp_servers testgroup_ntp_server
```

Check vaulted variable

```shell
$ ansible -e @vars/vault.yml --vault-password-file ~/.vault_pass -i inventory/prod/hosts.yml -m debug -a var=vault__ldap_readonly_password docker_stack_openldap
$ ansible -e @vars/vault.yml --vault-password-file ~/.vault_pass -i inventory/prod/hosts.yml -m debug -a var=docker_stack_jenkins_jcac_ldap_base_dn docker_stack_jenkins_jcac
```

Query multiple variables based on group:

```shell
$ ansible -i inventory/prod/hosts.yml -m debug -a var=bootstrap_ntp_var_source,bootstrap_ntp_servers testgroup_ntp
```

Query intersecting groups:
```shell
$ ansible -i inventory/prod/hosts.yml -m debug -a var=group_names dmz:\&dc_os_linux
$ ansible -i inventory/prod/hosts.yml -m debug -a var=group_names dmz:\&docker_stack
$ ansible -i inventory/prod/hosts.yml -m debug -a var=group_names dmz:\&docker_stack:\&ntp_network
```


### Run `tag-based` `site.yml` plays on hosts

```shell
$ runme.sh site.yml -t deploy-cacerts -l admin01
$ runme.sh site.yml -t bootstrap-linux -l admin01
$ runme.sh site.yml -t bootstrap-webmin -l admin01
$ runme.sh site.yml -t bootstrap-docker -l admin01
$ runme.sh site.yml -t bootstrap-docker-stack -l admin01
$ runme.sh site.yml -t bootstrap-docker-stack -l docker_stack_control
$ runme.sh site.yml -t bootstrap-docker-stack -l docker_stack_openldap
$ runme.sh site.yml -t bootstrap-docker-stack -l docker_stack_jenkins_jcac
$ runme.sh site.yml -t bootstrap-docker-stack -l docker_stack_media
```

### Run playbook

```shell
$ runme.sh bootstrap-ntp.yml -l docker_stack
```

### Run playbooks on hosts

```shell

$ runme.sh deploy-cacerts.yml
$ runme.sh deploy-cacerts.yml -l admin*
$ runme.sh bootstrap-linux.yml
$ runme.sh bootstrap-linux.yml -l control01
$ runme.sh bootstrap-linux.yml -l admin*
$ runme.sh bootstrap-webmin.yml
$ runme.sh bootstrap-webmin.yml -l control01
$ runme.sh bootstrap-webmin.yml -l admin*
$ runme.sh bootstrap-docker.yml
$ runme.sh bootstrap-docker.yml -v -l testgroup_docker
$ runme.sh bootstrap-docker.yml -l control01
$ runme.sh bootstrap-docker.yml -l vcontrol01
$ runme.sh bootstrap-docker.yml -l admin01
$ runme.sh bootstrap-docker.yml -l admin*
$ runme.sh bootstrap-docker-stack.yml -l testgroup_docker
$ runme.sh bootstrap-docker-stack.yml -l control01
$ runme.sh bootstrap-docker-stack.yml -l admin*
$ runme.sh bootstrap-docker-stack.yml -l docker_stack_control
$ runme.sh bootstrap-docker-stack.yml -l docker_stack_openldap
$ runme.sh bootstrap-docker-stack.yml -l docker_stack_jenkins
$ runme.sh bootstrap-docker-stack.yml -l docker_stack_jenkins_jcac
$ runme.sh bootstrap-docker-stack.yml -l docker_stack_media
$ runme.sh get-latest-compose-version.yml 
$ 
```

## Test site.yml

### Test site.yml with tags and limit

```shell
$ runme.sh site.yml -t display-common-vars -l testd1s4.example.int
$ runme.sh site.yml -t display-common-vars -l admin01
$ runme.sh site.yml -t display-common-vars -l testgroup
$ runme.sh site.yml -t display-controller-vars
$ runme.sh site.yml -t bootstrap-ntp -l testgroup
$ runme.sh site.yml -t bootstrap-docker -l docker
$ runme.sh site.yml -t bootstrap-docker-stack
```

## Test Inventory Checks 

Whenever making updates/additions to the inventory

### 1) Check that the correct hosts appear for the test group

Test host group defined in 'inventory/prod/hosts.yml':
```shell
$ ansible-inventory -i inventory/prod/hosts.yml --graph --yaml docker_stack
@docker_stack:
  |--@docker_stack_admin:
  |  |--admin02
  |  |--admin03
  |--@docker_stack_control:
  |  |--@control_node:
  |  |  |--control01
  |  |  |--vcontrol01
  |--@docker_stack_jenkins_jcac:
  |  |--admin01
  |--@docker_stack_media:
  |  |--media01
  |--@docker_stack_ml:
  |--@docker_stack_samba:
```

```shell
ansible-inventory -i inventory/prod/hosts.yml --graph --yaml testgroup_wnd
@testgroup_wnd:
  |--@testgroup_wnd_site1:
  |  |--vmwintestd1s1
  |  |--vmwintestd2s1
  |  |--vmwintestd3s1
  |  |--vmwintestd4s1
  |--@testgroup_wnd_site4:
  |  |--vmwintestd1s4
  |  |--vmwintestd2s4
  |  |--vmwintestd3s4
  |  |--vmwintestd4s4
```

## 2) Check the groups are correctly setup for the test hosts 

Var value query based on group:
```shell
ansible -i inventory/prod/hosts.yml -m debug -a var=group_names docker_stack
vmlnxtestd1s1 | SUCCESS => {
    "group_names": ["nondomain_dmz"]
}
vmlnxtestd2s1 | SUCCESS => {
    "group_names": ["nondomain_dmz"]
}

```

## Run molecule tests

The molecule tests below use the [python enabled docker systemd images defined here](https://github.com/lj020326/systemd-python-dockerfiles/tree/master/systemd).

```shell
$ git clone https://github.com/lj020326/ansible-datacenter.git
$ cd ansible-datacenter
$ pip install -r requirements.molecule.txt
$ export MOLECULE_DISTRO=redhat7
$ molecule create
$ molecule login
$ MOLECULE_DISTRO=redhat8-systemd-python molecule --debug test -s bootstrap-linux-package
$ molecule --debug test -s bootstrap-linux-package
$ molecule destroy
$ MOLECULE_DISTRO=redhat8-systemd-python molecule --debug test -s bootstrap-linux-package --destroy never
$ MOLECULE_DISTRO=redhat8-systemd-python molecule login
$ molecule destroy
$ MOLECULE_DISTRO=centos7-systemd-python molecule converge --destroy never
$ MOLECULE_DISTRO=centos7-systemd-python molecule login
$ molecule destroy
$ MOLECULE_DISTRO=centos8-systemd-python --debug converge
$ molecule destroy
$ MOLECULE_DISTRO=ubuntu2004-systemd-python converge
$ molecule destroy
$ MOLECULE_DISTRO=ubuntu2204-systemd-python --debug converge

```

Testing with scenarios:
```shell
$ tests/molecule_exec.sh centos7 converge
$ molecule destroy
$ tests/molecule_exec.sh centos7 converge -s bootstrap-linux
$ molecule destroy
$ tests/molecule_exec.sh centos7 converge -s bootstrap-linux-package
$ molecule destroy
$ tests/molecule_exec.sh centos7 converge -s bootstrap-pip
$ molecule destroy
$ tests/molecule_exec.sh centos8 --debug converge
$ molecule destroy
$ tests/molecule_exec.sh ubuntu2004 converge
$ molecule destroy
$ tests/molecule_exec.sh ubuntu2204 --debug converge
$ molecule destroy

```

To log into container

```shell
$ molecule destroy
$ tests/molecule_exec.sh redhat7 create
$ tests/molecule_exec.sh redhat7 login
```

```shell
$ molecule destroy
$ tests/molecule_exec.sh redhat7 converge
$ molecule destroy
$ tests/molecule_exec.sh debian8 converge
$ molecule destroy
$ tests/molecule_exec.sh centos7 converge
$ molecule destroy
$ tests/molecule_exec.sh centos8 --debug converge
$ molecule destroy
$ tests/molecule_exec.sh ubuntu2004 converge
$ molecule destroy
$ tests/molecule_exec.sh ubuntu2204 --debug converge

```

```shell
runme.sh deploy-cacerts.yml -l admin01
runme.sh bootstrap-ansible.yml -l admin01
runme.sh bootstrap-docker-stack -l admin03
runme.sh bootstrap-docker-stack.yml -l admin01
runme.sh bootstrap-docker-stack.yml -l admin02
runme.sh bootstrap-docker-stack.yml -l admin03
runme.sh bootstrap-docker-stack.yml -vvv -l admin01
runme.sh bootstrap-docker.yml -l admin*
runme.sh bootstrap-docker.yml -l admin01
runme.sh bootstrap-docker.yml -l admin03
runme.sh bootstrap-gov.yml -l admin01
runme.sh bootstrap-govc.yml -l admin01
runme.sh bootstrap-java.yml -l admin01
runme.sh bootstrap-jenkins-agent.yml -l admin01
runme.sh bootstrap-pip.yml -l admin*
runme.sh bootstrap-pip.yml -l admin01
runme.sh bootstrap-pip.yml -l admin02
runme.sh bootstrap-pip.yml -l admin03
runme.sh bootstrap-pip.yml -vv -l admin02
runme.sh site.yml -l media01 -t bootstrap-keyring
runme.sh site.yml -t bootstrap-keyring -l media01
```
