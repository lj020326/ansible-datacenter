
# ANSIBLE DATACENTER TODO - 2022 Goals

## Datacenter Client Applications

### Setup apache Spark cluster

#### Setup models using Spark

## CICD Infrastructure Automation Priorities

### Idempotent roles for key plays

Develop roles for idempotency and ability to run independently to achieve correct end-state:

Specifically, target the roles that take lists most often needed by other roles for implementing.

    [ ] bootstrap-linux-packages
    [ ] bootstrap-linux-service-accounts
    [ ] bootstrap-linux-firewalld
    [ ] bootstrap-linux-mounts
    [ ] bootstrap-linux-nfs (e.g., nfs-server)

    Use consistent group based pattern such that all settings can be compared with runtime to verify / generate drift reporting for each above as needed. 


### Setup DEV, QA and PROD AWX clusters

### Setup DEV, QA and PROD openshift clusters

* https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.2/latest/
* https://ayakoubo.medium.com/openshift-4-x-automation-of-upi-deployment-by-ansible-tower-and-vsphere-preparations-81bb4001efe6
* https://github.com/openshift/installer/blob/master/docs/user/overview.md#installer-overview
* https://giters.com/rmetzler/openshift-ansible

* Setup hypervisor based router for respective PaaS environmental subnets
  * https://univirt.wordpress.com/2020/04/29/a-basic-lab-setup-using-vyos-on-vsphere/
  * http://keithlee.ie/2018/11/05/pks-nsx-t-home-lab-part-3-core-vms/
  * http://keithlee.ie/2018/11/08/pks-nsx-t-home-lab-part-4-configuring-pfsense-router/
  
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

### Container service delivery

