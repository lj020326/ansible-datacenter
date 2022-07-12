
# ANSIBLE DATACENTER TODO - 2022 Goals

## 1) Setup AWX POC(s) to simplify job_template inventory execution 

Goal(s)/Benefit(s):

(1) minimize development/deployment time/effort required for roles/plays to run across multiple networks/sites.<br>
(2) reduce risks due to multiple job template definitions/configurations for each network/site.<br>

Demonstrate how to run a single job template to bootstrap a simple NTP client/server configuration (with help/assist from redhat/ansible engineering if and as needed):

* DMZ and PCI networks across 2 sites (site1 and site4)
  
* using group_vars to derive the correct ntp_server configuration for each of the group configurations:
  
  - pci/site1
  - pci/site4
  - dmz/site1
  - dmz/site4

* POC should demonstrate how to leverage instance group configuration integrating with group vars configurations.<br>
 E.g., if there are instance groups for each of the 4 groups above, ideally the appropriate groups are applied for each instance group configuration to properly derive the correct ntp_server configuration.  


## 2) Setup automated CICD test pipelines for essential plays (vm provisioning, bootstrap plays, etc)

Goal(s)/Benefit(s): to enable high quality roles/plays by frequent PR based testing of essential roles/modules. 

See [ansible datacenter VM provisioning using molecule](https://github.com/lj020326/ansible-datacenter/blob/main/molecule/default/molecule.yml)


## 3) Refactor Roles using ansible inventory groups

Goal(s)/Benefit(s): 

(1) Use consistent framework/approach to setting all collection/group based variable states across the entire inventory.<br>
(2) Adopt ansible group var flexibility and best practices while minimizing risks due to multiple approaches and overusing global variable namespace.<br> 

Refactor Roles to use ansible inventory group vars to derive role var configuration for key provisioning plays.  

To accomplish this:

1) all role input variable names must be distinct to the role such that only one role is the consumer for the variable.<br>
2) setup role-groups to set values for the role to use for all hosts in the defined group.<br>
3) if and when using global variable names to obtain values, coerce/marshall the variable value from the global variable namespace to the role variable namespace.<br>

Find [example group vars marshalling/coercion of global to group role values here](https://github.com/lj020326/ansible-datacenter/blob/main/inventory/group_vars/docker_stack.yml)


## 4) Idempotent Common/Shared Roles

Goal(s)/Benefit(s): 

(1) Ability to efficiently run any selected idempotent role to achieve desired target machine configuration end-state for the role-purpose without having to replay all the roles for a given machine target. <br>
(2) Achieve re-usability of roles for dependent roles.<br> 
(3) Achieve single set of variables used to define end-state for each role such that the end-state definition may easily be compared with the corresponding audit information to properly produce drift comparison report between runtime and inventory/design state.<br>

Develop roles for idempotency and ability to run independently to achieve correct end-state:

Specifically, target the roles that take lists most often needed by other roles for implementing.

    [ ] bootstrap-linux-packages
    [ ] bootstrap-linux-service-accounts
    [ ] bootstrap-linux-firewalld
    [ ] bootstrap-linux-logrotate
    [ ] bootstrap-linux-mounts
    [ ] bootstrap-linux-nfs (e.g., nfs-server)

    Use consistent group based pattern such that all settings can be compared with runtime to verify / generate drift reporting for each above as needed. 

Find [example group vars setting for idempotent role values for mount and package here](https://github.com/lj020326/ansible-datacenter/blob/main/inventory/group_vars/cicd_node.yml)


## 5) Setup DEV, QA and PROD AWX clusters
 
Goal(s)/Benefit(s):

(1) Ability to execute plays/roles/modules in environment-agnostic approach such that no reconfiguration is required to promote plays/roles/module to upper envs.<br>
(2) Ability to setup CICD PR based pipeline test automation in formal TEST env.<br>
(3) Ability to test code integration in TEST env with prod-env-like fixtures/updates/upgrades (e.g., LDAP/AD, vaults, etc) before getting to prod env.<br>
(4) If there is a major component upgrade, the TEST env can be used to properly test and vet all necessary plays/roles/modules to make sure integration works before promoting the upgrade/update of the fixture to the PROD env.<br>
(5) Increased code quality due to ability to test in proper test environment. <br>

## 6) Setup Ansible role to deploy apps onto cloud based or openshift cluster using pipeline

Goal(s)/Benefit(s): Utilize the best feature sets of both products.

Configure pipeline to use Ansible to run terraform deployments.

* ansible inventory to drive terraform inputs
* terraform deployment features 

* https://github.com/lj020326/cicd-paas-example
* https://github.com/lj020326/ansible-datacenter/blob/main/docs/terraform-deployments-with-ansible-part-1.md


## 7) add chef inspec tests to VM provisioning pipeline

See [ansible inspec role to run inspec tests for target here](https://github.com/lj020326/ansible-datacenter/blob/9156de347d04e4ab2a1df10310b8c0ddf4ea183c/roles/ansible-role-inspec/README.md)

