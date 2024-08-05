
# ANSIBLE DATACENTER TODO

## Datacenter Client Applications

### Standardized 'docker service mesh' setup using ansible

Automate a standardized 'docker service mesh' using ansible:
* [Ansible playbook to setup array of docker mesh services](https://github.com/lj020326/matrix-docker-ansible-deploy)
  * This ansible playbook bootstraps your own [Docker Matrix](http://matrix.org/) server, along with the [various services](#supported-services) related to that.

### Setup apache Spark cluster

#### Setup models using Spark

## CICD Infrastructure Automation Priorities

### Setup example.int domain for running client demos

* Setup pipeline demos
  * ansible 'bootstrap' pipelines
  * ansible CICD / SDLC pipelines
    * pipeline based CICD promotions DEV -> QA -> PROD

Create / document detailed AAP CICD workflow/pipeline use cases

The demo PoC's should prove following CICD / SDLC pipeline/workflows:

  * create/update 'develop' branch  
    1) new/update playbook(s), 
    2) new/update roles
    3) new/update collections
    4) new/update AWX job templates
    5) update inventory
  * create PR branch for code repo(s) and inventory repo(s) 
    * use PR branches to test/run in QA AWX environment
  * create PR pull request into 'release' branch 
    * upon PR request, run full regression test automation 
    * run regression test playbooks (site.yml and any other key test playbooks) in QA AWX environment
    * review PR request and test status
  * merge PR into 'release' branch
    * test/run using the release branch in QA AWX environment

### Setup Ansible Automation Platform (AWX + Collection Hub e.g., PAH)

Implement ansible bootstrap play to set up multi-stage environment

[Ansible role to bootstrap AAP env](roles/bootstrap_awx/README.md)

* https://docs.ansible.com/ansible-tower/latest/html/quickinstall/install_script.html
* [Setting up LDAP for AAP controller and hub](./docs/ansible/ansible-automation-platform/lab-ldap-for-aap.md)

Setting up execution environments

* https://weiyentan.github.io/2021/creating-execution-environments/
* https://ansible-runner.readthedocs.io/en/latest/execution_environments/
* https://ansible-builder.readthedocs.io/en/latest/index.html
* https://devops.cisel.ch/awx-19-create-a-custom-awx-ee-docker-image

Setting up collections in tower using automation hub

* https://www.ansible.com/blog/installing-and-using-collections-on-ansible-tower
* https://www.ansible.com/blog/importing/exporting-collections-in-automation-hubs
* https://goetzrieger.github.io/ansible-collections/6-automation-hub-and-galaxy/

Set up constructed inventory demo using fact cache yaml plugin
* https://docs.ansible.com/ansible/latest/collections/ansible/builtin/constructed_inventory.html
* https://docs.ansible.com/ansible/latest/plugins/cache.html
* https://stackoverflow.com/questions/57529059/can-inventory-plugin-constructed-create-a-groups-based-on-ansible-facts
* https://www.lutro.me/posts/complex-groups-in-ansible-using-the-constructed-inventory-plugin
* https://stackoverflow.com/questions/52652782/where-are-set-facts-stored-for-ansible-when-cacheable-true
* https://www.typeerror.org/docs/ansible/collections/ansible/builtin/constructed_inventory 
* https://github.com/ansible/ansible/issues/37397



