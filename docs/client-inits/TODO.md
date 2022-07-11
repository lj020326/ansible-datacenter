
ANSIBLE DATACENTER TODO
====

# 2022 Goals

## CICD Infrastructure Automation Priorities

[ ] Setup POC(s) (ideally with help from redhat/ansible engineering as needed) to be able to demonstrate how to run a single job template to bootstrap a simple NTP client/server configuration:

* DMZ and PCI networks across 2 sites (site1 and site4)
  
* using group_vars to derive the correct ntp_server configuration for each of the group configurations:
  
  - pci/site1
  - pci/site4
  - dmz/site1
  - dmz/site4

* demonstrating how to leverage instance group configuration integrating with group vars configurations.  E.g., if there are instance groups for each of the 4 groups above, ideally the appropriate groups are applied for each instance group configuration to properly derive the correct ntp_server configuration.  


[ ] Develop roles for idempotency and ability to run independently to achieve correct end-state:

    [ ] bootstrap-linux-packages
    [ ] bootstrap-linux-service-accounts
    [ ] bootstrap-linux-dns
    [ ] bootstrap-linux-ntp
    [ ] bootstrap-linux-firewalld
    [ ] bootstrap-linux-mounts
    [ ] bootstrap-linux-nfs (e.g., nfs-server)
    [ ] bootstrap-linux-postfix
    [ ] bootstrap-linux-sshd
    [ ] bootstrap-linux-core

    Use consistent group based pattern such that all settings can be compared with runtime to verify / generate drift reporting for each above as needed. 


[ ] Setup DEV, QA and PROD AWX clusters
 
[ ] Add functionality to deploy-vm role to support automated deployment for VM appliances:
    https://docs.ansible.com/ansible/latest/collections/community/vmware/vmware_deploy_ovf_module.html

[ ] Update ansible to run terraform to deploy apps onto openshift using pipeline

[ ] Setup automated CICD test pipelines for important plays (vm provisioning, bootstrap plays, etc)

    [ ] Setup ansible test env using molecule/vagrant
        https://github.com/lj020326/ansible-datacenter/blob/main/molecule/default/molecule.yml

[ ] CICD Deployment pipeline

    Configure pipeline to use Ansible to run terraform deployments.
    Benefits - utilizing the best feature sets of both products:

    * ansible inventory to drive terraform inputs
    * terraform deployment features 

    https://github.com/lj020326/cicd-paas-example
    https://github.com/lj020326/ansible-datacenter/blob/main/docs/terraform-deployments-with-ansible-part-1.md


[ ] add chef inspec tests to VM provisioning pipeline

    https://github.com/lj020326/ansible-datacenter/blob/9156de347d04e4ab2a1df10310b8c0ddf4ea183c/roles/ansible-role-inspec/README.md


[ ] Migrate configs and service delivery to [modern way to manage configurations for multiple environments and clouds](https://github.com/lj020326/ansible-datacenter/tree/main/docs/common-way-to-manage-configurations-for-multiple-environments-and-clouds.md)


Pie-in-the-sky / moonshot:

[ ] Ideally find a good node querying/editor opensource codebase that can used/adapted/refactored to view/query and edit the ansible-inventory repo YAMLs.

  Food for thought / fuel for ideas for some possible candidate in adapting to handling inventory viewing/editing use case possibilities:

    * https://docs.cloudify.co/5.1/trial_getting_started/examples/local/local_hello_world_example/
      * https://docs.cloudify.co/5.1/trial_getting_started/examples/first_service/aws_hello_world_example/
 
    * https://newcat.github.io/baklavajs/#/
    * rete.js 
       * https://github.com/retejs/rete
       * https://codepen.io/Ni55aN/pen/xzgQYq
    * https://cloud-pipelines.net/pipeline-editor/
    * https://github.com/miroiu/nodify
    * https://github.com/jerosoler/Drawflow


## Reference

* https://learn.hashicorp.com/tutorials/consul/service-mesh-zero-trust-network?in=consul/gs-consul-service-mesh
* https://learn.hashicorp.com/tutorials/consul/get-started-create-datacenter?in=consul/getting-started
* https://ayakoubo.medium.com/openshift-4-x-automation-of-upi-deployment-by-ansible-tower-and-vsphere-preparations-81bb4001efe6
* https://thecloudblog.net/post/simplifying-terraform-deployments-with-ansible-part-2/
* https://github.com/lj020326/cicd-paas-example
* https://traefik.io/blog/integrating-consul-connect-service-mesh-with-traefik-2-5/
* https://dzone.com/articles/platform-as-code-with-openshift-amp-terraform
* https://pypi.org/project/deploy-to-kubernetes/
* [containers-and-service-discovery](https://github.com/lj020326/ansible-datacenter/tree/main/docs/containers-and-service-discovery.md)

* [AWX do not load group vars after add_host · Issue #11793 · ansible/awx](https://github.com/ansible/awx/issues/11793)
* [Inventory group vars are not loaded · Issue #761 · ansible/awx](https://github.com/ansible/awx/issues/761)
* [Inventory not including all group_vars when using multiple children (or all group)](https://github.com/ansible/awx/issues/2574)
* [Ansible and Ansible Tower: best practices from the field](http://www.juliosblog.com/ansible-and-ansible-tower-best-practices-from-the-field/)
* [awx & venv - Managing infrastructure using Ansible Tower | XLAB Steampunk blog](https://steampunk.si/blog/managing-infrastructure-using-ansible-tower/)

* [good example awx playbook with groups](https://murrahjm.github.io/Source-Control-and-the-Tower-Project/)
* [Automating the automation — Ansible Tower configuration as code](https://www.redhat.com/en/blog/automating-automation-%E2%80%94-ansible-tower-configuration-code)
* [Well Structured Content Repositories :: Ansible Labs for Red Hat Summi](https://people.redhat.com/grieger/summit2020_labs/ansible-tower-advanced/10-structured-content/)
* [Changing variable precedence in Ansible](https://medium.com/opsops/changing-variable-precedence-in-ansible-a86c0c8373d7)
* [Playbook Variable | Ansible | Datacadamia](https://datacadamia.com/infra/ansible/variable)
* [Ansible: Variables scope and precedence](https://digitalis.io/blog/ansible/ansible-variables-scope-and-precedence/)
* [Workshop Exercise - Using Variables](https://aap2.demoredhat.com/exercises/ansible_rhel/1.4-variables/)
* [ansible/test-playbooks: playbook-tests](https://github.com/ansible/test-playbooks)
* [Developing and Testing Ansible Roles with Molecule and Podman](https://www.ansible.com/blog/developing-and-testing-ansible-roles-with-molecule-and-podman-part-1)
* [Managing Windows servers with Ansible Tower](https://4sysops.com/archives/managing-windows-servers-with-ansible-tower/)
* https://ayakoubo.medium.com/openshift-4-x-automation-of-upi-deployment-by-ansible-tower-and-vsphere-preparations-81bb4001efe6
* http://vcloud-lab.com/entries/devops/step-by-step-guide-to-configure-first-project-job-template-on-ansible-awx-tower

