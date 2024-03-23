
# Tower inventory repository

## Table of Contents
* [Sanity Checks](#sanity-checks)
  * [1 - Check that the correct hosts appear for the group](#1---check-that-the-correct-hosts-appear-for-the-group)
    * [Check correct hosts appear in the test hosts/groups](#check-correct-hosts-appear-in-the-test-hostsgroups)
    * [Check the host variable values are correctly set](#check-the-host-variable-values-are-correctly-set)
  * [2 - Check the groups are correctly setup for the hosts getting added](#2---check-the-groups-are-correctly-setup-for-the-hosts-getting-added)
    * [CORE/Essential "DC" groups](#coreessential-dc-groups)
  * [3 - Key role variable checks for hosts in group(s)](#3---key-role-variable-checks-for-hosts-in-groups)
  * [4 - Graphs for group hierarchy checks](#4---graphs-for-group-hierarchy-checks)
* [Testing Inventory host and/or group variable settings](#testing-inventory-host-andor-group-variable-settings)
  * [Show list of all DEV/DMZ/SITE1 hosts](#show-list-of-all-sandboxdmzmem-hosts)
  * [Debug host/group vars for inventory hosts](#debug-hostgroup-vars-for-inventory-hosts)
    * [Get groups for a host](#get-groups-for-a-host)
  * [Get info for all hosts in a specified inventory](#get-info-for-all-hosts-in-a-specified-inventory)

## Sanity Checks 

Perform the following CLI based sanity checks whenever making updates/additions to the inventory to confirm the inventory changes are correctly set.

### 1 - Check that the correct hosts appear for the group 

Using a group with name 'testgroup'
```shell
ansible-inventory -i ./inventory/DEV/ --graph testgroup_linux
@testgroup_linux:
  |--@testgroup_linux_site1:
  |  |--ntp1s1.qa.example.int
  |  |--testhost1s1.dev.example.int
  |  |--testhost2s1.dev.example.int
  |  |--testhost3s1.dev.example.int
  |--@testgroup_linux_site4:
  |  |--ntp1s4.qa.example.int
  |  |--testhost1s4.dev.example.int
  |  |--testhost2s4.dev.example.int
  |  |--testhost3s4.dev.example.int
```

#### Check correct hosts appear in the test hosts/groups 

```shell
ansible-inventory -i DEV/ --host testhost1s1.dev.example.int
ansible-inventory -i DEV/ --yaml --host testhost1s1.dev.example.int
ansible-inventory -i DEV/ --graph testgroup_linux
ansible-inventory -i DEV/ --graph testgroup_ntp
ansible-inventory -i DEV/ --graph dmz
```

#### Check the host variable values are correctly set  

Variable value/state query based on group:

```shell
$ ansible -i PROD/ -m debug -a var=group_names admin01
$ ansible -i DEV/ -m debug -a var=internal_domain control01
$ ansible -i DEV/ -m debug -a var=ansible_python_interpreter control01
$ ansible -i DEV/ -m debug -a var=ansible_python_interpreter control01
$ ansible -i PROD/ -m debug -a var=bootstrap_linux_package_list__jenkins_agent
$ ansible -i PROD/ -m debug -a var=docker_stack__environment control01
$ ansible -i DEV/ -m debug -a var=group_names testgroup_linux
$ ansible -i DEV/ -m debug -a var=group_names testgroup_ntp
$ ansible -i DEV/ -m debug -a var=group_names testgroup_ntp_server
$ ansible -i DEV/ -m debug -a var=bootstrap_ntp_servers testgroup_ntp
$ ansible -i DEV/ -m debug -a var=bootstrap_ntp_servers testgroup_ntp
$ ansible -i DEV/ -m debug -a var=bootstrap_ntp_servers testgroup_ntp_server
$ ansible -i DEV/ -m debug -a var=bootstrap_ntp_var_source testgroup_ntp
```

Query multiple variables based on group:

```shell
$ ansible -i DEV/ -m debug -a var=bootstrap_ntp_var_source,bootstrap_ntp_servers testgroup_ntp
```

Query vaulted variable

```shell
$ PROJECT_DIR="$( git rev-parse --show-toplevel )"
$ ansible -e @./vars/vault.yml --vault-password-file ${PROJECT_DIR}/.vault_pass -i DEV/ -m debug -a var=ansible_user app_abc123_dev
$ ansible -e @./vars/vault.yml --vault-password-file ${PROJECT_DIR}/.vault_pass -i DEV/ -m debug -a var=ansible_user app_abc123
$ ansible -e @vars/vault.yml --vault-password-file ${PROJECT_DIR}/.vault_pass -i DEV/ -m debug -a var=vault__ldap_readonly_password testgroup_linux
```

Query with vault and vars files variables (e.g., `./test-vars.yml`) 

```shell
$ PROJECT_DIR="$( git rev-parse --show-toplevel )"
$ ansible -e @./vars/vault.yml -e @test-vars.yml \
    --vault-password-file \
    ${PROJECT_DIR}/.vault_pass \
    -i DEV/ \
    -m debug \
    -a var=vault_platform \
    testd1s4.example.int
$ ansible -e @test-vars.yml -e @./vars/vault.yml --vault-password-file ${PROJECT_DIR}/.vault_pass -i DEV/ -m debug -a var=test_component_cyberark_base_url localhost
$ ansible -e @test-vars.yml -e @./vars/vault.yml --vault-password-file ${PROJECT_DIR}/.vault_pass -i DEV/ -m debug -a var=docker_stack_ldap_host testd1s4.example.int
$ ansible -e @test-vars.yml -e @./vars/vault.yml --vault-password-file ${PROJECT_DIR}/.vault_pass -i DEV/ -m debug -a var=ansible_user app_cdata_sync_sandbox
$ ansible -e @test-vars.yml -e @./vars/vault.yml --vault-password-file ${PROJECT_DIR}/.vault_pass -i DEV/ -m debug -a var=ansible_user app_tableau
$ ansible -e @test-vars.yml -e @vars/vault.yml --vault-password-file ${PROJECT_DIR}/.vault_pass -i DEV/ -m debug -a var=vault__ldap_readonly_password testgroup_linux
```


### 2 - Check the groups are correctly setup for the hosts getting added 

Group based query:
```shell
ansible -i DEV/ -m debug -a var=bootstrap_ntp_servers testgroup_linux
ntp1s1.qa.example.int | SUCCESS => {
    "bootstrap_ntp_servers": [
        "us.pool.ntp.org",
        "time.nist.gov",
        "tick.viawest.net",
        "tock.viawest.net"
    ]
}
testhost3s1.dev.example.int | SUCCESS => {
    "bootstrap_ntp_servers": "VARIABLE IS NOT DEFINED!"
}
ntp1s4.qa.example.int | SUCCESS => {
    "bootstrap_ntp_servers": [
        "us.pool.ntp.org",
        "time.nist.gov",
        "tick.viawest.net",
        "tock.viawest.net"
    ]
}
testhost1s4.dev.example.int | SUCCESS => {
    "bootstrap_ntp_servers": "VARIABLE IS NOT DEFINED!"
}
testhost2s4.dev.example.int | SUCCESS => {
    "bootstrap_ntp_servers": "VARIABLE IS NOT DEFINED!"
}
testhost2s1.dev.example.int | SUCCESS => {
    "bootstrap_ntp_servers": []
}
testhost1s1.dev.example.int | SUCCESS => {
    "bootstrap_ntp_servers": []
}
testhost3s4.dev.example.int | SUCCESS => {
    "bootstrap_ntp_servers": "VARIABLE IS NOT DEFINED!"
}

```

Query hosts for intersecting groups:

```shell
$ ansible -i DEV/ -m debug -a var=group_names dmz:\&lnx_all
$ ansible -i DEV/ -m debug -a var=group_names dmz:\&testgroup_linux
$ ansible -i DEV/ -m debug -a var=group_names dmz:\&testgroup_linux:\&ntp

```

Host based query:
```shell
ansible -i DEV/ -m debug -a var=group_names testhostp1s*
testhost1s4.example.int | SUCCESS => {
    "group_names": [
        "examplegroup"
    ]
}
testhost1s1.example.int | SUCCESS => {
    "group_names": [
        "examplegroup"
    ]
}
```

Seeing the situation above should inspire/invoke the following questions/concerns: 

* shouldn't these machines also be in the respective core/essential DC groups used to derive core/essential settings/configs? 
* currently, they only appear to be in only the `examplegroup` group, so they would not derive any values for the DC group settings. (see next subsection for more info).

#### CORE/Essential "DC" groups

All hosts should in appear in respective core/essential "DC" groups to derive the correct settings.

We would always expect there to be "core" DC groups that all machines should appear.

The "core" DC groups we expect to see:

* sdlc_environment 
  * DEV
  * QA
  * PROD

* infra_provider 
  * internal-vmware
  * AWS
  * Azure
  * GCP

* availability zone/site/location
  * site1 (SITE1), 
  * site4 (SITE2)
  * AWS 
    * AZ01, 
    * AZ02, 
    * ..., 
    * AZNN, 
  * etc

* network 
  * site1
  * site2
  * DMZ
  * pci_site1
  * pci_site2

and perhaps some others


### 3 - Key role variable checks for hosts in group(s)

If deploying host updates such that key variable values are expected, check to verify that the variable values are set correctly.

E.g., 

In the following example, we are updating the ntp client configuration for hosts and want to see that those machines have the expected value for variable 'ntp_servers'.

```shell
ansible -i ./inventory/DEV/SITE1/ -m debug -a var=ntp_servers ntp_client

#ansible -i ./inventory/DEV/SITE1/ -m debug -a var=ntp_servers,some_other_var ntp_client

```


### 4 - Graphs for group hierarchy checks

Query by group name:
```shell
ansible-inventory -i DEV/ --graph examplegroup
@examplegroup:
  |--testhost1s1.example.int
  |--testhost1s4.example.int

```

Other examples:
```shell
ansible-inventory -i DEV/SITE1/ --graph ntp
@ntp:
  |--@ntp_client:
  |  |--@environment_test:
  |  |  |--time5s1.test.example.int
  |  |  |--webq1.test.example.int
  |  |  |--webq2.test.example.int
  |--@ntp_server:
  |  |--time5s1.test.example.int
  |  |--time5s4.test.example.int

```


```shell
ansible-inventory -i DEV/ --graph ntp
@ntp:
  |--@ntp_client:
  |  |--@environment_test:
  |  |  |--time5s1.test.example.int
  |  |  |--webq1.test.example.int
  |  |  |--webq2.test.example.int
  |  |  |--time5s1.test.example.int
  |  |  |--webp1.test.example.int
  |  |  |--webp1.test.test.example.int
  |  |  |--webp2.test.example.int
  |  |  |--webp2.test.test.example.int
  |  |  |--webp3.test.example.int
  |  |  |--webp3.test.test.example.int
  |  |  |--webp4.test.example.int
  |  |  |--webp4.test.test.example.int
  |  |  |--webq1.test.example.int
  |  |  |--webq2.test.example.int
  |  |  |--web1s4.qa.test.example.int
  |  |  |--web1s4.qa.test.test.example.int
  |  |--@linux:
  |  |  |--@linux_dmz:
  |  |  |  |--@linux_dmz_site2:
  |  |  |  |  |--web1s4.example.int
  |  |  |  |--@linux_dmz_site1:
  |  |  |  |  |--webp1.example.int
  |  |  |--@linux_site1:
  |  |  |  |--@linux_site1_site2:
  |  |  |  |  |--lnxr7t1s4.example.int
  |  |  |  |  |--lnxr8t1s4.example.int
  |  |  |  |--@linux_site1_site1:
  |  |  |  |  |--awxtest1s1.dev.example.int
  |  |  |  |  |--testhost1s1.dev.example.int
  |  |  |  |  |--testhost2s1.dev.example.int
  |  |  |  |--@linux_site1_other:
  |--@ntp_server:
  |  |--awxtest1s1.dev.example.int
  |  |--time5s1.test.example.int
  |  |--time5s4.test.example.int
  |  |--web1s4.example.int

```


```shell
ansible -i ./inventory/DEV/ -m debug -a var=ansible_winrm_transport windows_dev
ansible -i ./inventory/DEV/ test* -m debug -a var=environment.name var=location_name
ansible -i ./inventory/DEV/SITE1/ --list-hosts all
ansible -i ./inventory/DEV/SITE1/ -m debug -a var=ntp_servers all
ansible -i ./inventory/DEV/SITE1/ -m debug -a var=ntp_servers bootstrap_ntp_servers
ansible -i ./inventory/DEV/SITE1/ -m debug -a var=bootstrap_ntp_servers all
ansible -i ./inventory/DEV/SITE1/ -m debug -a var=bootstrap_ntp_servers,group_names all
ansible -i ./inventory/DEV/SITE1/ -m debug -a var=bootstrap_ntp_servers,group_names ntp_server
ansible -i ./inventory/DEV/SITE1/ -m debug -a var=bootstrap_ntp_servers,group_names ntp_client
ansible -i ./inventory/DEV/SITE1/ -m debug -a var=bootstrap_ntp_servers,group_names ntp_client
ansible -i ./inventory/DEV/SITE1/ -m debug -a var=bootstrap_ntp_servers,group_names all
ansible -i ./inventory/DEV/SITE1/ -m debug -a var=bootstrap_ntp_servers,group_names ntp
ansible -i ./inventory/DEV/SITE1/ -m debug -a var="ansible_default_ipv4.address" ntp
ansible -i ./inventory/DEV/SITE1/ -m debug -a var="ansible_default_ipv4.address|ansible.utils.ipaddr('10.10.10.0/24')|ansible.utils.ipaddr(bool)" ntp
ansible -i ./inventory/DEV/SITE1/ -m debug -a var="ansible_default_ipv4.address|ansible.utils.ipaddr('10.10.10.0/24')|ansible.utils.ipaddr('bool')" ntp
ansible -i ./inventory/DEV/SITE1/ -m debug -a var="ansible_default_ipv4.address|ansible.utils.ipaddr('172.21.40.0/24')|ansible.utils.ipaddr('bool')" ntp
ansible -i ./inventory/DEV/SITE1/ -m debug -a var="ntp_servers|d('')" ntp
ansible -i ./inventory/DEV/SITE1/ -m debug -a var="bootstrap_ntp_servers|d('')" ntp
ansible -i ./inventory/DEV/SITE1/ -m debug -a var="bootstrap_ntp_servers|d(''),bootstrap_ntp_peers|d('')" ntp

```

## Testing Inventory host and/or group variable settings

We will now run through several ansible CLI tests to verify that the correct machines result for each respective limit used.

### Show list of all DEV/DMZ/SITE1 hosts

```shell
$ ansible -i ./inventory/DEV/DMZ/SITE1 --list-hosts all
  hosts (9):
    testhost1s1.dev.example.int
    testhost2s1.dev.example.int
    testhost3s1.dev.example.int
    webd1.example.int
    webq1.example.int
    webq2.example.int
    time5s1.test.example.int
    webq1.test.example.int
    webq2.test.example.int

```

### Debug host/group vars for inventory hosts

#### Get groups for a host

```shell
ansible -i ./Sandbox -m debug -a var=group_names testhostd1s1*
testhost1s1.dev.example.int | SUCCESS => {
    "group_names": [
        "dev",
        "dmz",
        "dmz_dev",
        "dmz_qa",
        "lnx_all",
        "lnx_dev",
        "lnx_site1",
        "lnx_qa",
        "dc_site_1",
        "ntp",
        "ntp_client",
        "qa",
        "test_git_acp",
        "test_git_acp_linux",
        "testhost"
    ]
}

```

### Get info for all hosts in a specified inventory

```shell
$ ansible -i ./inventory/DEV/DMZ/SITE1 -m debug -a var=group_names all
testhost1s1.dev.example.int | SUCCESS => {
    "group_names": [
        "dmz",
        "dmz_qa",
        "lnx_qa",
        "qa"
    ]
}
testhost2s1.dev.example.int | SUCCESS => {
    "group_names": [
        "ungrouped"
    ]
}
testhost3s1.dev.example.int | SUCCESS => {
    "group_names": [
        "ungrouped"
    ]
}
webd1.example.int | SUCCESS => {
    "group_names": [
        "appweb",
        "dmz_web",
        "dmz_web_s1"
    ]
}
webq1.example.int | SUCCESS => {
    "group_names": [
        "appweb",
        "dmz_web",
        "dmz_web_s1"
    ]
}
webq2.example.int | SUCCESS => {
    "group_names": [
        "appweb",
        "dmz_web",
        "dmz_web_s1"
    ]
}
time5s1.test.example.int | SUCCESS => {
    "group_names": [
        "rhel7_composite",
        "qa"
    ]
}
webq1.test.example.int | SUCCESS => {
    "group_names": [
        "rhel7_composite",
        "qa",
        "site1"
    ]
}
webq2.test.example.int | SUCCESS => {
    "group_names": [
        "rhel7_composite",
        "qa",
        "site1"
    ]
}

```
