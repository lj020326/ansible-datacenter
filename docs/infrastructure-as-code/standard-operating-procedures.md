
# Standard Operating Procedures for IaC

The SOPs are based on different scopes and/or patterns based on the requirements/circumstance.

The configurations, testing and other requirements depend on the scope/pattern.

In some case, multiple sets of use case SOPs may be required depending on the type/complexity of the specific circumstance needs.

## Table of Contents
* [Prerequisite to any feature development](#prerequisite-to-any-feature-development)
  * [Prepare the development environment for feature development](#prepare-the-development-environment-for-feature-development)
    * [Setting up and Synchronizing the development/test inventory into AWX](#setting-up-and-synchronizing-the-developmenttest-inventory-into-awx)
      * [Create Inventory Repo feature development branch](#create-inventory-repo-feature-development-branch)
      * [Setup Developer Inventory Project in AWX](#setup-developer-inventory-project-in-awx)
      * [Synchronize Developer Inventory Project in AWX](#synchronize-developer-inventory-project-in-awx)
    * [Use the test inventory to explicitly assign host(s) to required groups for the feature under test](#use-the-test-inventory-to-explicitly-assign-hosts-to-required-groups-for-the-feature-under-test)
    * [Add test host(s) to ivanti or foreman groups](#add-test-hosts-to-ivanti-or-foreman-groups)
    * [Limits to using the test inventory approach](#limits-to-using-the-test-inventory-approach)
    * [Do not use 'group_names' override method](#do-not-use-group_names-override-method)
* [Ansible feature validations](#ansible-feature-validations)
  * [Functional validation](#functional-validation)
    * [Smoke tests](#smoke-tests)
    * [Regression tests](#regression-tests)
    * [New Feature tests](#new-feature-tests)
  * [Interoperability validation](#interoperability-validation)
  * [Performance validation](#performance-validation)
  * [Multiple target hosts validation](#multiple-target-hosts-validation)
  * [Multiple target groups validation](#multiple-target-groups-validation)
    * [Binding test groups to intended 'production'/'final' deployment groups](#binding-test-groups-to-intended-productionfinal-deployment-groups)
* [Ansible feature deployments](#ansible-feature-deployments)
  * [Feature to PR deployment scenarios](#feature-to-pr-deployment-scenarios)
     * [1: Feature for hosts already defined in existing groups](#1-feature-for-hosts-already-defined-in-existing-groups)
     * [2: Feature for hosts defined in new groups](#2-feature-for-hosts-defined-in-new-groups)
* [Patterns and Scopes requiring specific SOPs](#patterns-and-scopes-requiring-specific-sops)
  * [1: Domain Use Cases](#1-domain-use-cases)
    * [Simple Example for a derived group](#simple-example-for-a-derived-group)
    * [Generalized Network Client-Server Use Case](#generalized-network-client-server-use-case)
  * [2: DC Shared Role and/or Module Development (TBC)](#2-dc-shared-role-andor-module-development-tbc)
  * [3: Linux Inventory, Playbook, Role Development (TBC)](#3-linux-inventory-playbook-role-development-tbc)
  * [4: Windows Inventory, Playbook, Role Development (TBC)](#4-windows-inventory-playbook-role-development-tbc)
  * [5: Database Inventory, Playbook, Role Development (TBC)](#5-database-inventory-playbook-role-development-tbc)
  * [6: Network Inventory, Playbook, Role Development (TBC)](#6-network-inventory-playbook-role-development-tbc)
  * [7: Middleware Inventory, Playbook, Role Development (TBC)](#7-middleware-inventory-playbook-role-development-tbc)
  * [8: Ansible Automation Management Role and/or Module Development (TBC)](#8-ansible-automation-management-role-andor-module-development-tbc)
  * [9: Ansible Inventory Change/Enhancement Development (TBC)](#9-ansible-inventory-changeenhancement-development-tbc)


## Prerequisite to any feature development

### Prepare the development environment for feature development

When developing any feature, it is necessary to stand up any/all necessary fixtures to simulate the ultimate environment that the feature is targeted to be deployed.
Most of the patterns/use cases discussed in the following sections involve using ansible 'groups' to properly categorize the set of machines/hosts to be targeted by the ansible plays.

In some cases, the target group will be derived.
In either case, derived or explicitly defined, there will be the need to assign a test machine to the group that is intended to be under test.

For example, consider a feature that is intended for the derived group 'windows_dmz'.
Also consider that the test machine does not fit the 'network' characteristics to properly conform to the derivation logic to assign the test machine into the DMZ network.

### Setting up and Synchronizing the development/test inventory into AWX 

#### Create Inventory Repo feature development branch

1. Clone the inventory repository from Bitbucket  
    1.  The repository contains a Prod folder for the Production Ansible install and a Sandbox folder for the Sandbox Ansible install.
    2.  Inside each of those subfolders are folders for specific inventories. We are moving towards one example.int folder that contains all of the hosts managed by that instance of Ansible and one aap-inventory folder that contains only the Ansible hosts themselves for managing itself.
2. Create a branch from an active Jira ticket in the repository
3. Locate the appropriate yaml file and update the group membership for any hosts being added/deleted.
4. Add/update any data in the group_vars files to reflect changes to any group configuration.

Upon successful feature development / validation:<br>
5. Create a Pull Request from your branch in Bitbucket.<br> 
6. The Inventory change will be reviewed during a DC Architecture meeting for validation before going to Change Management (if necessary).

#### Setup Developer Inventory Project in AWX

Do not manage group vars/memberships via the UI as those will be overwritten with the next Bitbucket refresh. 
The best workflow to update/synchronize the development inventory into AWX is to:

1.  Create a Project in Ansible Sandbox that you can use for your inventory changes - e.g.
    1.  Name: "example.int - Tower Inventory"
    2.  Organization: "example.int"
    3.  SCM Type: "git"
    4.  SCM Url: "[ssh://git@bitbucket.example.int:7999/at/tower-inventory.git](ssh://git@bitbucket.example.int:7999/at/tower-inventory.git)"
    5.  SCM Branch: Update this branch to reflect the change you are working on
    6.  SCM Credential: "example.int - Ansible - Git"
    7.  SCM Update Options: "Clean"
2.  Create an Inventory
    1.  Name: "Alsac Inventory"
    2.  Organization: "example.int"
3.  Add a source to your inventory that uses your project
    1.  After Saving your Inventory, click the Sources button and click the green + to add a new source
    2.  Name: "Bitbucket developer branch"
    3.  Source: Sourced from Project
    4.  Project: "example.int - Tower Inventory"
    5.  Inventory File: "Sandbox/"
    6.  Update Options: Overwrite, Update on Project Update

#### Synchronize Developer Inventory Project in AWX

Once this Project/Inventory exists, you can reuse it for development by updating the branch in the Project. To update the inventory in Sandbox:

1.  Follow the procedure above to make changes to the inventory
2.  Go to [https://ansible.qa.example.int/#/projects](https://ansible.qa.example.int/#/projects) and click the refresh button to the right of your Project
3.  Go to your Inventory and validate the changes you made are visible


#### Use the test inventory to explicitly assign host(s) to required groups for the feature under test

In this case, for test purposes, we can assign the machine explicitly into the group 'dc_wnd_dmz' by adding it into the test inventory file as follows:

```yaml

testgroup:
  vars:
    cred_env: test
  children:
    ...
    ...
    testgroup_platforms:
      children:
        testgroup_wnd:
        testgroup_lnx:

    testgroup_wnd:
      children:
       ...
       ...
        ## dc_wnd_dmz
        ## using prod machine as reference: "JAMFIMP2S1.example.int"
        dc_wnd_dmz:
          children:
            test_wnd_dmz:
              hosts:
                winansd1s1.example.int: {}
                winansd1s4.example.int: {}

        ...
        ...
    testgroup_lnx:
      children:
         ...
         ...

```

This will allow the test machine to be present in the intended group explicitly.

#### Add test host(s) to ivanti or foreman groups

Additionally, the Sandbox inventory often does not include all test machines in the set of ivanti/foreman groups.

These groups are often essential for setting characteristics in derived location/network groups.

These derived groups and respective configuration settings are often essential for downstream play/role based logic to work correctly and as intended.

To efficiently assign/simulate test machines into the ivanti/foreman inventory groups, simply add the assignments into the testgroup hosts YAML as follows.

Sandbox/testgroup.yml:

```yaml
testgroup:
  vars:
    cred_env: test
  children:

    foreman_organization_example_int:
      children:
        testgroup_lnx: {}
    foreman_lifecycle_environment_dev:
      children:
        testgroup_lnx: {}
    foreman_location_site1:
      children:
        testgroup_lnx_site1: {}
    foreman_location_site2:
      children:
        testgroup_lnx_site2: {}

    testgroup_platforms:
      children:
        testgroup_wnd:
        testgroup_lnx:

    ...
    ...

```


#### Limits to using the test inventory approach

For the prior example using the test inventory to explicitly add a test machine to a group, we want to make sure that by assigning a test machine into such a group does not invalidate the test itself.

Consider the scenario where the intended play logic is requires a specific type of machine.

As a more realistic example, consider the logic to power down a physical/baremetal machine/host.

The logic will validate the physical host powers down correctly.

One can hypothetically add the test virtual machine into the 'baremetal' group in the test inventory to have the VM simulate a physical host machine.

The problem with the approach is that now the test is no longer valid in that the 'physical' aspect to the test is no longer getting tested.

The best solution in these cases is that there should be actual 'baremetal' test machine(s) available to test actual 'baremetal' use cases/scenarios.

The same holds true whenever the logic requires the actual test host to conform and validate that the necessary logic actually works for the intended use case.

This type of test constraint upon test machine usually holds true for the following scenarios where the test machine must conform to specific parameters to be considered a valid test environment:

1) hardware (physical vs virtual vs linux container)
2) OS-version specific (rhel7 vs rhel8 vs windows2016 vs windows2019)
3) network (internal vs dmz vs cloud)
4) SW platform version (dockerCE engine 19.03.10 vs 19.03.2)

#### Do not use 'group_names' override method

One may be tempted to simply override the ansible special variable 'group_names' in the job template/playbook extra-vars as follows:

```yaml
group_names:
  - dc_wnd_dmz
  - baremetal

```

Placing the test machine into the group using the ansible special variable 'group_names' is strongly discouraged.
It will override all the group definitions for the machine including any/all that may be necessary for other play logic to work correctly.  

The advantage of using the aforementioned inventory group based approach is that any/all existing inventory host groups are readily available supporting all/any supporting/dependent/downstream play/role logic.  

In fact, as a general rule, do not override 'ansible special variables' since much is lost with little to gain.
Using such methods, the results can often be considered suspect since they can be inconsistent with actual production playbook run results.  


## Ansible feature validations

### Functional validation

The feature functional validation tests should cover all the primary use cases defined by the feature.

In many cases, the specific use cases for the feature are not known by the feature requester.

Out of practicality, test cases can be inferred and developed implicitly by the defined feature request.

The feature developer can develop the test cases to validate the feature set using automated functional tests.

Then at time of deployment, the feature developer can support the feature functional validation success by referring to the functional test automation results as the supporting evidence of complete feature validation.

The benefit of implementing functional test automation is that at any time going forward, feature functionality can be easily validated whenever the following occurs: 

1) new features are added to the existing feature set (regression)
2) changes are made with respect to supporting/dependent libraries/components used by the feature
3) changes are made with respect to the feature environment

#### Smoke tests

Smoke tests are usually sets of critical feature tests that are run to validate that the "lights are on" and/or that the most essential/key parts of the system are operational and working as expected.  The idea to reduce the fuller setup of regression tests to a more practical set of tests that can be run in an efficient manner on a frequent basis.

For infrastructure automation smoke testing, one might consider a having a set of plays that verify that all hosts in the inventory meet a set of infrastructure core requirements, such as:

1) pass ansible ssh ping,
2) pass credential checks: 
   1) ansible credential valid 
   2) machine admin account credential matches cyberark safe account password
   3) machine service account passwords match cyberark safe account passwords
3) pass machine and service route PKI certificate authority (ca) checks 
   1) valid ca root cert 
   2) valid ca signed cert chain(s) 
   3) non-expired 
   4) non-revoked
4) pass system truststore checks (valid root cert, only corp-valid certs and cert chains)
5) pass check OS/SW version/patch updates are up-to-date
6) pass service list check to validate that only 'defined' services are running 
7) pass critical set OS compliance checks 
8) pass disk storage checks  with defined threshold/tolerance/limit
   1) tempfs / etc
   2) log rotations performed 
   3) total log size (e.g., 'du -h --max-depth=1 --exclude=nfs --exclude=proc --no-dereference /var/log') 
   4) file log sizes
9) pass machine resources checks with defined threshold/tolerance/limit 
   1) Number of ionodes consumed/free(avail)
   2) Number of connections consumed/free(avail)
   3) Number of open file handles
10) if DB machine, pass DB specific checks meets defined threshold/tolerance/limit 
    1) disk IOmeter test  
    2) tempDb size
11) validate VM backups are valid/current if defined

#### Challenge/Limits to "monitoring-agent" focused approach to inventory state

In many circumstances, some/many of these "lights-on" tests/checks can also fall into site "monitoring" checks.

As such, it can be debated that some/many of these may not be needed or necessary for deployment smoke tests purposes since they would be redundant.

The challenge and possible problem(s) with the monitoring-only approach is:

1) the resource configurations should be defined for hosts in the host inventory
2) validation is done comparing the host runtime state against defined inventory state derived from the host group_vars.<br>
   For example, hosts defined in a 'windows_mssql' group can have group_vars defining the 'tempDb' configuration.
   The site smoke test can then compare the group_vars defined with the host runtime configuration to determine the smoke test pass/fail status.
   This approach benefits from a single-source-of-truth for the type of host based on group_vars defined in the inventory.

#### Inventory host configurations comparison with host runtime state

Assuming all group_vars and host_vars are setup to fully configure and specify any host machine, smoke tests can then be executed on a regular basis to compare the host runtime configuration versus the intended inventory configuration.  This would provide a very robust solution for monitoring and assessing the state of the inventory.
Failed tests should highlight hosts requiring some care in aligning with the inventory, or the inventory may require to be updated to reflect the new configuration of any host that does not align with the group_vars/host_vars state.  

#### Regression tests

The feature regression tests are usually comprehensive sets of tests used to validate all the feature use cases.

Due to the amount of resource required to run through a comprehensive integration regression test, these tests are usually only targeted after code has successfully completed a number of quality gates (linting, smoke, etc) and at time of PR request.


#### New Feature tests

The new feature tests are usually sets of tests used to validate the new feature use cases and upon PR feature merge/deployment will then be considered part of the overall regression tests for the overall feature.


### Interoperability validation

The feature interoperability validation tests should look to determine if the feature is implemented in a way that sufficiently meets integration requirements with existing environment components/APIs/libraries/OS versions/etc.

The benefit of implementing interoperability test automation is that at any time going forward, feature interoperability can be easily validated whenever the following occurs: 

1) new features are added to the existing feature set (regression)
2) changes are made with respect to supporting/dependent libraries/components used by the feature
3) changes are made with respect to the feature environment


