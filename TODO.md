
ANSIBLE DATACENTER TODO
====

[ ] 2022

    [ ] Setup awx with ansible-datacenter
        [ ] run original work config that now has task/job related issues along side of new clean config
        [ ] ansible-datacenter - setup dev branch and corresponding job templates in awx
        [ ] ansible-datacenter - move ldif to secrets

        AWX do not load group vars after add_host · Issue #11793 · ansible/awx
            https://github.com/ansible/awx/issues/11793
        Inventory group vars are not loaded · Issue #761 · ansible/awx
            https://github.com/ansible/awx/issues/761
        Inventory not including all group_vars when using multiple children (or all group)
            https://github.com/ansible/awx/issues/2574

        Ansible and Ansible Tower: best practices from the field
            http://www.juliosblog.com/ansible-and-ansible-tower-best-practices-from-the-field/

        awx & venv - Managing infrastructure using Ansible Tower | XLAB Steampunk blog
            https://steampunk.si/blog/managing-infrastructure-using-ansible-tower/

        good example awx playbook with groups
            https://murrahjm.github.io/Source-Control-and-the-Tower-Project/

        Automating the automation — Ansible Tower configuration as code
            https://www.redhat.com/en/blog/automating-automation-%E2%80%94-ansible-tower-configuration-code

        Well Structured Content Repositories :: Ansible Labs for Red Hat Summi
            https://people.redhat.com/grieger/summit2020_labs/ansible-tower-advanced/10-structured-content/

        Changing variable precedence in Ansible
            https://medium.com/opsops/changing-variable-precedence-in-ansible-a86c0c8373d7

        Playbook Variable | Ansible | Datacadamia
            https://datacadamia.com/infra/ansible/variable

        Ansible: Variables scope and precedence
            https://digitalis.io/blog/ansible/ansible-variables-scope-and-precedence/

        Workshop Exercise - Using Variables
            https://aap2.demoredhat.com/exercises/ansible_rhel/1.4-variables/

        ansible/test-playbooks: playbook-tests
            https://github.com/ansible/test-playbooks

        Developing and Testing Ansible Roles with Molecule and Podman
            https://www.ansible.com/blog/developing-and-testing-ansible-roles-with-molecule-and-podman-part-1

        Managing Windows servers with Ansible Tower
            https://4sysops.com/archives/managing-windows-servers-with-ansible-tower/


        https://ayakoubo.medium.com/openshift-4-x-automation-of-upi-deployment-by-ansible-tower-and-vsphere-preparations-81bb4001efe6
        http://vcloud-lab.com/entries/devops/step-by-step-guide-to-configure-first-project-job-template-on-ansible-awx-tower

    [ ] Setup DHCP for multiple scopes/zone (DEV/QA/PROD)

    [ ] Setup DHCP for multiple scopes/zone (DEV/QA/PROD)

    [ ] Setup DEV, QA and PROD openshift clusters

        https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.2/latest/
        https://ayakoubo.medium.com/openshift-4-x-automation-of-upi-deployment-by-ansible-tower-and-vsphere-preparations-81bb4001efe6
        https://github.com/openshift/installer/blob/master/docs/user/overview.md#installer-overview
        https://giters.com/rmetzler/openshift-ansible

        Setup router for respective environmental subnets
        https://univirt.wordpress.com/2020/04/29/a-basic-lab-setup-using-vyos-on-vsphere/
        http://keithlee.ie/2018/11/05/pks-nsx-t-home-lab-part-3-core-vms/
        http://keithlee.ie/2018/11/08/pks-nsx-t-home-lab-part-4-configuring-pfsense-router/

    [ ] Deploy from ovf template in ansible:
        https://docs.ansible.com/ansible/latest/collections/community/vmware/vmware_deploy_ovf_module.html


    [ ] Update blog for cicd-paas-example
        [ ] update ansible to run terraform to deploy apps onto openshift using pipeline

    [ ] Setup ansible test env using molecule/vagran
        https://github.com/lj020326/ansible-datacenter/tree/public/roles/solrcloud/molecule


    [ ] Update DNS records using ansible
        https://www.rubysecurity.org/Updating-BIND-DNS-records-using-Ansible
        https://stackoverflow.com/questions/61764320/ansible-nsupdate-module-adding-zone-to-record-value
        https://docs.ansible.com/ansible/latest/collections/community/general/nsupdate_module.html
        https://serverfault.com/questions/414734/setting-up-bind-to-work-with-nsupdate-servfail

        [ ] fix bind role to use /var/bind instead of /var/cache

    [ ] CICD Deployment pipeline
        Configure pipeline to use Ansible to run terraform deployments:

        https://github.com/lj020326/cicd-paas-example
        https://github.com/lj020326/ansible-datacenter/search?q=.war
        https://thecloudblog.net/post/simplifying-terraform-deployments-with-ansible-part-2/

        benefit - inventory derived from ansible to drive terraform

    [ ] Simplify terraform deployments with ansible:

        https://thecloudblog.net/post/simplifying-terraform-deployments-with-ansible-part-2/

    [ ] Setup blog markdown on hugo

        How to build a personal website with github pages and hugo:
        https://levelup.gitconnected.com/build-a-personal-website-with-github-pages-and-hugo-6c68592204c7


        https://vninja.net/2020/02/12/my-hugo-workflow/
        https://restlessdata.com.au/p/updating-a-blog-theme/
        https://github.com/mrjoh3/blog

