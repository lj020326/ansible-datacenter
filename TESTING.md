
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
ansible-inventory -i inventory/ --host vmlnxtestd1s1
ansible-inventory -i inventory/ --yaml --host vmlnxtestd1s1
ansible-inventory -i inventory/ --yaml --host ntpq1s1
ansible-inventory -i inventory/ --graph testgroup_lnx
ansible-inventory -i inventory/ --graph testgroup_ntp
ansible-inventory -i inventory/ --graph dmz
```

### Check the host variable values are correctly set  

Variable value/state query based on group:

```shell
$ ansible -i inventory/ -m debug -a var=group_names testgroup_lnx
$ ansible -i inventory/ -m debug -a var=group_names testgroup_ntp
$ ansible -i inventory/ -m debug -a var=group_names testgroup_ntp_server
$ ansible -i inventory/ -m debug -a var=bootstrap_ntp_servers testgroup_ntp
$ ansible -i inventory/ -m debug -a var=bootstrap_ntp_servers testgroup_ntp_server
$ ansible -i inventory/ -m debug -a var=bootstrap_ntp_var_source testgroup_ntp
```

Query multiple variables based on group:

```shell
$ ansible -i inventory/ -m debug -a var=bootstrap_ntp_var_source,bootstrap_ntp_servers testgroup_ntp
```

Query intersecting groups:
```shell
$ ansible -i inventory/ -m debug -a var=group_names dmz:\&os_linux
$ ansible -i inventory/ -m debug -a var=group_names dmz:\&testgroup_lnx
$ ansible -i inventory/ -m debug -a var=group_names dmz:\&testgroup_lnx:\&ntp_network
```

### Run playbook

```shell
$ runme.sh bootstrap-ntp.yml -l testgroup_lnx
```

### Run playbook on hosts

```shell
$ runme.sh site.yml -t bootstrap-docker-stack -l admin01
$ runme.sh bootstrap-docker.yml -l admin02
$ runme.sh bootstrap-docker.yml -v -l testgroup_docker
$ runme.sh bootstrap-docker.yml -v -l admin03
$ runme.sh bootstrap-docker-stack.yml -l testgroup_dockerstack
$ runme.sh bootstrap-docker-stack.yml -v -l infracicdd1s1
$ runme.sh bootstrap-docker-stack.yml -v -l testgroup_docker
$ runme.sh bootstrap-docker-stack.yml -v -l admin03
$ runme.sh get-latest-compose-version.yml 
$ 
```

## Test site.yml

### Test site.yml with tags and limit

```shell
$ runme.sh site.yml -t display-ansible-env -l testgroup_lnx
$ runme.sh site.yml -t bootstrap-ntp -l testgroup_lnx
```

## Test Inventory Checks 

Whenever making updates/additions to the inventory

### 1) Check that the correct hosts appear for the test group

Test machine group defined in 'inventory/TEST/testgroup.yml':
```shell
ansible-inventory -i inventory/ --graph --yaml testgroup_lnx
@testgroup_lnx:
  |--@testgroup_lnx_site1:
  |  |--ntpq1s1
  |  |--vmlnxtestd1s1
  |  |--vmlnxtestd2s1
  |  |--vmlnxtestd3s1
  |--@testgroup_lnx_site4:
  |  |--ntpq1s4
  |  |--vmlnxtestd1s4
  |  |--vmlnxtestd2s4
  |  |--vmlnxtestd3s4
```

```shell
ansible-inventory -i inventory/ --graph --yaml testgroup_wnd
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
ansible -i inventory/ -m debug -a var=group_names testgroup_lnx
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
$ export MOLECULE_DISTRO=redhat7-systemd-python
$ molecule create
$ molecule login
$ MOLECULE_DISTRO=redhat8-systemd-python molecule --debug test -s bootstrap_linux_package
$ molecule --debug test -s bootstrap_linux_package
$ molecule destroy
$ MOLECULE_DISTRO=redhat8-systemd-python molecule --debug test -s bootstrap_linux_package --destroy never
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
$ tests/molecule_exec.sh centos7 converge -s bootstrap_pip
$ molecule destroy
$ tests/molecule_exec.sh centos7 converge -s bootstrap_linux
$ molecule destroy
$ tests/molecule_exec.sh centos7 converge -s bootstrap_linux_package
$ molecule destroy
$ tests/molecule_exec.sh centos8 --debug converge -s bootstrap_pip
$ molecule destroy
$ tests/molecule_exec.sh centos8 --debug converge
$ molecule destroy
$ tests/molecule_exec.sh ubuntu2004 converge
$ molecule destroy
$ tests/molecule_exec.sh ubuntu2204 --debug converge
$ molecule destroy --all

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