### Performance validation

The feature performance validation tests should look to determine if the feature is implemented in a way that sufficiently meets performance requirements.

For example, if the 'deploy-VM' role has a performance requirement to be able to deploy 10 VMs in less than 5 minutes, then tests should be set up to validate that this performance requirement.

The benefit of implementing performance test automation is that at any time going forward, feature performance can be easily validated whenever the following occurs: 

1) new features are added to the existing feature set (regression)
2) changes are made with respect to supporting/dependent libraries/components used by the feature
3) changes are made with respect to the feature environment


### Multiple target hosts validation

When developing a feature requiring a new role, the feature is ultimately going to be applied to targeted set of machines.
Most of the patterns/use cases discussed in the following sections involve using ansible 'groups' to properly categorize the set of machines/hosts to be targeted by the ansible plays.

Most features will get deployed to multiple target hosts defined by a group.

While a feature may have been developed and tested for a single machine, it is important that the feature is also executed for multiple hosts defined by a test group.
This will validate that the play/role based logic can execute correctly in realistic production group-based use case scenarios.

The test should create a 'mirror' test group with more than 1 test host in the test group such that the test will validate that it runs successfully and as expected in the end-state production scenarios where groups have multiple hosts defined.

### Multiple target groups validation

Some feature use cases require more multiple group configurations to be configured and validated/tested.