[ ] Datacenter items:

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


    [ ] Migrating VM apps to Kubernetes using Ambassador API gateway:
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

        [ ] set automated cert renewal

            https://smallstep.com/docs/step-ca/certificate-authority-server-production#automated-renewal


    [ ] Setup k8s cert-manager

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

    [ ] Setup cert manager to

        - create cluster issue as signer
        - create certs for nodes
        - get signed certs for nodes from cluster
        - renew certificates at time of expiration
        - query to get list of expiring certificates
        - allow admin to view / manage certs

        - solves the issues around ansible node cacert create
            - currently when bootstraping a new node-
            - the process involves interaction between

            (1) the ansible control node,
            (2) the node getting provisioned, and
            (3) the cert manager node (called the keyring node in our playbooks)

            There are issues when the tasks running on the provisioned node delegate tasks to the cert manager
            The issues usually are ssh/sudo related to the cert manager
            We want to reduce/eliminate the dependency on ansible to automate the cert manager
            We prefer to use/leverage an API that ansible can then call to get the cacert for the node.

            Before creating one of our own - ask are there already ones available meeting the tasks above:

        Perhaps:
            https://cert-manager.io/docs/

            At first glance this appears to interact with other external 3rd party agents to create/sign the cer
            Need to research further if this server can also create internally ca signed certs.

            Results of search to date seems to indicate that this only operates/serves the kubernetes ecosystem.
            I cannot find any useful examples showing how to use this for baremetal cert create/signing use cases.

            it looks like it does all of this and more:

            https://www.redhat.com/sysadmin/cert-manager-operator-openshif
            https://github.com/jetstack/cert-manager
            https://cert-manager.io/docs/reference/api-docs/
            https://github.com/jetstack/cert-manager/tree/master/tes

            https://github.com/mmatur/traefik-cert-manager
            https://doc.traefik.io/traefik/providers/kubernetes-crd/
            https://elastisys.com/building-and-testing-base-images-for-kubernetes-cluster-nodes-with-packer-qemu-and-chef-inspec/
            https://itnext.io/cert-manager-native-x509-certificate-management-for-kubernetes-80ac478d314f

                https://itnext.io/how-to-expose-your-kubernetes-dashboard-with-cert-manager-422ab1e3bf30

                https://dzone.com/articles/secure-your-kubernetes-services-using-cert-manager

                https://github.com/bitnami/bitnami-docker-cert-manager
                https://github.com/bitnami/bitnami-docker-cert-manager/blob/master/docker-compose.yml

                https://stackoverflow.com/questions/51177410/create-issuer-for-cert-manager-for-rancher-2-x-launched-with-docker-compose
                https://www.2stacks.net/blog/rancher-2-and-letsencrypt/


        - perhaps use the following as simple example apps to use as a starting point:

            https://github.com/linuxserver/docker-healthchecks

            - healthcheck app
                - it has a good simple UI to manage healthchecks
                - migrate noun/subject from healthchecks to certs
                - it currently offers a simple API



    [X] setup pipeline to deploy multiple VMs using terraform:
        ssh://git@gitea.admin.dettonville.int:2222/infra/terraform-vmware-vm.gi

        upstream: https://netsyncr.io/creating-virtual-machines-in-vsphere-with-terraform/

    [X] Setup vm management on baremetal (admin01)
        [X] VMware esxi + vcenter
        [X] Openstack
        [P] Proxmox

        Considerations in deciding:
        [ ] wealth of docs / example use cases
        [ ] support for RDM and automation of RDM provisioning
            [ ] we are moving to disks/storage pool mgmt done by a VM - and need to pass thru the disks to the storage VM

    [ ] Setup full dev/test/prod CICD for webdev
        [ ] Use openshift to setup support full dev/test/prod CICD (per openshift example below) for webdev
        [ ] Marry/merge in mantl (do not use redhat specific tech (the router in the openshift case)
            https://dzone.com/articles/platform-as-code-with-openshift-amp-terraform
            https://github.com/clean-docker/ghost-cms
            https://github.com/lj020326/mantl

        possibly add static code analysis to CICD web dev pipeline:
            https://techexpert.tips/sonarqube/sonarqube-docker-installation/

    [D] Setup IPA server to manage cacert and signed certs for nodes
        deferred - nice to have - but not a necessity - given most of benefit would be for having a UI on top of LDAP/cert managemen

    [ ] push ca certs to gitea/archiva
        [ ] integrate with buildVmTemplate pipeline
        [ ] integrate with deploy-vm play

    [ ] push signer certs to archiva
        [ ] integrate with buildVmTemplate pipeline
        [ ] integrate with deploy-vm play

    [x] Setup new switch
        [x] use web UI to config vlans
        [X] firmware no longer avail for dell & old cisco switch
            - need jumbo frame suppor
            - and gig switch (e.g., get the more current sf200)
        [ ] setup cisco sf200

    [ ] Setup Proxmox

    [ ] Setup smokeping - keep track of network latency
        https://github.com/linuxserver/docker-smokeping

    [ ] Authelia setup
        [X] File based
        [X] Setup LDAP
        [ ] Confirm Authelia LDAP setup

    [ ] revisit IPA setup from nathancurry homelabs.ansible

    [ ] multi-cluster portainer setup:
        https://gist.github.com/deviantony/0d5fde119e9340a984af875244eced09

    [ ] Setup docker in swarm mode:
        5 cool apps using docker swarm mode:
        https://collabnix.com/5-cool-application-stacks-to-showcase-using-play-with-dockerpwd/


    [ ] Setup VM management (not vmware)
        [ ] openstack and / or proxmox

    [ ] Setup apache Spark cluster

    [ ] Setup models using Spark

    [ ] Setup msmtp as mail proxy client into gmail:

        motivation:
            https://forums.servethehome.com/index.php?threads/storage-server-w-mergerfs-snapraid-proxmox-zfs.28767/post-266482

        https://arnaudr.io/2020/08/24/send-emails-from-your-terminal-with-msmtp/
        https://marlam.de/msmtp/

        Docker image:
            https://github.com/alvistack/docker-msmtp
            https://owendavies.net/articles/setting-up-msmtp/


    [ ] Setup vlan subnets in pfsense NICs to protect dettonville.int from home network
        Question here is how to allow devices from subnet 2 to access the secure network Subnet1
        [ ] Then setup subnets using
            https://netosec.com/protect-home-network/
        [ ] Setup OPT2 nic as subnet2 and have home network connect to OPT2

    [X] Storage JBOD Setup

        [X] Setup JBOD drives to connect with storage VM

        [X] Setup Storage VM (nas02) with:

            [X] principally using these reference architectures:
                https://blog.linuxserver.io/2019/07/16/perfect-media-server-2019/
                https://selfhostedhome.com/combining-different-sized-drives-with-mergerfs-and-snapraid/

            [X] mergerFS
            [X] snapraid

            [x] Setup raid + snapshots

                Huge advantage using this configuration is ability to perform online Data Drive Replacements

                https://github.com/automorphism88/snapraid-btrfs
                ref: https://github.com/trapexit/mergerfs/wiki/Real-World-Deployments

                [ ] Use snapraid-btrfs
                    https://github.com/automorphism88/snapraid-btrfs
                    https://www.reddit.com/r/btrfs/comments/k93f16/using_btrfs_with_snapraid_and_snapper/
                    https://wiki.selfhosted.show/tools/snapraid-btrfs/

                [ ] btrfs snapshots+snapraid

            [ ] Optimize snapraid config:
                [ ] Tweak snapraid autosave to ~4-6TB, otherwise it will take a long ass time
                    ref: https://github.com/trapexit/mergerfs/wiki/Real-World-Deployments

            [ ] perform healthchecks:
                [ ] snapraid checks:
                    https://github.com/lj020326/snapraid-checks.gi
                    https://github.com/n8io/snapraid-checks

                [ ] file integrity checks
                    https://github.com/trapexit/scorch


            ESX02 Storage Adapters:
                "Name","LUN","Type","Capacity","Datastore","Operational State","Hardware Acceleration","Drive Type","Transport"
                "Local HGST Disk (naa.5000cca2620873d8)","0","disk","7.15 TB","Not Consumed","Attached","Not supported","HDD","SAS"
                "Local ATA Disk (naa.5000cca222e0abaf)","0","disk","1.82 TB","Not Consumed","Attached","Not supported","HDD","SAS"
                "Local ATA Disk (naa.5000cca373d3178e)","0","disk","931.51 GB","Not Consumed","Attached","Not supported","HDD","SAS"
                "Local ATA Disk (naa.50014ee0ac054fd7)","0","disk","931.51 GB","Not Consumed","Attached","Not supported","HDD","SAS"

            ESX02 Storage Devices:
                "Name","LUN","Type","Capacity","Datastore","Operational State","Hardware Acceleration","Drive Type","Transport"
                "Local DELL Disk (naa.6842b2b07215510026e1002d15013a7e)","0","disk","1.82 TB","esx02_ds1","Attached","Not supported","HDD","Parallel SCSI"
                "Local DELL Disk (naa.6842b2b07215510026d00fe7307d358f)","0","disk","931.00 GB","esx2_ds2","Attached","Not supported","HDD","Parallel SCSI"
                "Local DELL Disk (naa.6842b2b07215510026d00fe7307d8a68)","0","disk","931.00 GB","esx2_ds3","Attached","Not supported","HDD","Parallel SCSI"
                "Local DELL Disk (naa.6842b2b07215510026e1306b0d362237)","0","disk","1.82 TB","esx2_ds4","Attached","Not supported","HDD","Parallel SCSI"

                "Local ATA Disk (naa.5000cca373d3178e)","0","disk","931.51 GB","Not Consumed","Attached","Not supported","HDD","SAS"
                "Local ATA Disk (naa.50014ee0ac054fd7)","0","disk","931.51 GB","Not Consumed","Attached","Not supported","HDD","SAS"
                "Local ATA Disk (naa.5000cca222e0abaf)","0","disk","1.82 TB","Not Consumed","Attached","Not supported","HDD","SAS"
                "Local HGST Disk (naa.5000cca2620873d8)","0","disk","7.15 TB","Not Consumed","Attached","Not supported","HDD","SAS"

            Add disks to VM nas02
            Use webmin to wipe partition and format as ext4 and mount to /mnt/disk***

                cat /etc/fstab

                ...
                UUID=dfec8b74-a42c-48c5-b08c-a407a4e73200       /mnt/parity     ext4    defaults        0       0
                UUID=4cee9952-6216-46c1-b0f1-e9a85a21758b       /mnt/disk0181   ext4    defaults        0       0
                UUID=a80be579-2ca7-4e8e-8462-11a33b6eac97       /mnt/disk0091   ext4    defaults        0       0
                UUID=1f5751ab-9553-49a2-9168-f8ae37e11455       /mnt/disk0092   ext4    defaults        0       0

[ ] neat motd / display
    https://github.com/arsham/figurine

[ ] Setup new dettonville.org

    [ ] migrate wordpress to hugo


## Issues

  * esx00 host crash

    - 7:20:19 AM Size of scratch partition 6194203b-3a42f95f-c222-002590bdc802 is too small. Recommended scratch partition size is 4532 MiB
    - 7:20:19 AM File system [datastore1, 6194203a-0d147132-f0d5-002590bdc802] on volume 6194203a-e868ebeb-e39b-002590bdc802 has been mounted in rw mode on this host. 

    Resolution:
    * https://vinfrastructure.it/2017/12/esxi-6-5-scratch-partition-issues/
    

 