
# ANSIBLE DATACENTER TODO - 2022 Goals

## CICD Infrastructure Automation Priorities

### Setup POC(s)

Ideally with help from redhat/ansible engineering as needed) to be able to demonstrate how to run a single job template to bootstrap a simple NTP client/server configuration:

* DMZ and PCI networks across 2 sites (site1 and site4)
  
* using group_vars to derive the correct ntp_server configuration for each of the group configurations:
  
  - pci/site1
  - pci/site4
  - dmz/site1
  - dmz/site4

* POC should demonstrate how to leverage instance group configuration integrating with group vars configurations.<br>
 E.g., if there are instance groups for each of the 4 groups above, ideally the appropriate groups are applied for each instance group configuration to properly derive the correct ntp_server configuration.  


### Idempotent Common/Shared Roles

Develop roles for idempotency and ability to run independently to achieve correct end-state:

Specifically, target the roles that take lists most often needed by other roles for implementing.

    [ ] bootstrap-linux-packages
    [ ] bootstrap-linux-service-accounts
    [ ] bootstrap-linux-firewalld
    [ ] bootstrap-linux-mounts
    [ ] bootstrap-linux-nfs (e.g., nfs-server)

    Use consistent group based pattern such that all settings can be compared with runtime to verify / generate drift reporting for each above as needed. 

### Refactor Roles using ansible inventory groups

Refactor Roles to use ansible inventory group vars to derive role var configuration for key provisioning plays.


### Setup DEV, QA and PROD AWX clusters
 
### VM appliances

Add functionality to deploy-vm role to support automated deployment for VM appliances:

    https://docs.ansible.com/ansible/latest/collections/community/vmware/vmware_deploy_ovf_module.html

### Setup automated CICD test pipelines for important plays (vm provisioning, bootstrap plays, etc)

    [ ] Setup ansible test env using molecule/vagrant
        https://github.com/lj020326/ansible-datacenter/blob/main/molecule/default/molecule.yml

### Setup Ansible role to deploy cloud based apps onto openshift using pipeline

    Configure pipeline to use Ansible to run terraform deployments.
    Benefits - utilizing the best feature sets of both products:

    * ansible inventory to drive terraform inputs
    * terraform deployment features 

    https://github.com/lj020326/cicd-paas-example
    https://github.com/lj020326/ansible-datacenter/blob/main/docs/terraform-deployments-with-ansible-part-1.md


### add chef inspec tests to VM provisioning pipeline

    https://github.com/lj020326/ansible-datacenter/blob/9156de347d04e4ab2a1df10310b8c0ddf4ea183c/roles/ansible-role-inspec/README.md