Consider a typical client-server use case.

For example, take a role that sets up postfix for the following 2 configurations into 2 sites (site1 and site4):

1) primary postfix server to relay traffic to an external outbound STMP agent and 
2) hosts defined in a group that will relay internal SMTP traffic to the corresponding site primary postfix server.  

Then consider the following configuration groups can be defined to support this role:

1) postfix_primary_relay_site1
2) postfix_primary_relay_site2
3) postfix_relay_client_site1
4) postfix_relay_client_site2

The test inventory can then define test groups to add test machines in the resulting 4 aforementioned groups in the following way/method:

#### Binding test groups to intended 'production'/'final' deployment groups 

1) Setup the 'production'/'final' groups to be PR'd and deployed:

This can be in a separate 'Sandbox/postfix.yml' inventory file or merged into the existing 'Sandbox/all.yml'.

Sandbox/postfix.yml
```yaml
---
postfix:
  children:
    postfix_primary_relay:
      children:
        postfix_primary_relay_site1:
        postfix_primary_relay_site2:
            
    postfix_relay_client:
      children:
         postfix_relay_client_site1:
         postfix_relay_client_site2:
```

2) Setup the test groups used to validate the group configuration to be PR'd and deployed:

Sandbox/testgroup.yml
```yaml
---
testgroup:
  children:
    testgroup_lnx:

      children:
        
        postfix:
          test_postfix_primary_relay: {}
          test_postfix_relay_client: {}
          
        testgroup_postfix:
          children:
           test_postfix_primary_relay:
              children:
                test_postfix_primary_relay_site1:
                  hosts:
                    toyboxd1s1.example.int: {}
                test_postfix_primary_relay_site2:
                  hosts:
                    toyboxd1s4.example.int: {}
                   
            test_postfix_relay_client:
              children:
                 test_postfix_relay_client_site1:
                   vars:
                      postfix_relay_server: toyboxd1s1.example.int
                   hosts:
                     toyboxd[2:4]s1.example.int: {}
                 test_postfix_relay_client_site2:
                   vars:
                      postfix_relay_server: toyboxd1s4.example.int
                   hosts:
                     toyboxd[2:4]s4.example.int: {}


```