Similar methods not using ansible to set up for reference:

  * 'Kind' Method
    * https://netapp.io/2021/08/19/how-to-guide-setting-up-awx-on-a-single-host/
    * Creating a custom Docker image to install Kubernetes in Docker, referred to as ‘kind’, on the host with Docker
    * Note about kind: [kind](https://sigs.k8s.io/kind) is a tool for running local Kubernetes clusters using Docker container “nodes”.  
      * kind was primarily designed for testing Kubernetes itself, but may be used for local development or CI.

  * Openshift / AWX Series by ayakoubo covers: 
    1) installing tower into vsphere using template 
    2) setting up tower resources to support openshift deployment
    3) using tower to stand up openshift 
      * [ayakoubo](https://ayakoubo.medium.com/openshift-4-x-automation-of-upi-deployment-by-ansible-tower-and-vsphere-preparations-81bb4001efe6)
      * [ayakoubo](https://medium.com/@ayakoubo/openshift-4-x-automation-of-upi-deployment-by-ansible-f7cc902e3ade)

  * [WSL2 - manual CLI based setup](http://vcloud-lab.com/entries/devops/install-ansible-awx-tower-on-ubuntu-linux-os)
  * [WSL2 - primarily using powershell setup script `awxly-install.ps1`](https://github.com/TJoshua/awxly)
  * [Ubuntu manual](https://computingforgeeks.com/how-to-install-ansible-awx-on-ubuntu-linux/)

Redhat Ansible Automation Platform download(s)/blog(s)
* https://catalog.redhat.com/software/containers/ansible-automation-platform-21/ee-supported-rhel8/6177cff2be25a74c009224fa?container-tabs=gti
* https://www.ansible.com/blog/control-your-content-with-private-automation-hub
* https://www.ansible.com/blog/fun-with-private-automation-hub-part-1


### Setup AWX integration with conjur

* [Setup Conjur Dev Env](https://www.conjur.org/get-started/quick-start/oss-environment/)
  * https://github.com/cyberark/conjur-quickstart.git
* [Ansible integration with conjur](https://docs.conjur.org/Latest/en/Content/Integrations/ansible.html?tocpath=Integrations%7C_____1)
* https://github.com/cyberark/ansible-conjur-collection
* https://github.com/cyberark/ansible-conjur-collection/blob/main/plugins/lookup/conjur_variable.py
* https://github.com/infamousjoeg/instruqt/blob/22654a6ae7681846ae516489c5594935456fea33/tracks/conjur.org/secure-ansible-automation/09-secure-playbook/solve-host01#L13-L17


### Setup collection CICD using github

Reference repos that implement test automation and automation documentation generation/publishing:
- https://github.com/willshersystems/ansible-sshd

### Setup DEV, QA and PROD AWX clusters

### Setup DEV, QA and PROD docker/k8s/openshift clusters

* [Vsphere Openshift Setup](https://github.com/alanadiprastyo/openshift-4.6)
  * comprehensive easy-to-follow setup
  * [openshift registry setup](https://github.com/alanadiprastyo/openshift-4.6/tree/master/registry)
* https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.2/latest/
* https://ayakoubo.medium.com/openshift-4-x-automation-of-upi-deployment-by-ansible-tower-and-vsphere-preparations-81bb4001efe6
* https://github.com/openshift/installer/blob/master/docs/user/overview.md#installer-overview
* https://giters.com/rmetzler/openshift-ansible
* [proxied-openshift-nvidia-gpu-operator](./docs/openshift/proxied-openshift-nvidia-gpu-operator.md)

Install methods for reference:
* [installation of OCP 4.3 on VMware vSphere with static IPs using User Provisioned Infrastructure (UPI)](https://medium.com/icp-for-data/installing-openshift-4-3-7d8053cd64fd)
  * covers best practices for deploy IBM Cloud Pak for Data (CPD) 3.0.1 on OCP 4.3
  * provides realistic resource / network specifications 

* Setup hypervisor based router for respective PaaS environmental subnets
  * https://univirt.wordpress.com/2020/04/29/a-basic-lab-setup-using-vyos-on-vsphere/
  * http://keithlee.ie/2018/11/05/pks-nsx-t-home-lab-part-3-core-vms/
  * http://keithlee.ie/2018/11/08/pks-nsx-t-home-lab-part-4-configuring-pfsense-router/
  
### pfsense VMs - Set up multiple VM subnet gateways

* https://docs.netgate.com/pfsense/en/latest/recipes/virtualize-esxi.html

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


### Ansible Role to run chef inspec tests on target hosts

* [ansible_role_inspec](https://github.com/lj020326/ansible-datacenter/blob/9156de347d04e4ab2a1df10310b8c0ddf4ea183c/roles/ansible_role_inspec/README.md)
* https://www.digitalocean.com/community/tutorials/how-to-test-your-ansible-deployment-with-inspec-and-kitchen
* https://www.chef.io/blog/compliance-with-inspec-any-node-any-time-anywhere
* https://www.stackovercloud.com/2019/11/19/how-to-test-your-ansible-deployment-with-inspec-and-kitchen/
* 

### POC - Windows Role to manage AD Admin credentials for local machines

* [ansible-role-win_laps](https://github.com/jborean93/ansible-role-win_laps)
  This role can be used to do the following:

  - Install the server side components and add the required active directory schema objects and permissions 
  - Create a GPO to automatically push the LAPS configuration to clients 
  - Install the client side components

### Container service delivery

Migrate configs and service delivery to [modern way to manage configurations for multiple environments and clouds](https://github.com/lj020326/ansible-datacenter/tree/main/docs/ansible/inventory/common-way-to-manage-configurations-for-multiple-environments-and-clouds.md)

## Migrate tech-docs to gitbook

* https://www.gitbook.com/
* https://github.com/GitbookIO
* https://docs.gitbook.com/troubleshooting/connectivity-issues
* https://github.com/GitbookIO/example
* https://github.com/GitbookIO/gitbook
* https://docs.ibracorp.io/authelia/configuration-files/configuration.yml

## Other 

### Idempotent roles for key plays

Develop roles for idempotency and ability to run independently to achieve correct end-state:

Specifically, target the roles that take lists most often needed by other roles for implementing.

    [ ] bootstrap-linux-packages
    [ ] bootstrap-linux-service-accounts
    [ ] bootstrap-linux-firewalld
    [ ] bootstrap-linux-mounts
    [ ] bootstrap-linux-nfs (e.g., nfs-server)

    Use consistent group based pattern such that all settings can be compared with runtime to verify / generate drift reporting for each above as needed. 


### Graph/node view/editor of inventory

Ideally find a good node querying/editor opensource codebase that can used/adapted/refactored to 
1) view/query in a blueprint-like way/fashion and 2) edit the ansible-inventory repo YAMLs.

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

### Migrate configs and service delivery to [modern way to manage configurations for multiple environments and clouds](./docs/ansible/inventory/common-way-to-manage-configurations-for-multiple-environments-and-clouds.md)

### Setup KEA DHCP + PowerDNS Containers for API based DNS record updates using ansible

* https://computingforgeeks.com/running-powerdns-and-powerdns-admin-in-docker-containers/
* https://blog.devopstom.com/isc-dhcp-and-powerdns/
* https://github.com/rakheshster/docker-kea-knot
* https://github.com/mhiro2/docker-kea-dhcp-server

* https://github.com/mhiro2/docker-kea-dhcp-server/blob/master/docker-compose.yml
* https://carll.medium.com/get-up-and-running-on-with-your-own-dns-and-dhcp-server-from-scratch-powerdns-isc-dhcp-server-4b9d6185d275
* https://github.com/Akkadius/glass-isc-dhcp
* https://github.com/Akkadius/glass-isc-dhcp/blob/master/docker-compose.yaml
* https://github.com/networkboot/docker-dhcpd
* https://kifarunix.com/easily-install-and-setup-powerdns-admin-on-ubuntu-20-04/
* https://blog.eldernode.com/install-powerdns-and-powerdns-admin-on-debian-11/
* https://charlottemach.com/2021/09/08/powerdns.html
* 
* https://github.com/rakheshster/docker-kea-knot

## Cyberark Safe bootstrap automation

* https://github.com/cyberark/epv-api-scripts
* https://github.com/pspete/psPAS/blob/master/Tests/Set-PASSafeMember.Tests.ps1

## Modern UI

Some good modern UI implementations:

* https://github.com/morpheus65535/bazarr

### Simplify terraform deployments with ansible:

    https://thecloudblog.net/post/simplifying-terraform-deployments-with-ansible-part-2/

### Setup hugo site build/deploy pipeline in jenkins

    How to build a personal website with github pages and hugo:
    https://levelup.gitconnected.com/build-a-personal-website-with-github-pages-and-hugo-6c68592204c7

    https://vninja.net/2020/02/12/my-hugo-workflow/
    https://restlessdata.com.au/p/updating-a-blog-theme/
    https://github.com/mrjoh3/blog

## Datacenter Priorities

### Setup artifactory using ansible

* https://www.jfrog.com/confluence/display/JFROG/Installing+the+JFrog+Platform+Using+Ansible
* https://github.com/mattandes/ansible-role-artifactory
* https://github.com/quadewarren/ansible-role-artifactory

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

## Media stack enhancements

Check out container image features additions used in following:
* https://github.com/martinbjeldbak/self-hosted/blob/main/docker-compose.yml

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