Migrate configs and service delivery to [modern way to manage configurations for multiple environments and clouds](https://github.com/lj020326/ansible-datacenter/tree/main/docs/common-way-to-manage-configurations-for-multiple-environments-and-clouds.md)


## Pie-in-the-sky / moonshot

Ideally find a good node querying/editor opensource codebase that can used/adapted/refactored to view/query and edit the ansible-inventory repo YAMLs.

  Food for thought / fuel for ideas for some possible candidate in adapting to handling inventory viewing/editing use case possibilities:

    * https://docs.cloudify.co/5.1/trial_getting_started/examples/local/local_hello_world_example/
      * https://docs.cloudify.co/5.1/trial_getting_started/examples/first_service/aws_hello_world_example/


    * https://github.com/Cloud-Pipelines/pipeline-editor
    * https://github.com/newcat/baklavajs
    * https://newcat.github.io/baklavajs/#/styling
    * https://mrambourg.medium.com/use-baklavajs-with-nuxt-ba696c2a1602
    * https://github.com/sea-kg/pipeline-editor-s5
    * https://github.com/elyra-ai/pipeline-editor
    * https://github.com/jerosoler/Drawflow#node-example
    * https://github.com/alibaba/butterfly/blob/master/README.en-US.md
    * https://github.com/jagenjo/litegraph.js



    Node nesting capabilities:
    * https://github.com/miroiu/nodify
    * https://github.com/miroiu/nodify/blob/master/Examples/Nodify.Playground

    * https://newcat.github.io/baklavajs/#/
    * rete.js 
       * https://github.com/retejs/rete
       * https://codepen.io/Ni55aN/pen/xzgQYq
    * https://cloud-pipelines.net/pipeline-editor/
    * https://github.com/miroiu/nodify
    * https://github.com/jerosoler/Drawflow

### Migrate configs and service delivery to [modern way to manage configurations for multiple environments and clouds](./docs/common-way-to-manage-configurations-for-multiple-environments-and-clouds.md)

### Setup KEA DHCP + PowerDNS Containers for API based DNS record updates using ansible

https://computingforgeeks.com/running-powerdns-and-powerdns-admin-in-docker-containers/
https://blog.devopstom.com/isc-dhcp-and-powerdns/
https://github.com/rakheshster/docker-kea-knot
https://github.com/mhiro2/docker-kea-dhcp-server


### Simplify terraform deployments with ansible:

    https://thecloudblog.net/post/simplifying-terraform-deployments-with-ansible-part-2/

### Setup hugo site build/deploy pipeline in jenkins

    How to build a personal website with github pages and hugo:
    https://levelup.gitconnected.com/build-a-personal-website-with-github-pages-and-hugo-6c68592204c7

    https://vninja.net/2020/02/12/my-hugo-workflow/
    https://restlessdata.com.au/p/updating-a-blog-theme/
    https://github.com/mrjoh3/blog

## Datacenter Priorities

[X] add chef inspec to buildVmTemplate pipeline - performs checks before completing build

[p] Setup kubernetes cluster

    Deploying a Distributed AI Stack to Kubernetes on CentOS &
    Deploying Your Own x509 TLS Encryption files as Kubernetes Secrets

        https://pypi.org/project/deploy-to-kubernetes/
        https://github.com/jay-johnson/deploy-to-kubernetes
        https://github.com/lj020326/deploy-to-kubernetes
        https://elastisys.com/building-and-testing-base-images-for-kubernetes-cluster-nodes-with-packer-qemu-and-chef-inspec/

[p] Consul Setup (key-value pair server + dns)

    [ ] automated dns entry as services register dynamically
    [ ] config maps for docker apps?

    https://learn.hashicorp.com/tutorials/consul/get-started-create-datacenter?in=consul/getting-started
    https://learn.hashicorp.com/tutorials/consul/reference-architecture
    https://groups.google.com/g/consul-tool/c/0P_27-j3SYQ

    https://groups.google.com/g/consul-tool/c/Q_lZcETBsSg

    ref: https://groups.google.com/g/consul-tool/c/Q_lZcETBsSg/m/Bsz9lJzGBQAJ
    Suggested AWS network layout:

     - separate autonomous Application VPCs representing autonomous application environments (dev, qa, prod, stage)
     - single Management VPC for shared services (Chef, Monitoring Stack, etc...)
     - peering relationship that links application VPCs with Management VPCs


    Additional considerations:

     - single Consul cluster residing in Management VPC w/ namespacing and ACLs to permit access to shared services while preventing application cross-pollination.
     - Consul cluster per Application VPC (for application assets) + Consul cluster in Management VPC (for shared services) with WAN pooling.


    to provide best of both worlds:

     - complete application service autonomy
     - seamless service discovery of shared services


        https://github.com/mockingbirdconsulting/HashicorpAtHome
        https://www.budgetsmarthome.co.uk/2021/03/16/starting-to-visualise-the-smart-home/
        https://www.google.com/books/edition/Vagrant_Virtual_Development_Environment/UzDWBgAAQBAJ?hl=en&gbpv=0


### Migrating VM apps to Kubernetes using Ambassador API gateway:
    https://blog.getambassador.io/part-3-incremental-app-migration-from-vms-to-kubernetes-ambassador-and-consul-aacf87eea3e8
    Reference architecture:
        git clone git@github.com:datawire/pro-ref-arch.gi

[x] Vault setup (secrets for docker containers/etc)

[x] Setup container cert-manager

    [x] Step-ca
        https://smallstep.com/docs/step-ca/installation
        https://smallstep.com/docs/step-ca/certificate-authority-core-concepts

        Good working example how to integrate internal step-ca with traefik:
            https://github.com/Praqma/smallstep-ca-demo

        Step Issuer - a cert-manager's CertificateRequest controller that uses step certificates (a.k.a. step-ca) to sign the certificate requests.
        https://smallstep.com/blog/embarrassingly-easy-certificates-on-aws-azure-gcp/

       Using step-ca with cert-manager using cert-issuer:
        https://github.com/smallstep/step-issuer

    [P] set automated cert renewal

        https://smallstep.com/docs/step-ca/certificate-authority-server-production#automated-renewal


### Setup k8s cert-manager

    [ ] Configure cert-manager with step-ca:

        https://smallstep.com/docs/tutorials/kubernetes-acme-ca
        https://elastisys.com/building-and-testing-base-images-for-kubernetes-cluster-nodes-with-packer-qemu-and-chef-inspec/

    https://cert-manager.io/docs/
    https://cert-manager.io/v0.14-docs/usage/certificate/
    https://cert-manager.io/docs/tutorials/


    K8s with traefik + cert manager:
        https://github.com/lj020326/traefik-cert-manager
        https://github.com/mmatur/traefik-cert-manager

    Openshift + cert-manager
        https://www.redhat.com/sysadmin/cert-manager-operator-openshif

    Boulder-ca
        https://github.com/alemonmk/ansible_boulder_deploymen
        Use this if want full control of issuing CA subject, and have an existing root CA, otherwise use step-ca.
        PROS: it is the exact same component that ACME/LetsEncrypt uses
        CONS: its a behemoth to install - has many many components




[X] setup pipeline to deploy multiple VMs using terraform:
    ssh://git@gitea.admin.dettonville.int:2222/infra/terraform-vmware-vm.gi

    upstream: https://netsyncr.io/creating-virtual-machines-in-vsphere-with-terraform/

[X] Setup multiple vm hypervisors on baremetal (admin01)
    [X] VMware esxi + vcenter
    [X] Openstack
    [P] Proxmox

    Considerations in deciding:
    [ ] wealth of docs / example use cases
    [ ] support for RDM and automation of RDM provisioning
        [ ] we are moving to disks/storage pool mgmt done by a VM - and need to pass thru the disks to the storage VM

### Setup full dev/test/prod CICD for webdev

    [ ] Use openshift to setup support full dev/test/prod CICD (per openshift example below) for webdev

    [ ] Marry/merge in mantl (do not use redhat specific tech (the router in the openshift case)
        https://dzone.com/articles/platform-as-code-with-openshift-amp-terraform
        https://github.com/clean-docker/ghost-cms
        https://github.com/lj020326/mantl

    possibly add static code analysis to CICD web dev pipeline:
        https://techexpert.tips/sonarqube/sonarqube-docker-installation/

[D] Setup IPA server to manage cacert and signed certs for nodes
    deferred - nice to have - but not a necessity - given most of benefit would be for having a UI on top of LDAP/cert managemen

### push ca certs to gitea/archiva
    [ ] integrate with buildVmTemplate pipeline
    [ ] integrate with deploy-vm play

[x] push signer certs to archiva
    [ ] integrate with buildVmTemplate pipeline
    [ ] integrate with deploy-vm play

[x] Setup new switch

    [x] use web UI to config vlans
    [X] firmware no longer avail for dell & old cisco switch
        - need jumbo frame suppor
        - and gig switch (e.g., get the more current sf200)
    [ ] setup cisco sf200

### Setup smokeping - keep track of network latency
    https://github.com/linuxserver/docker-smokeping

### multi-cluster portainer setup:
    https://gist.github.com/deviantony/0d5fde119e9340a984af875244eced09

### Setup docker in swarm mode:
    5 cool apps using docker swarm mode:
    https://collabnix.com/5-cool-application-stacks-to-showcase-using-play-with-dockerpwd/

### Setup msmtp as mail proxy client into gmail:

    motivation:
        https://forums.servethehome.com/index.php?threads/storage-server-w-mergerfs-snapraid-proxmox-zfs.28767/post-266482

    https://arnaudr.io/2020/08/24/send-emails-from-your-terminal-with-msmtp/
    https://marlam.de/msmtp/

    Docker image:
        https://github.com/alvistack/docker-msmtp
        https://owendavies.net/articles/setting-up-msmtp/


### Setup vlan subnets in pfsense NICs to protect dettonville.int from home network
    Question here is how to allow devices from subnet 2 to access the secure network Subnet1

    [ ] Then setup subnets using
        https://netosec.com/protect-home-network/
    [ ] Setup OPT2 nic as subnet2 and have home network connect to OPT2


## Reference(s)


* https://learn.hashicorp.com/tutorials/consul/service-mesh-zero-trust-network?in=consul/gs-consul-service-mesh
* https://learn.hashicorp.com/tutorials/consul/get-started-create-datacenter?in=consul/getting-started
* https://ayakoubo.medium.com/openshift-4-x-automation-of-upi-deployment-by-ansible-tower-and-vsphere-preparations-81bb4001efe6
* https://thecloudblog.net/post/simplifying-terraform-deployments-with-ansible-part-2/
* https://github.com/lj020326/cicd-paas-example
* https://traefik.io/blog/integrating-consul-connect-service-mesh-with-traefik-2-5/
* https://dzone.com/articles/platform-as-code-with-openshift-amp-terraform
* https://pypi.org/project/deploy-to-kubernetes/
* [containers-and-service-discovery](./docs/containers-and-service-discovery.md)

* [AWX do not load group vars after add_host · Issue #11793 · ansible/awx](https://github.com/ansible/awx/issues/11793)
* [Inventory group vars are not loaded · Issue #761 · ansible/awx](https://github.com/ansible/awx/issues/761)
* [Inventory not including all group_vars when using multiple children (or all group)](https://github.com/ansible/awx/issues/2574)
* [Ansible and Ansible Tower: best practices from the field](http://www.juliosblog.com/ansible-and-ansible-tower-best-practices-from-the-field/)
* [awx & venv - Managing infrastructure using Ansible Tower | XLAB Steampunk blog](https://steampunk.si/blog/managing-infrastructure-using-ansible-tower/)

* https://www.rubysecurity.org/Updating-BIND-DNS-records-using-Ansible
* https://stackoverflow.com/questions/61764320/ansible-nsupdate-module-adding-zone-to-record-value
* https://docs.ansible.com/ansible/latest/collections/community/general/nsupdate_module.html
* https://serverfault.com/questions/414734/setting-up-bind-to-work-with-nsupdate-servfail

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