This will allow the test machines to be present in the 4 groups to be tested explicitly.

1) Check test inventory

```shell
ansible-inventory -i Sandbox/ --graph --yaml testgroup_postfix
ansible-inventory -i Sandbox/ --graph --yaml test_postfix_primary_relay
ansible-inventory -i Sandbox/ --graph --yaml test_postfix_relay_client
```

2) Check the group vars are correctly setup for the test hosts 

Group based query:
```shell
ansible -i Sandbox/ -m debug -a var=group_names testgroup_postfix
ansible -i Sandbox/ -m debug -a var=postfix_relay_server test_postfix_relay_client

```

3) Run on groups

Make sure to set up test groups to be tested in ./Sandbox/testgroup.yml

```shell
ansible-playbook run-role-tests.yml -i Sandbox/ -v -l testgroup_postfix
ansible-playbook run-role-tests.yml -i Sandbox/ -v -l test_postfix_primary_relay
ansible-playbook run-role-tests.yml -i Sandbox/ -v -l test_postfix_relay_client
```


## Ansible feature deployments

### Feature to PR deployment scenarios

The target set of machines can either be defined in an existing group, or require a new group to be defined.
Consider the following 2 use case examples.

#### 1: Feature for hosts already defined in existing groups

In this specific example, consider a new role to install and configure the 'ntp' service to be deployed to all machines in the following hypothetical already existing network group 'network_internal'.

In this case, the feature can be developed and PR'd into a single role-repo based PR supporting the feature deployment since the inventory group already exists.

#### 2: Feature for hosts defined in new groups

In this specific example, consider a new role to install and configure the windows 'RDS' services to be deployed to a subset of an existing windows inventory group.
We will define a new group of machines called 'windows_rds_host' that will contain the necessary subset of existing windows machines.

In this case, the feature can be developed and PR'd into two PRs supporting the feature deployment:

1) role-repo based PR
2) corresponding inventory repo PR - to define the new inventory group 'windows_rds_host' and the hosts defined in the group



## Patterns and Scopes requiring specific SOPs

### 1: Domain Use Cases 

This use case is common and usually involves:

1) SW Deployments involving Large Disjoint and/or Complementary Sub-Groups 
2) Inventory Configuration State for each sub-group (e.g., A/B or Client / Server machine configs within a network domain) 

When meeting these conditions, this SOP is required for any playbook and corresponding roles (e.g., client/server configurations).

Basically / put simply, whenever there is the following inventory group requirement conditions: 

1) a large group "A", and 
2) a very small/finite subset group "B" within "A", and 
3) the need exists to have a 3rd group "C" which is the difference of A - B = C, and 
4) the need to maintain the configuration state for each of the groups "A", "B", and "C" in group_vars/group[A|B|C].yml format

Many use cases require shared services enabling a complimentary set of clients within a defined superset group.

Service based use cases usually involve: 

1) a network or domain group "A" 
   Example domains/networks 
   1) 'DMZ'/'internal'/'cloud1'/'cloud2', 
   2) 'site1'/'site2'/../'siteN', 
   3) 'env1'/'env2'/../'envN', 
   4) 'prod'/'qa', 
   5) etc
2) a finite/small subset machines hosting shared services in group "B"  
3) a large subset of 'client' machines, group "C" that is the complement of group "B" within the superset group "A" ('domain', 'network', etc)

Example domain/network shared services:
- router/gateways/firewalls
- dns/dhcp 
- ntp/time/chrony
- ldap/AD 
- mail/postfix
- nfs/samba/cifs/storage
- archive servers (apache archiva, jfrog artifactory, sonatype nexus, etc)
- source code repo (bitbucket, gitlab, gitea, etc)
- etc (many other similar software network/client domain use cases)

#### Simple Example for a derived group

Currently, functionality exists in ansible playbook to sufficiently limit hosts to an implied "subset" set of machines using the [patterns supported by the limit feature](https://docs.ansible.com/ansible/latest/user_guide/intro_patterns.html).  For example, to specify all hosts in webservers except those in atlanta:

```shell
ansible-playbook site.yml --limit 'webservers:!atlanta' 
```

Now consider the following inventory use case.
![Derived Groups](./img/iac-derived-groups.png)

In the aforementioned diagram/example, to limit the targeted hosts to only clients:
```shell
ansible-playbook site.yml --limit 'network_a:!network_a_servers' 
```

However, if there are any configurations that the client group requires, then this method is insufficient.

Ideally, the YAML-based inventory could support derived groupings with operators similar to the limit directive.

For example, if the YAML-based inventory supported the following feature then the solution mentioned [here](https://github.com/lj020326/ansible-inventory-file-examples/tree/develop-lj/tests/ansible-multiple-yaml-inventories/example6) would not be necessary:

```yaml
all:
  children:
    network_a_clients: 
      hosts: network_a:!network_a_servers
      vars:
        network_server_list: "{{ groups['network_a_servers'] }}"
      
    network_a:
      hosts:
        admin01: {}
        admin02: {}
        admin03: {}
        machine10: {}
        machine11: {}
        machine12: {}
        ...
        ...
        ...
        machine99: {}
    
    network_a_servers:
      hosts:
        admin01: {}
        admin02: {}
        admin03: {}


```

But alas, the YAML-based ansible inventory does not support this feature, at least not at present.

#### Generalized Network Client-Server Use Case

Say the following parameters are given:

* A 'network' (parent) group has 100, 1000, or lets say __N machines__ and 
* A subset 'network_server' group only has a far less _finite number_ of instances, say 2, 4, or __M machines__
* A derived 'network_client' defined as the parent group of __N machines__ minus the server group of __M machines__.

So given an inventory with a 'network' group of 1000 machines, and a 'network_server' group of 4 machines, then the 'network_client' group would have 996 machines. 

Maintaining a 'network_client' group for multiple use-cases would have to re-define the child group of __(N - M) machines__. 

This can present risks since then each 'network_client' group is almost the same size as the parent 'network_server' group and exposes risks of maintaining synchronization of the group.

Multiply this by the number of use cases having the same/similar pattern.

Ideally, we do not want to explicitly define and maintain a 'network_client' group since it can be simply derived from the obtaining the difference of the 'network' and 'network_server' groups.

The ansible inventory solution [here](https://github.com/lj020326/ansible-inventory-file-examples/tree/develop-lj/tests/ansible-multiple-yaml-inventories/example6) details a working solution to the challenge of deriving the 'network_client' child group.  Specifically, the example illustrates how to derive an 'ntp_client_internal' group from explicitly defined ntp_network and ntp_server groups.

#### Use Case involving an actual Client-Server Example

For this example, we consider the steps necessary to deploy a client/server role, specifically, an ntp role [bootstrap_ntp](https://github.com/lj020326/ansible-datacenter/tree/main/roles/bootstrap-ntp).



More to follow....


### 2: DC Shared Role and/or Module Development (TBC)

This section remains to be completed (TBC).

This section will seek to document the processes, procedures, and/or steps required whenever changes and/or enhancements are made to any shared collection playbooks, roles and/or modules.


### 3: Linux Inventory, Playbook, Role Development (TBC)

This section remains to be completed (TBC).

This section will seek to document the process/procedures/steps required whenever changes/enhancements are made to any linux related inventory, playbooks, and/or roles.


### 4: Windows Inventory, Playbook, Role Development (TBC)

This section remains to be completed (TBC).

This section will seek to document the process/procedures/steps required whenever changes/enhancements are made to any windows related inventory, playbooks, roles, and/or modules.


### 5: Database Inventory, Playbook, Role Development (TBC)

This section remains to be completed (TBC).

This section will seek to document the process/procedures/steps required whenever changes/enhancements are made to any database related inventory, playbooks, roles, and/or modules.

### 6: Network Inventory, Playbook, Role Development (TBC)
This section remains to be completed (TBC).

This section will seek to document the process/procedures/steps required whenever changes/enhancements are made to any network related inventory, playbooks, roles, and/or modules.

### 7: Middleware Inventory, Playbook, Role Development (TBC)
This section remains to be completed (TBC).

This section will seek to document the process/procedures/steps required whenever changes/enhancements are made to any middleware related inventory, playbooks, roles, and/or modules.


### 8: Ansible Automation Management Role and/or Module Development (TBC)

This section remains to be completed (TBC).

This section will seek to document the processes, procedures, and/or steps required whenever changes and/or enhancements are made to any tower management related inventory, playbooks, roles and/or modules.


### 9: Ansible Inventory Change/Enhancement Development (TBC)

This section remains to be completed (TBC).

This section will seek to document the processes, procedures, and/or steps required whenever changes and/or enhancements are made to any tower-inventory related inventory.

