## Console Output

```
Started by user admin
Loading library pipeline-automation-lib@master
Attempting to resolve master from remote references...
 > git --version # timeout=10
 > git --version # 'git version 2.30.2'
using GIT_ASKPASS to set credentials 
 > git ls-remote -h -- https://gitea.admin.dettonville.int/infra/pipeline-automation-lib.git # timeout=10
Found match: refs/heads/master revision b76a4948b000e5ad21b7c1b3a3ac3822fc39bee1
The recommended git tool is: NONE
using credential dcapi-jenkins-git-user
 > git rev-parse --resolve-git-dir /var/jenkins_home/workspace/dettonville/infra/ansible-datacenter/dev/bootstrap-linux@libs/1733a05d3ae2b07784f14771e944b9331eff50438c1371ba0f6c1be5f61331ab/.git # timeout=10
Fetching changes from the remote Git repository
 > git config remote.origin.url https://gitea.admin.dettonville.int/infra/pipeline-automation-lib.git # timeout=10
Fetching without tags
Fetching upstream changes from https://gitea.admin.dettonville.int/infra/pipeline-automation-lib.git
 > git --version # timeout=10
 > git --version # 'git version 2.30.2'
using GIT_ASKPASS to set credentials 
 > git fetch --no-tags --force --progress -- https://gitea.admin.dettonville.int/infra/pipeline-automation-lib.git +refs/heads/*:refs/remotes/origin/* # timeout=10
Checking out Revision b76a4948b000e5ad21b7c1b3a3ac3822fc39bee1 (master)
 > git config core.sparsecheckout # timeout=10
 > git checkout -f b76a4948b000e5ad21b7c1b3a3ac3822fc39bee1 # timeout=10
Commit message: "updates from ${HOSTNAME}"
[Pipeline] Start of Pipeline (hide)
[Pipeline] properties (hide)
[Pipeline] echo (hide)
[INFO] runAnsibleParamWrapper : runAnsibleParamWrapper(): config={
    "ansibleLimitHosts": "vmu20-01",
    "gitBranch": "master",
    "gitRepoUrl": "git@bitbucket.org:lj020326/ansible-datacenter.git",
    "gitCredId": "bitbucket-ssh-lj020326",
    "ansibleCollectionsRequirements": "collections/requirements.yml",
    "ansibleRolesRequirements": "./roles/requirements.yml",
    "ansibleTags": "bootstrap-linux",
    "environment": "dev",
    "ansibleInventory": "./inventory/dev/hosts.ini"
}
expected to call org.kohsuke.groovy.sandbox.impl.Checker.checkedCast but wound up catching org.jenkinsci.plugins.workflow.cps.CpsClosure2.call; see: https://jenkins.io/redirect/pipeline-cps-method-mismatches/
[Pipeline] echo (hide)
Right Now the Jenkins Agent Label Name is ansible
[Pipeline] node (hide)
Running on admin02 in /workspace/dettonville/infra/ansible-datacenter/dev/bootstrap-linux
[Pipeline] { (hide)
[Pipeline] timestamps (hide)
[Pipeline] { (hide)
[Pipeline] timeout (hide)
11:46:36  Timeout set to expire in 3 hr 0 min
[Pipeline] { (hide)
[Pipeline] stage (hide)
[Pipeline] { (Checkout) (hide)
[Pipeline] script (hide)
[Pipeline] { (hide)
[Pipeline] checkout (hide)
11:46:36  The recommended git tool is: NONE
11:46:36  using credential bitbucket-ssh-lj020326
11:46:36  Fetching changes from the remote Git repository
11:46:37  Checking out Revision 18e6bf2516478e33bd3aa8bfa78c522547350648 (origin/master)
11:44:27   > git rev-parse --resolve-git-dir /workspace/dettonville/infra/ansible-datacenter/dev/bootstrap-linux/.git # timeout=10
11:44:27   > git config remote.origin.url git@bitbucket.org:lj020326/ansible-datacenter.git # timeout=10
11:44:27  Fetching upstream changes from git@bitbucket.org:lj020326/ansible-datacenter.git
11:44:27   > git --version # timeout=10
11:44:28   > git --version # 'git version 2.25.1'
11:44:28  using GIT_SSH to set credentials bitbucket-ssh-lj020326
11:44:28   > git fetch --tags --force --progress -- git@bitbucket.org:lj020326/ansible-datacenter.git +refs/heads/*:refs/remotes/origin/* # timeout=10
11:44:28   > git rev-parse origin/master^{commit} # timeout=10
11:44:28   > git config core.sparsecheckout # timeout=10
11:44:28   > git checkout -f 18e6bf2516478e33bd3aa8bfa78c522547350648 # timeout=10
11:46:37  Commit message: " - modified:   inventory/group_vars/vmware_vm.yml"
11:44:28   > git rev-list --no-walk 18e6bf2516478e33bd3aa8bfa78c522547350648 # timeout=10
[Pipeline] }
[Pipeline] // script
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage (hide)
[Pipeline] { (Run collections and roles Install) (hide)
[Pipeline] script (hide)
[Pipeline] { (hide)
[Pipeline] fileExists (hide)
[Pipeline] sh (hide)
11:46:38  + ansible-galaxy collection install -r collections/requirements.yml
11:46:39  Starting galaxy collection install process
11:46:39  Process install dependency map
11:46:57  Starting collection install process
11:46:57  Skipping 'ansible.posix' as it is already installed
11:46:57  Skipping 'community.general' as it is already installed
11:46:57  Skipping 'community.docker' as it is already installed
11:46:57  Skipping 'dellemc.openmanage' as it is already installed
11:46:57  Skipping 'sivel.toiletwater' as it is already installed
11:46:57  Skipping 'lvrfrc87.git_acp' as it is already installed
[Pipeline] fileExists (hide)
[Pipeline] sh (hide)
11:46:57  + ansible-galaxy install -r ./roles/requirements.yml
11:46:58  Starting galaxy role install process
11:46:58  - geerlingguy.git (master) is already installed, skipping.
11:46:58  - geerlingguy.java (master) is already installed, skipping.
11:46:58  - geerlingguy.ntp (master) is already installed, skipping.
11:46:58  - geerlingguy.pip (master) is already installed, skipping.
11:46:58  - geerlingguy.ansible (master) is already installed, skipping.
11:46:58  - geerlingguy.awx (master) is already installed, skipping.
11:46:58  - geerlingguy.nfs (master) is already installed, skipping.
11:46:58  - geerlingguy.jenkins (master) is already installed, skipping.
11:46:58  - geerlingguy.repo-epel (master) is already installed, skipping.
11:46:58  - geerlingguy.nodejs (master) is already installed, skipping.
11:46:58  - geerlingguy.postfix (master) is already installed, skipping.
11:46:58  - geerlingguy.packer (master) is already installed, skipping.
11:46:58  - gantsign.maven (master) is already installed, skipping.
11:46:58  - bertvv.dhcp (master) is already installed, skipping.
11:46:58  - ansible-role-docker (master) is already installed, skipping.
11:46:58  - githubixx.cfssl (master) is already installed, skipping.
11:46:58  - mrlesmithjr.netplan (master) is already installed, skipping.
11:46:58  - mrlesmithjr.cloud-init (master) is already installed, skipping.
11:46:58  - mrlesmithjr.ansible-config-interfaces (master) is already installed, skipping.
11:46:58  - mrlesmithjr.ansible-kvm (master) is already installed, skipping.
11:46:58  - willshersystems.sshd (master) is already installed, skipping.
11:46:58  - grog.package (master) is already installed, skipping.
11:46:58  - rossmcdonald.telegraf (master) is already installed, skipping.
11:46:58  - tumf.systemd-service (master) is already installed, skipping.
[Pipeline] }
[Pipeline] // script
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage (hide)
[Pipeline] { (Run Ansible Playbook) (hide)
[Pipeline] script (hide)
[Pipeline] { (hide)
[Pipeline] echo (hide)
11:46:59  [INFO] runAnsiblePlaybook : config={
11:46:59      "ansible": {
11:46:59          "installation": "ansible-local",
11:46:59          "playbook": "site.yml",
11:46:59          "inventory": "./inventory/dev/hosts.ini",
11:46:59          "tags": "bootstrap-linux",
11:46:59          "credentialsId": "jenkins-ansible-ssh",
11:46:59          "vaultCredentialsId": "ansible-vault-pwd-file",
11:46:59          "colorized": true,
11:46:59          "disableHostKeyChecking": true,
11:46:59          "extraParameters": [
11:46:59              
11:46:59          ],
11:46:59          "limit": "vmu20-01"
11:46:59      },
11:46:59      "ansibleLimitHosts": "vmu20-01",
11:46:59      "gitBranch": "master",
11:46:59      "gitRepoUrl": "git@bitbucket.org:lj020326/ansible-datacenter.git",
11:46:59      "gitCredId": "bitbucket-ssh-lj020326",
11:46:59      "ansibleCollectionsRequirements": "collections/requirements.yml",
11:46:59      "ansibleRolesRequirements": "./roles/requirements.yml",
11:46:59      "ansibleTags": "bootstrap-linux",
11:46:59      "environment": "dev",
11:46:59      "ansibleInventory": "./inventory/dev/hosts.ini",
11:46:59      "jenkinsNodeLabel": "ansible",
11:46:59      "logLevel": "INFO",
11:46:59      "debugPipeline": false,
11:46:59      "timeout": 3,
11:46:59      "timeoutUnit": "HOURS",
11:46:59      "emailDist": "ljohnson@dettonville.org",
11:46:59      "emailFrom": "admin+ansible@dettonville.com",
11:46:59      "skipDefaultCheckout": false,
11:46:59      "gitPerformCheckout": true,
11:46:59      "ansibleGalaxyForceOpt": "",
11:46:59      "ansibleSshCredId": "jenkins-ansible-ssh",
11:46:59      "ansibleVaultCredId": "ansible-vault-pwd-file",
11:46:59      "ansiblePlaybook": "site.yml"
11:46:59  }
[Pipeline] sh (hide)
11:46:59  + tree inventory/dev/group_vars
11:46:59  inventory/dev/group_vars
11:46:59  ├── all
11:46:59  │   ├── 000_cross_env_vars.yml -> ../../../group_vars/all.yml
11:46:59  │   └── env_specific.yml
11:46:59  ├── ansible_controller.yml -> ../../group_vars/ansible_controller.yml
11:46:59  ├── backup_server.yml -> ../../group_vars/backup_server.yml
11:46:59  ├── baremetal.yml -> ../../group_vars/baremetal.yml
11:46:59  ├── bind_master.yml -> ../../group_vars/bind_master.yml
11:46:59  ├── bind_slave.yml -> ../../group_vars/bind_slave.yml
11:46:59  ├── ca_domain_int_dettonville.yml -> ../../group_vars/ca_domain_int_dettonville.yml
11:46:59  ├── ca_domain_int_johnson.yml -> ../../group_vars/ca_domain_int_johnson.yml
11:46:59  ├── ca_domain.yml -> ../../group_vars/ca_domain.yml
11:46:59  ├── ca_keyring.yml -> ../../group_vars/ca_keyring.yml
11:46:59  ├── cert_node.yml -> ../../group_vars/cert_node.yml
11:46:59  ├── chef_inspec.yml -> ../../group_vars/chef_inspec.yml
11:46:59  ├── cicd_node.yml -> ../../group_vars/cicd_node.yml
11:46:59  ├── cloudstack_cluster.yml -> ../../group_vars/cloudstack_cluster.yml
11:46:59  ├── cloudstack_master.yml -> ../../group_vars/cloudstack_master.yml
11:46:59  ├── dell_idrac_hosts.yml -> ../../group_vars/dell_idrac_hosts.yml
11:46:59  ├── deploy_vm_node.yml -> ../../group_vars/deploy_vm_node.yml
11:46:59  ├── deploy_vsphere_dc.yml -> ../../group_vars/deploy_vsphere_dc.yml
11:46:59  ├── dhcp_master.yml -> ../../group_vars/dhcp_master.yml
11:46:59  ├── dhcp_slave.yml -> ../../group_vars/dhcp_slave.yml
11:46:59  ├── docker_admin_node.yml -> ../../group_vars/docker_admin_node.yml
11:46:59  ├── docker_awx_node.yml -> ../../group_vars/docker_awx_node.yml
11:46:59  ├── docker_cobbler_node.yml -> ../../group_vars/docker_cobbler_node.yml
11:46:59  ├── docker_control_node.yml -> ../../group_vars/docker_control_node.yml
11:46:59  ├── docker_image_builder.yml -> ../../group_vars/docker_image_builder.yml
11:46:59  ├── docker_media_node.yml -> ../../group_vars/docker_media_node.yml
11:46:59  ├── docker_ml_node.yml -> ../../group_vars/docker_ml_node.yml
11:46:59  ├── docker_pxe_node.yml -> ../../group_vars/docker_pxe_node.yml
11:46:59  ├── docker_registry_service.yml -> ../../group_vars/docker_registry_service.yml
11:46:59  ├── docker_samba_node.yml -> ../../group_vars/docker_samba_node.yml
11:46:59  ├── docker_stack.yml -> ../../group_vars/docker_stack.yml
11:46:59  ├── docker.yml -> ../../group_vars/docker.yml
11:46:59  ├── fog_server.yml -> ../../group_vars/fog_server.yml
11:46:59  ├── iscsi_client.yml -> ../../group_vars/iscsi_client.yml
11:46:59  ├── jenkins_agent.yml -> ../../group_vars/jenkins_agent.yml
11:46:59  ├── jenkins_master.yml -> ../../group_vars/jenkins_master.yml
11:46:59  ├── k8s_cluster.yml -> ../../group_vars/k8s_cluster.yml
11:46:59  ├── kube_master.yml -> ../../group_vars/kube_master.yml
11:46:59  ├── kube_node.yml -> ../../group_vars/kube_node.yml
11:46:59  ├── ldap_client.yml -> ../../group_vars/ldap_client.yml
11:46:59  ├── linux_ip_dhcp.yml -> ../../group_vars/linux_ip_dhcp.yml
11:46:59  ├── linux_ip_static.yml -> ../../group_vars/linux_ip_static.yml
11:46:59  ├── os_linux_baremetal.yml -> ../../group_vars/os_linux_baremetal.yml
11:46:59  ├── os_linux.yml -> ../../group_vars/os_linux.yml
11:46:59  ├── mergerfs.yml -> ../../group_vars/mergerfs.yml
11:46:59  ├── nameserver.yml -> ../../group_vars/nameserver.yml
11:46:59  ├── ntp_client.yml -> ../../group_vars/ntp_client.yml
11:46:59  ├── openstack_control.yml -> ../../group_vars/openstack_control.yml
11:46:59  ├── openstack_kolla_node.yml -> ../../group_vars/openstack_kolla_node.yml
11:46:59  ├── os_CentOS_7.yml -> ../../group_vars/os_CentOS_7.yml
11:46:59  ├── os_CentOS.yml -> ../../group_vars/os_CentOS.yml
11:46:59  ├── os_Debian.yml -> ../../group_vars/os_Debian.yml
11:46:59  ├── os_Ubuntu_18.yml -> ../../group_vars/os_Ubuntu_18.yml
11:46:59  ├── os_Ubuntu_20.yml -> ../../group_vars/os_Ubuntu_20.yml
11:46:59  ├── os_Ubuntu.yml -> ../../group_vars/os_Ubuntu.yml
11:46:59  ├── postfix_client.yml -> ../../group_vars/postfix_client.yml
11:46:59  ├── postfix_server.yml -> ../../group_vars/postfix_server.yml
11:46:59  ├── proxmox.yml -> ../../group_vars/proxmox.yml
11:46:59  ├── samba_client.yml -> ../../group_vars/samba_client.yml
11:46:59  ├── step_ca_server.yml -> ../../group_vars/step_ca_server.yml
11:46:59  ├── veeam_agent.yml -> ../../group_vars/veeam_agent.yml
11:46:59  ├── vm_template.yml -> ../../group_vars/vm_template.yml
11:46:59  ├── vmware_esx_host.yml -> ../../group_vars/vmware_esx_host.yml
11:46:59  ├── vmware_flavor_centos8_medium.yml -> ../../group_vars/vmware_flavor_centos8_medium.yml
11:46:59  ├── vmware_flavor_centos8_small.yml -> ../../group_vars/vmware_flavor_centos8_small.yml
11:46:59  ├── vmware_flavor_ubuntu20_medium.yml -> ../../group_vars/vmware_flavor_ubuntu20_medium.yml
11:46:59  ├── vmware_flavor_ubuntu20_small.yml -> ../../group_vars/vmware_flavor_ubuntu20_small.yml
11:46:59  ├── vmware_nested_esx.yml -> ../../group_vars/vmware_nested_esx.yml
11:46:59  ├── vmware_physical_esx_host.yml -> ../../group_vars/vmware_physical_esx_host.yml
11:46:59  ├── vmware_vcenter.yml -> ../../group_vars/vmware_vcenter.yml
11:46:59  ├── vmware_vm_linux.yml -> ../../group_vars/vmware_vm_linux.yml
11:46:59  ├── vmware_vm_windows.yml -> ../../group_vars/vmware_vm_windows.yml
11:46:59  ├── vmware_vm.yml -> ../../group_vars/vmware_vm.yml
11:46:59  ├── vmware_vsphere.yml -> ../../group_vars/vmware_vsphere.yml
11:46:59  └── zookeeper.yml -> ../../group_vars/zookeeper.yml
11:46:59  
11:46:59  1 directory, 76 files
[Pipeline] withCredentials (hide)
11:46:59  Masking supported pattern matches of $ANSIBLE_SSH_USERNAME or $ANSIBLE_SSH_PASSWORD
[Pipeline] { (hide)
[Pipeline] ansiblePlaybook (hide)
11:44:52  [bootstrap-linux] $ /usr/local/bin/****-playbook site.yml -i ./inventory/dev/hosts.ini -l vmu20-01 -t bootstrap-linux -f 5 --private-key /workspace/dettonville/infra/****-datacenter/dev/bootstrap-linux/ssh14168035858218572379.key -u **** --vault-password-file /workspace/dettonville/infra/****-datacenter/dev/bootstrap-linux/vault8923262593350848434.password --extra-vars {}
11:44:54  [WARNING]: Could not match supplied host pattern, ignoring: server_offline
11:44:54  
11:44:54  PLAY [Gather facts for all hosts to apply OS specific group vars for them] *****
11:44:54  
11:44:54  TASK [Gathering Facts] *********************************************************
11:45:03  ok: [vmu20-01]
11:45:03  
11:45:03  TASK [Classify hosts depending on their OS distribution] ***********************
11:45:03  ok: [vmu20-01]
11:45:03  
11:45:03  TASK [Classify hosts depending on their OS distribution-version] ***************
11:45:04  ok: [vmu20-01]
11:45:04  
11:45:04  TASK [Print env var debug information] *****************************************
11:45:04  ok: [vmu20-01] => 
11:45:04    msg:
11:45:04    - inventory_hostname=vmu20-01
11:45:04    - inventory_hostname_short=vmu20-01
11:45:04    - internal_subdomain=
11:45:04    - internal_domain=johnson.int
11:45:04    - netbase__hostname=vmu20-01.johnson.int
11:45:04    - ****_host=vmu20-01.johnson.int
11:45:04    - ****_hostname=vmu20-01
11:45:04    - ****_fqdn=vmu20-01.johnson.int
11:45:04    - ****_default_ipv4.address=10.10.100.44
11:45:04    - ****_os_family=Debian
11:45:04    - ****_distribution=Ubuntu
11:45:04    - ****_distribution_release=focal
11:45:04    - ****_distribution_major_version=20
11:45:04    - ****_python_interpreter=/usr/bin/python3
11:45:04    - ****_pip_interpreter=pip3
11:45:04    - group_names=['ca_domain', 'ca_domain_int_johnson', 'cert_node', 'deploy_vm', 'dhcp_client_mac_interface', 'dhcp_hosts', 'esxi', 'ldap_client', 'linux_ip_dhcp', 'os_linux', 'nfs_service', 'ntp_client', 'os_Ubuntu', 'os_Ubuntu_20', 'postfix_client', 'server_node', 'server_vm', 'step_ca_cli', 'stepca_certs', 'vmware_flavor_ubuntu20_small', 'vmware_linux_ip_dhcp', 'vmware_ubuntu20_dhcp', 'vmware_ubuntu20_dhcp_int_johnson', 'vmware_ubuntu20_int_johnson', 'vmware_vm', 'vmware_vm_dhcp', 'vmware_vm_linux']
11:45:04    - ntp_servers=['10.0.0.1 prefer iburst']
11:45:04    - docker_stack_external_domain=
11:45:04    - docker_stack_internal_domain=
11:45:04    - ca_domain=johnson.int
11:45:04    - ca_domains_hosted=[]
11:45:04  
11:45:04  TASK [Print env var debug information] *****************************************
11:45:04  skipping: [vmu20-01]
11:45:04  
11:45:04  PLAY [Display bind info] *******************************************************
11:45:04  skipping: no hosts matched
11:45:04  
11:45:04  PLAY [Debug: Print environment variables] **************************************
11:45:04  
11:45:04  PLAY [Debug: Print internal variables] *****************************************
11:45:04  
11:45:04  PLAY [Bootstrap users] *********************************************************
11:45:04  
11:45:04  PLAY [Configure nameservers] ***************************************************
11:45:04  skipping: no hosts matched
11:45:04  
11:45:04  PLAY [Bootstrap linux] *********************************************************
11:45:04  
11:45:04  TASK [Gathering Facts] *********************************************************
11:45:06  ok: [vmu20-01]
11:45:06  
11:45:06  TASK [Setup vmware-tools] ******************************************************
11:45:06  
11:45:06  TASK [vmware-tools : Installing Open VMware Tools (open-vm-tools)] *************
11:45:09  ok: [vmu20-01]
11:45:09  
11:45:09  TASK [vmware-tools : Start vmtoolsd and enable vmtoolsd to start during boot] ***
11:45:10  ok: [vmu20-01]
11:45:10  
11:45:10  TASK [Setup geerlingguy.ntp] ***************************************************
11:45:10  
11:45:10  TASK [geerlingguy.ntp : Include OS-specific variables.] ************************
11:45:10  ok: [vmu20-01]
11:45:10  
11:45:10  TASK [geerlingguy.ntp : Set the ntp_driftfile variable.] ***********************
11:45:10  ok: [vmu20-01]
11:45:10  
11:45:10  TASK [geerlingguy.ntp : Set the ntp_package variable.] *************************
11:45:10  ok: [vmu20-01]
11:45:10  
11:45:10  TASK [geerlingguy.ntp : Set the ntp_config_file variable.] *********************
11:45:11  ok: [vmu20-01]
11:45:11  
11:45:11  TASK [geerlingguy.ntp : Set the ntp_daemon variable.] **************************
11:45:11  ok: [vmu20-01]
11:45:11  
11:45:11  TASK [geerlingguy.ntp : Ensure NTP package is installed.] **********************
11:45:12  ok: [vmu20-01]
11:45:12  
11:45:12  TASK [geerlingguy.ntp : Ensure tzdata package is installed (Linux).] ***********
11:45:14  ok: [vmu20-01]
11:45:14  
11:45:14  TASK [geerlingguy.ntp : Set timezone.] *****************************************
11:45:15  ok: [vmu20-01]
11:45:15  
11:45:15  TASK [geerlingguy.ntp : Populate service facts.] *******************************
11:45:29  ok: [vmu20-01]
11:45:29  
11:45:29  TASK [geerlingguy.ntp : Disable systemd-timesyncd if it's running but ntp is enabled.] ***
11:45:30  ok: [vmu20-01]
11:45:30  
11:45:30  TASK [geerlingguy.ntp : Ensure NTP is running and enabled as configured.] ******
11:45:30  ok: [vmu20-01]
11:45:30  
11:45:30  TASK [geerlingguy.ntp : Ensure NTP is stopped and disabled as configured.] *****
11:45:30  skipping: [vmu20-01]
11:45:30  
11:45:30  TASK [geerlingguy.ntp : Generate ntp configuration file.] **********************
11:45:32  ok: [vmu20-01]
11:45:32  
11:45:32  TASK [Setup ****-firewalld] *************************************************
11:45:32  
11:45:32  TASK [****-firewalld : include_vars] ****************************************
11:45:32  ok: [vmu20-01] => (item=/workspace/dettonville/infra/****-datacenter/dev/bootstrap-linux/roles/****-firewalld/vars/Debian.yml)
11:45:32  
11:45:32  TASK [****-firewalld : Install firewalld and firewalld-python packages] *****
11:45:34  ok: [vmu20-01]
11:45:34  
11:45:34  TASK [****-firewalld : Configure firewalld.conf] ****************************
11:45:34  ok: [vmu20-01] => (item={'key': 'DefaultZone', 'value': 'internal'})
11:45:35  ok: [vmu20-01] => (item={'key': 'IndividualCalls', 'value': 'yes'})
11:45:35  
11:45:35  TASK [****-firewalld : Configure firewalld zones] ***************************
11:45:36  changed: [vmu20-01] => (item=internal)
11:45:36  
11:45:36  TASK [****-firewalld : Get zones in /etc/firewalld/zones] *******************
11:45:37  ok: [vmu20-01]
11:45:37  
11:45:37  TASK [****-firewalld : Remove unmanaged zones in /etc/firewalld/zones] ******
11:45:38  changed: [vmu20-01] => (item=docker.xml)
11:45:38  skipping: [vmu20-01] => (item=internal.xml) 
11:45:38  
11:45:38  TASK [****-firewalld : Configure firewalld ipsets] **************************
11:45:38  
11:45:38  TASK [****-firewalld : Get ipsets in /etc/firewalld/ipsets] *****************
11:45:38  ok: [vmu20-01]
11:45:38  
11:45:38  TASK [****-firewalld : Remove unmanaged ipsets in /etc/firewalld/ipsets] ****
11:45:38  
11:45:38  TASK [****-firewalld : Configure firewalld custom services] *****************
11:45:38  skipping: [vmu20-01] => (item=ssh) 
11:45:38  skipping: [vmu20-01] => (item=ntp) 
11:45:39  ok: [vmu20-01] => (item=webmin)
11:45:39  
11:45:39  TASK [****-firewalld : display firewalld vars] ******************************
11:45:39  ok: [vmu20-01] => 
11:45:39    msg:
11:45:39    - |-
11:45:39      firewalld_zones: [
11:45:39          {
11:45:39              "description": "internal infrastructure hosts",
11:45:39              "name": "internal",
11:45:39              "service": [
11:45:39                  {
11:45:39                      "name": "webmin"
11:45:39                  },
11:45:39                  {
11:45:39                      "name": "ssh"
11:45:39                  }
11:45:39              ],
11:45:39              "short": "MGT",
11:45:39              "source": [
11:45:39                  {
11:45:39                      "address": "127.0.0.0/8"
11:45:39                  },
11:45:39                  {
11:45:39                      "address": "172.0.0.0/8"
11:45:39                  },
11:45:39                  {
11:45:39                      "address": "10.0.0.0/8"
11:45:39                  }
11:45:39              ],
11:45:39              "target": "ACCEPT"
11:45:39          }
11:45:39      ]
11:45:39  
11:45:39  TASK [****-firewalld : display firewalld vars] ******************************
11:45:39  ok: [vmu20-01] => 
11:45:39    msg:
11:45:39    - |-
11:45:39      firewalld_services: [
11:45:39          {
11:45:39              "name": "ssh"
11:45:39          },
11:45:39          {
11:45:39              "name": "ntp"
11:45:39          },
11:45:39          {
11:45:39              "custom": true,
11:45:39              "description": "webmin services",
11:45:39              "name": "webmin",
11:45:39              "port": [
11:45:39                  {
11:45:39                      "port": 10000,
11:45:39                      "protocol": "tcp"
11:45:39                  }
11:45:39              ],
11:45:39              "short": "webmin"
11:45:39          }
11:45:39      ]
11:45:39  
11:45:39  TASK [****-firewalld : Configure firewalld services] ************************
11:45:41  ok: [vmu20-01] => (item=internal - ssh)
11:45:42  changed: [vmu20-01] => (item=internal - ntp)
11:45:43  ok: [vmu20-01] => (item=internal - webmin)
11:45:43  
11:45:43  TASK [****-firewalld : Configure firewalld services] ************************
11:45:43  ok: [vmu20-01] => (item=internal - ssh)
11:45:44  ok: [vmu20-01] => (item=internal - ntp)
11:45:45  ok: [vmu20-01] => (item=internal - webmin)
11:45:45  
11:45:45  TASK [****-firewalld : Get services in /etc/firewalld/services] *************
11:45:45  ok: [vmu20-01]
11:45:45  
11:45:45  TASK [****-firewalld : Remove unmanaged services in /etc/firewalld/services] ***
11:45:45  skipping: [vmu20-01] => (item=webmin.xml) 
11:45:46  
11:45:46  TASK [****-firewalld : Start and enable firewalld] **************************
11:45:46  ok: [vmu20-01]
11:45:46  
11:45:46  TASK [****-firewalld : Configure running firewalld] *************************
11:45:47  changed: [vmu20-01] => (item={'zone': 'internal', 'immediate': 'yes', 'masquerade': 'yes', 'permanent': 'yes', 'state': 'enabled'})
11:45:47  
11:45:47  RUNNING HANDLER [****-firewalld : reload firewalld] *************************
11:45:50  changed: [vmu20-01]
11:45:50  
11:45:50  TASK [Setup firewall-config] ***************************************************
11:45:51  
11:45:51  TASK [firewall-config : Disable firewall] **************************************
11:45:51  skipping: [vmu20-01]
11:45:51  
11:45:51  TASK [firewall-config : Configure firewalld services] **************************
11:45:51  ok: [vmu20-01] => (item=internal - ssh)
11:45:52  ok: [vmu20-01] => (item=internal - ntp)
11:45:53  ok: [vmu20-01] => (item=internal - webmin)
11:45:53  
11:45:53  TASK [firewall-config : Allow ports through the firewall] **********************
11:45:53  changed: [vmu20-01] => (item=internal - 10000/tcp)
11:45:53  
11:45:53  TASK [Setup ****-postfix] ***************************************************
11:45:54  
11:45:54  TASK [****-postfix : include_vars] ******************************************
11:45:54  ok: [vmu20-01] => (item=/workspace/dettonville/infra/****-datacenter/dev/bootstrap-linux/roles/****-postfix/vars/Debian.yml)
11:45:54  
11:45:54  TASK [****-postfix : facts | set] *******************************************
11:45:54  ok: [vmu20-01]
11:45:54  
11:45:54  TASK [****-postfix : configure debconf] *************************************
11:45:56  ok: [vmu20-01] => (item={'name': 'postfix', 'question': 'postfix/main_mailer_type', 'value': 'No configuration', 'vtype': 'select'})
11:45:56  
11:45:56  TASK [****-postfix : install package] ***************************************
11:45:58  ok: [vmu20-01]
11:45:58  
11:45:58  TASK [****-postfix : configure mailname] ************************************
11:45:58  ok: [vmu20-01]
11:45:58  
11:45:58  TASK [****-postfix : update configuration file] *****************************
11:45:59  ok: [vmu20-01]
11:45:59  
11:45:59  TASK [****-postfix : configure sasl username/password] **********************
11:45:59  skipping: [vmu20-01]
11:45:59  
11:45:59  TASK [****-postfix : configure aliases] *************************************
11:46:00  ok: [vmu20-01]
11:46:00  
11:46:00  TASK [****-postfix : check if aliases.db exists] ****************************
11:46:01  ok: [vmu20-01]
11:46:01  
11:46:01  TASK [****-postfix : configure virtual aliases] *****************************
11:46:02  ok: [vmu20-01] => (item={'virtual': 'root', 'alias': 'admin@dettonville.com'})
11:46:02  
11:46:02  TASK [****-postfix : configure sender canonical maps] ***********************
11:46:02  ok: [vmu20-01] => (item={'sender': 'root', 'rewrite': 'admin@dettonville.com'})
11:46:02  
11:46:02  TASK [****-postfix : configure recipient canonical maps] ********************
11:46:02  
11:46:02  TASK [****-postfix : configure transport maps] ******************************
11:46:02  
11:46:02  TASK [****-postfix : configure sender dependent relayhost maps] *************
11:46:03  
11:46:03  TASK [****-postfix : configure generic table] *******************************
11:46:03  
11:46:03  TASK [****-postfix : configure rbl_override] ********************************
11:46:03  skipping: [vmu20-01]
11:46:03  
11:46:03  TASK [****-postfix : configure header checks] *******************************
11:46:04  ok: [vmu20-01]
11:46:04  
11:46:04  TASK [Allow postfix traffic through the firewall] ******************************
11:46:04  
11:46:04  TASK [firewall-config : Disable firewall] **************************************
11:46:04  skipping: [vmu20-01]
11:46:04  
11:46:04  TASK [firewall-config : Configure firewalld services] **************************
11:46:05  ok: [vmu20-01] => (item=internal - ssh)
11:46:05  ok: [vmu20-01] => (item=internal - ntp)
11:46:06  ok: [vmu20-01] => (item=internal - webmin)
11:46:06  
11:46:06  TASK [firewall-config : Allow ports through the firewall] **********************
11:46:06  
11:46:06  TASK [****-postfix : start and enable service] ******************************
11:46:07  ok: [vmu20-01]
11:46:07  
11:46:07  TASK [Setup geerlingguy.pip] ***************************************************
11:46:07  
11:46:07  TASK [geerlingguy.pip : Ensure Pip is installed.] ******************************
11:46:08  ok: [vmu20-01]
11:46:08  
11:46:08  TASK [geerlingguy.pip : Ensure pip_install_packages are installed.] ************
11:46:09  
11:46:09  TASK [Setup geerlingguy.java] **************************************************
11:46:09  
11:46:09  TASK [geerlingguy.java : Include OS-specific variables for Fedora or FreeBSD.] ***
11:46:09  skipping: [vmu20-01]
11:46:09  
11:46:09  TASK [geerlingguy.java : Include version-specific variables for CentOS/RHEL.] ***
11:46:09  skipping: [vmu20-01]
11:46:09  
11:46:09  TASK [geerlingguy.java : Include version-specific variables for Ubuntu.] *******
11:46:09  ok: [vmu20-01]
11:46:09  
11:46:09  TASK [geerlingguy.java : Include version-specific variables for Debian.] *******
11:46:09  ok: [vmu20-01]
11:46:09  
11:46:09  TASK [geerlingguy.java : Define java_packages.] ********************************
11:46:09  ok: [vmu20-01]
11:46:09  
11:46:09  TASK [geerlingguy.java : include_tasks] ****************************************
11:46:09  skipping: [vmu20-01]
11:46:09  
11:46:09  TASK [geerlingguy.java : include_tasks] ****************************************
11:46:09  included: /workspace/dettonville/infra/****-datacenter/dev/bootstrap-linux/roles/geerlingguy.java/tasks/setup-Debian.yml for vmu20-01
11:46:10  
11:46:10  TASK [geerlingguy.java : Ensure 'man' directory exists.] ***********************
11:46:10  changed: [vmu20-01]
11:46:10  
11:46:10  TASK [geerlingguy.java : Ensure Java is installed.] ****************************
11:46:12  ok: [vmu20-01]
11:46:12  
11:46:12  TASK [geerlingguy.java : include_tasks] ****************************************
11:46:12  skipping: [vmu20-01]
11:46:12  
11:46:12  TASK [geerlingguy.java : Set JAVA_HOME if configured.] *************************
11:46:12  skipping: [vmu20-01]
11:46:12  
11:46:12  TASK [Setup bootstrap-linux-core] **********************************************
11:46:13  
11:46:13  TASK [bootstrap-linux-core : include_vars] *************************************
11:46:13  ok: [vmu20-01] => (item=/workspace/dettonville/infra/****-datacenter/dev/bootstrap-linux/roles/bootstrap-linux-core/vars/Ubuntu-20.yml)
11:46:13  
11:46:13  TASK [bootstrap-linux-core : Setup packages] ***********************************
11:46:13  included: /workspace/dettonville/infra/****-datacenter/dev/bootstrap-linux/roles/bootstrap-linux-core/tasks/packages.yml for vmu20-01
11:46:13  
11:46:13  TASK [bootstrap-linux-core : Update Debian repositories] ***********************
11:46:13  
11:46:13  TASK [bootstrap-linux-core : Update apt-get repo and cache] ********************
11:46:21  changed: [vmu20-01]
11:46:21  
11:46:21  TASK [bootstrap-linux-core : Update yum repo and cache] ************************
11:46:21  skipping: [vmu20-01]
11:46:21  
11:46:21  TASK [bootstrap-linux-core : get_cert_facts | Set ca_fetch_domains_list] *******
11:46:21  ok: [vmu20-01]
11:46:21  
11:46:21  TASK [bootstrap-linux-core : debug] ********************************************
11:46:22  ok: [vmu20-01] => 
11:46:22    __bootstrap_linux_packages: []
11:46:22  
11:46:22  TASK [bootstrap-linux-core : Installing Common Packages] ***********************
11:46:23  ok: [vmu20-01]
11:46:23  
11:46:23  TASK [bootstrap-linux-core : Install common pip libs] **************************
11:46:29  ok: [vmu20-01]
11:46:29  
11:46:29  TASK [bootstrap-linux-core : Setup environment] ********************************
11:46:29  included: /workspace/dettonville/infra/****-datacenter/dev/bootstrap-linux/roles/bootstrap-linux-core/tasks/env.yml for vmu20-01
11:46:29  
11:46:29  TASK [bootstrap-linux-core : Print bootstrap_linux_default_path info] ***********
11:46:29  ok: [vmu20-01] => 
11:46:29    bootstrap_linux_default_path: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
11:46:29  
11:46:29  TASK [bootstrap-linux-core : Set path in profile for all users] ****************
11:46:30  ok: [vmu20-01]
11:46:30  
11:46:30  TASK [bootstrap-linux-core : Set path for sudo] ********************************
11:46:31  ok: [vmu20-01]
11:46:31  
11:46:31  TASK [bootstrap-linux-core : Set path in environment] **************************
11:46:31  ok: [vmu20-01]
11:46:31  
11:46:31  TASK [bootstrap-linux-core : Create sysctl reboot cron] ************************
11:46:32  ok: [vmu20-01] => (item={'name': 'apply sysctl settings upon reboot', 'special_time': 'reboot', 'job': 'sysctl -p'})
11:46:32  
11:46:32  TASK [bootstrap-linux-core : Setup motd] ***************************************
11:46:32  included: /workspace/dettonville/infra/****-datacenter/dev/bootstrap-linux/roles/bootstrap-linux-core/tasks/motd.yml for vmu20-01
11:46:32  
11:46:32  TASK [bootstrap-linux-core : Remove ubuntu motd spam] **************************
11:46:33  ok: [vmu20-01] => (item=80-livepatch)
11:46:33  ok: [vmu20-01] => (item=95-hwe-eol)
11:46:34  ok: [vmu20-01] => (item=10-help-text)
11:46:34  
11:46:34  TASK [bootstrap-linux-core : Adding motd] **************************************
11:46:34  changed: [vmu20-01]
11:46:34  
11:46:34  TASK [bootstrap-linux-core : Setup figurine] ***********************************
11:46:34  included: /workspace/dettonville/infra/****-datacenter/dev/bootstrap-linux/roles/bootstrap-linux-core/tasks/figurine.yml for vmu20-01
11:46:35  
11:46:35  TASK [bootstrap-linux-core : check if figurine is installed already] ***********
11:46:35  ok: [vmu20-01]
11:46:35  
11:46:35  TASK [bootstrap-linux-core : download and unpack figurine] *********************
11:46:35  skipping: [vmu20-01]
11:46:35  
11:46:35  TASK [bootstrap-linux-core : move extracted file to bin directory] *************
11:46:35  skipping: [vmu20-01]
11:46:35  
11:46:35  TASK [bootstrap-linux-core : configure login] **********************************
11:46:36  ok: [vmu20-01]
11:46:36  
11:46:36  TASK [bootstrap-linux-core : Setup mounts] *************************************
11:46:36  included: /workspace/dettonville/infra/****-datacenter/dev/bootstrap-linux/roles/bootstrap-linux-core/tasks/mounts.yml for vmu20-01
11:46:36  
11:46:36  TASK [bootstrap-linux-core : set_fact] *****************************************
11:46:36  ok: [vmu20-01]
11:46:36  
11:46:36  TASK [bootstrap-linux-core : Ensure mount dirs exist] **************************
11:46:37  ok: [vmu20-01] => (item={'name': '/data', 'src': 'diskstation01.johnson.int:/volume1/data', 'fstype': 'nfs', 'options': 'intr,auto,_netdev'})
11:46:37  ok: [vmu20-01] => (item={'name': '/tmp', 'src': 'tmpfs', 'fstype': 'tmpfs', 'options': 'size=512m,defaults,noatime,nosuid,nodev,mode=1777'})
11:46:37  
11:46:37  TASK [bootstrap-linux-core : Add node mounts to fstab] *************************
11:46:39  changed: [vmu20-01] => (item={'name': '/data', 'src': 'diskstation01.johnson.int:/volume1/data', 'fstype': 'nfs', 'options': 'intr,auto,_netdev'})
11:46:39  ok: [vmu20-01] => (item={'name': '/tmp', 'src': 'tmpfs', 'fstype': 'tmpfs', 'options': 'size=512m,defaults,noatime,nosuid,nodev,mode=1777'})
11:46:39  
11:46:39  TASK [bootstrap-linux-core : Setup host name] **********************************
11:46:40  included: /workspace/dettonville/infra/****-datacenter/dev/bootstrap-linux/roles/bootstrap-linux-core/tasks/hostname.yml for vmu20-01
11:46:40  
11:46:40  TASK [bootstrap-linux-core : Display hostnames] ********************************
11:46:40  ok: [vmu20-01] => 
11:46:40    msg:
11:46:40    - internal_domain=johnson.int
11:46:40    - hostname_internal_domain=johnson.int
11:46:40    - hostname_name_short=vmu20-01
11:46:40    - hostname_name_full=vmu20-01.johnson.int
11:46:40  
11:46:40  TASK [bootstrap-linux-core : Hostname | Setting up hostname] *******************
11:46:41  ok: [vmu20-01]
11:46:41  
11:46:41  TASK [bootstrap-linux-core : Hostname | Configure hosts file.] *****************
11:46:42  ok: [vmu20-01]
11:46:42  
11:46:42  TASK [bootstrap-linux-core : Configure logging] ********************************
11:46:42  included: /workspace/dettonville/infra/****-datacenter/dev/bootstrap-linux/roles/bootstrap-linux-core/tasks/logging.yml for vmu20-01
11:46:42  
11:46:42  TASK [bootstrap-linux-core : configure rsyslog] ********************************
11:46:43  ok: [vmu20-01] => (item=rsyslog)
11:46:43  
11:46:43  TASK [bootstrap-linux-core : Enable journald persistence] **********************
11:46:44  ok: [vmu20-01]
11:46:44  
11:46:44  TASK [bootstrap-linux-core : remove journald rate limit burst limit] ***********
11:46:44  ok: [vmu20-01]
11:46:44  
11:46:44  TASK [bootstrap-linux-core : remove journald rate limit interval] **************
11:46:45  ok: [vmu20-01]
11:46:45  
11:46:45  TASK [bootstrap-linux-core : remove journald rate limit interval] **************
11:46:45  ok: [vmu20-01]
11:46:45  
11:46:45  TASK [bootstrap-linux-core : Create /var/log/journal] **************************
11:46:46  changed: [vmu20-01]
11:46:46  
11:46:46  TASK [bootstrap-linux-core : Setup backup scripts] *****************************
11:46:46  skipping: [vmu20-01]
11:46:46  
11:46:46  TASK [Setup willshersystems.sshd] **********************************************
11:46:46  
11:46:46  TASK [willshersystems.sshd : include_tasks] ************************************
11:46:46  included: /workspace/dettonville/infra/****-datacenter/dev/bootstrap-linux/roles/willshersystems.sshd/tasks/sshd.yml for vmu20-01
11:46:46  
11:46:46  TASK [willshersystems.sshd : include_tasks] ************************************
11:46:46  included: /workspace/dettonville/infra/****-datacenter/dev/bootstrap-linux/roles/willshersystems.sshd/tasks/variables.yml for vmu20-01
11:46:46  
11:46:46  TASK [willshersystems.sshd : Set OS dependent variables] ***********************
11:46:47  ok: [vmu20-01]
11:46:47  
11:46:47  TASK [willshersystems.sshd : include_tasks] ************************************
11:46:47  included: /workspace/dettonville/infra/****-datacenter/dev/bootstrap-linux/roles/willshersystems.sshd/tasks/install.yml for vmu20-01
11:46:47  
11:46:47  TASK [willshersystems.sshd : Install ssh packages] *****************************
11:46:48  ok: [vmu20-01]
11:46:48  
11:46:48  TASK [willshersystems.sshd : Sysconfig configuration] **************************
11:46:48  skipping: [vmu20-01]
11:46:48  
11:46:48  TASK [willshersystems.sshd : Check the kernel FIPS mode] ***********************
11:46:48  skipping: [vmu20-01]
11:46:48  
11:46:48  TASK [willshersystems.sshd : Check the userspace FIPS mode] ********************
11:46:48  skipping: [vmu20-01]
11:46:49  
11:46:49  TASK [willshersystems.sshd : Make sure hostkeys are available] *****************
11:46:49  
11:46:49  TASK [willshersystems.sshd : Make sure private hostkeys have expected permissions] ***
11:46:49  
11:46:49  TASK [willshersystems.sshd : Create a temporary hostkey for syntax verification if needed] ***
11:46:49  ok: [vmu20-01]
11:46:49  
11:46:49  TASK [willshersystems.sshd : Generate temporary hostkey] ***********************
11:46:50  ok: [vmu20-01]
11:46:50  
11:46:50  TASK [willshersystems.sshd : Make sure sshd runtime directory is present] ******
11:46:51  ok: [vmu20-01]
11:46:51  
11:46:51  TASK [willshersystems.sshd : Create the complete configuration file] ***********
11:46:51  ok: [vmu20-01]
11:46:51  
11:46:51  TASK [willshersystems.sshd : Update configuration file snippet] ****************
11:46:51  skipping: [vmu20-01]
11:46:52  
11:46:52  TASK [willshersystems.sshd : Remove temporary host keys] ***********************
11:46:52  ok: [vmu20-01]
11:46:52  
11:46:52  TASK [willshersystems.sshd : Install service unit file] ************************
11:46:52  skipping: [vmu20-01]
11:46:52  
11:46:52  TASK [willshersystems.sshd : Install instanced service unit file] **************
11:46:52  skipping: [vmu20-01]
11:46:52  
11:46:52  TASK [willshersystems.sshd : Install socket unit file] *************************
11:46:52  skipping: [vmu20-01]
11:46:52  
11:46:52  TASK [willshersystems.sshd : Service enabled and running] **********************
11:46:53  ok: [vmu20-01]
11:46:53  
11:46:53  TASK [willshersystems.sshd : Enable service in chroot] *************************
11:46:53  skipping: [vmu20-01]
11:46:53  
11:46:53  TASK [willshersystems.sshd : Register that this role has run] ******************
11:46:53  ok: [vmu20-01]
11:46:53  
11:46:53  TASK [Setup ldap-client] *******************************************************
11:46:53  
11:46:53  TASK [ldap-client : Install LDAP client packages] ******************************
11:46:55  ok: [vmu20-01]
11:46:55  
11:46:55  TASK [ldap-client : Copy ldap.conf configuration file] *************************
11:46:56  ok: [vmu20-01]
11:46:56  
11:46:56  TASK [ldap-client : Create link to ldap.conf] **********************************
11:46:56  ok: [vmu20-01]
11:46:56  
11:46:56  TASK [ldap-client : Setup ldap app config templates] ***************************
11:46:57  changed: [vmu20-01] => (item={'src': 'nslcd.conf.j2', 'dest': '/etc/nslcd.conf'})
11:46:58  ok: [vmu20-01] => (item={'src': 'nsswitch.conf.j2', 'dest': '/etc/nsswitch.conf'})
11:46:58  ok: [vmu20-01] => (item={'src': 'nscd.conf.j2', 'dest': '/etc/nscd.conf'})
11:46:58  
11:46:58  TASK [ldap-client : Setup ldap ssh fetchSSHKeysFromLDAP] ***********************
11:46:59  ok: [vmu20-01] => (item={'src': 'fetchSSHKeysFromLDAP.sh', 'dest': '/usr/local/bin/fetchSSHKeysFromLDAP'})
11:46:59  
11:46:59  TASK [ldap-client : Configure SSH to use PAM] **********************************
11:47:00  ok: [vmu20-01] => (item={'regexp': '(?i)^\\s*UsePAM\\b', 'insertafter': '(?i)^#\\s*UsePAM\\b', 'line': 'UsePAM yes'})
11:47:00  ok: [vmu20-01] => (item={'regexp': '(?i)^\\s*UseDNS\\b', 'insertafter': '(?i)^#\\s*UseDNS\\b', 'line': 'UseDNS no'})
11:47:00  
11:47:00  TASK [ldap-client : Enable NSLCD service] **************************************
11:47:01  ok: [vmu20-01]
11:47:01  
11:47:01  TASK [ldap-client : include_tasks] *********************************************
11:47:01  included: /workspace/dettonville/infra/****-datacenter/dev/bootstrap-linux/roles/ldap-client/tasks/configure_pam.Debian.yml for vmu20-01
11:47:01  
11:47:01  TASK [ldap-client : Nslcd daemon configuration file] ***************************
11:47:02  changed: [vmu20-01]
11:47:02  
11:47:02  TASK [ldap-client : Install custom PAM config] *********************************
11:47:02  ok: [vmu20-01]
11:47:02  
11:47:02  TASK [ldap-client : Clear NSCD passwd cache] ***********************************
11:47:03  changed: [vmu20-01]
11:47:03  
11:47:03  TASK [Setup users] *************************************************************
11:47:03  
11:47:03  TASK [bootstrap-user : Initialize homedir for users] ***************************
11:47:03  ok: [vmu20-01]
11:47:03  
11:47:03  TASK [bootstrap-user : Ensure group exist with correct gid] ********************
11:47:04  ok: [vmu20-01] => (item=root)
11:47:05  ok: [vmu20-01] => (item=administrator)
11:47:05  ok: [vmu20-01] => (item=****)
11:47:05  ok: [vmu20-01] => (item=container-user)
11:47:05  
11:47:05  TASK [bootstrap-user : Add users with groups] **********************************
11:47:06  changed: [vmu20-01] => (item=root)
11:47:07  changed: [vmu20-01] => (item=administrator)
11:47:08  changed: [vmu20-01] => (item=****)
11:47:08  changed: [vmu20-01] => (item=container-user)
11:47:08  
11:47:08  TASK [bootstrap-user : Check users password valid days] ************************
11:47:09  ok: [vmu20-01] => (item=root)
11:47:09  ok: [vmu20-01] => (item=administrator)
11:47:09  ok: [vmu20-01] => (item=****)
11:47:10  ok: [vmu20-01] => (item=container-user)
11:47:10  
11:47:10  TASK [bootstrap-user : Display user password valid days] ***********************
11:47:10  ok: [vmu20-01] => (item=root) => 
11:47:10    msg: output = 99999
11:47:10  ok: [vmu20-01] => (item=administrator) => 
11:47:10    msg: output = 99999
11:47:10  ok: [vmu20-01] => (item=****) => 
11:47:10    msg: output = 99999
11:47:10  ok: [vmu20-01] => (item=container-user) => 
11:47:10    msg: output = 99999
11:47:10  
11:47:10  TASK [bootstrap-user : Set users password valid days] **************************
11:47:10  skipping: [vmu20-01] => (item=root) 
11:47:11  changed: [vmu20-01] => (item=administrator)
11:47:11  changed: [vmu20-01] => (item=****)
11:47:11  skipping: [vmu20-01] => (item=container-user) 
11:47:11  
11:47:11  TASK [bootstrap-user : Add to sudoers] *****************************************
11:47:11  skipping: [vmu20-01] => (item=root) 
11:47:12  ok: [vmu20-01] => (item=administrator)
11:47:13  ok: [vmu20-01] => (item=****)
11:47:13  skipping: [vmu20-01] => (item=container-user) 
11:47:13  
11:47:13  TASK [bootstrap-user : Add .ssh directories] ***********************************
11:47:13  ok: [vmu20-01] => (item=root)
11:47:14  ok: [vmu20-01] => (item=administrator)
11:47:14  ok: [vmu20-01] => (item=****)
11:47:15  ok: [vmu20-01] => (item=container-user)
11:47:15  
11:47:15  TASK [bootstrap-user : Add user SSH authorized keys] ***************************
11:47:15  skipping: [vmu20-01] => (item=root) 
11:47:16  ok: [vmu20-01] => (item=administrator)
11:47:16  ok: [vmu20-01] => (item=****)
11:47:16  skipping: [vmu20-01] => (item=container-user) 
11:47:16  
11:47:16  TASK [bootstrap-user : Add user SSH private key] *******************************
11:47:17  ok: [vmu20-01] => (item=root)
11:47:18  ok: [vmu20-01] => (item=administrator)
11:47:19  ok: [vmu20-01] => (item=****)
11:47:19  skipping: [vmu20-01] => (item=container-user) 
11:47:19  
11:47:19  TASK [bootstrap-user : Add user SSH public key] ********************************
11:47:20  ok: [vmu20-01] => (item=root)
11:47:21  ok: [vmu20-01] => (item=administrator)
11:47:21  ok: [vmu20-01] => (item=****)
11:47:21  skipping: [vmu20-01] => (item=container-user) 
11:47:21  
11:47:21  TASK [bootstrap-user : Copy bash env files to home folder] *********************
11:47:22  ok: [vmu20-01] => (item=Copy .k8sh for root)
11:47:23  changed: [vmu20-01] => (item=Copy .bash_functions for root)
11:47:24  ok: [vmu20-01] => (item=Copy .sparse.bashrc for root)
11:47:24  changed: [vmu20-01] => (item=Copy .bash_env2 for root)
11:47:25  ok: [vmu20-01] => (item=Copy .bashrc for root)
11:47:26  ok: [vmu20-01] => (item=Copy .gitconfig.lj.tpl for root)
11:47:27  changed: [vmu20-01] => (item=Copy .bash_aliases for root)
11:47:27  ok: [vmu20-01] => (item=Copy .gitconfig.tpl for root)
11:47:28  ok: [vmu20-01] => (item=Copy .bash_prompt for root)
11:47:29  changed: [vmu20-01] => (item=Copy .bash_env for root)
11:47:30  ok: [vmu20-01] => (item=Copy .k8sh for administrator)
11:47:30  changed: [vmu20-01] => (item=Copy .bash_functions for administrator)
11:47:31  ok: [vmu20-01] => (item=Copy .sparse.bashrc for administrator)
11:47:32  changed: [vmu20-01] => (item=Copy .bash_env2 for administrator)
11:47:32  ok: [vmu20-01] => (item=Copy .bashrc for administrator)
11:47:33  ok: [vmu20-01] => (item=Copy .gitconfig.lj.tpl for administrator)
11:47:34  changed: [vmu20-01] => (item=Copy .bash_aliases for administrator)
11:47:35  ok: [vmu20-01] => (item=Copy .gitconfig.tpl for administrator)
11:47:35  ok: [vmu20-01] => (item=Copy .bash_prompt for administrator)
11:47:36  changed: [vmu20-01] => (item=Copy .bash_env for administrator)
11:47:37  ok: [vmu20-01] => (item=Copy .k8sh for ****)
11:47:38  changed: [vmu20-01] => (item=Copy .bash_functions for ****)
11:47:38  ok: [vmu20-01] => (item=Copy .sparse.bashrc for ****)
11:47:39  changed: [vmu20-01] => (item=Copy .bash_env2 for ****)
11:47:40  ok: [vmu20-01] => (item=Copy .bashrc for ****)
11:47:41  ok: [vmu20-01] => (item=Copy .gitconfig.lj.tpl for ****)
11:47:41  changed: [vmu20-01] => (item=Copy .bash_aliases for ****)
11:47:42  ok: [vmu20-01] => (item=Copy .gitconfig.tpl for ****)
11:47:43  ok: [vmu20-01] => (item=Copy .bash_prompt for ****)
11:47:44  changed: [vmu20-01] => (item=Copy .bash_env for ****)
11:47:44  ok: [vmu20-01] => (item=Copy .k8sh for container-user)
11:47:45  changed: [vmu20-01] => (item=Copy .bash_functions for container-user)
11:47:46  ok: [vmu20-01] => (item=Copy .sparse.bashrc for container-user)
11:47:47  changed: [vmu20-01] => (item=Copy .bash_env2 for container-user)
11:47:47  ok: [vmu20-01] => (item=Copy .bashrc for container-user)
11:47:48  ok: [vmu20-01] => (item=Copy .gitconfig.lj.tpl for container-user)
11:47:49  changed: [vmu20-01] => (item=Copy .bash_aliases for container-user)
11:47:50  ok: [vmu20-01] => (item=Copy .gitconfig.tpl for container-user)
11:47:50  ok: [vmu20-01] => (item=Copy .bash_prompt for container-user)
11:47:51  changed: [vmu20-01] => (item=Copy .bash_env for container-user)
11:47:51  
11:47:51  TASK [bootstrap-user : Copy bashlib files to home folder] **********************
11:47:52  ok: [vmu20-01] => (item=Copy logger.sh for root)
11:47:53  ok: [vmu20-01] => (item=Copy logger.sh for administrator)
11:47:53  ok: [vmu20-01] => (item=Copy logger.sh for ****)
11:47:54  ok: [vmu20-01] => (item=Copy logger.sh for container-user)
11:47:54  
11:47:54  TASK [Setup nfs-service] *******************************************************
11:47:54  
11:47:54  TASK [nfs-service : include_vars] **********************************************
11:47:54  ok: [vmu20-01] => (item=/workspace/dettonville/infra/****-datacenter/dev/bootstrap-linux/roles/nfs-service/vars/Debian.yml)
11:47:55  
11:47:55  TASK [nfs-service : Installing Packages required by nfs] ***********************
11:47:56  ok: [vmu20-01]
11:47:56  
11:47:56  TASK [Setup and run nfs] *******************************************************
11:47:56  
11:47:56  TASK [geerlingguy.nfs : Include OS-specific variables.] ************************
11:47:56  ok: [vmu20-01]
11:47:56  
11:47:56  TASK [geerlingguy.nfs : Include overrides specific to Fedora.] *****************
11:47:56  skipping: [vmu20-01]
11:47:56  
11:47:56  TASK [geerlingguy.nfs : include_tasks] *****************************************
11:47:56  skipping: [vmu20-01]
11:47:56  
11:47:56  TASK [geerlingguy.nfs : include_tasks] *****************************************
11:47:56  included: /workspace/dettonville/infra/****-datacenter/dev/bootstrap-linux/roles/geerlingguy.nfs/tasks/setup-Debian.yml for vmu20-01
11:47:56  
11:47:56  TASK [geerlingguy.nfs : Ensure NFS utilities are installed.] *******************
11:47:58  ok: [vmu20-01]
11:47:58  
11:47:58  TASK [geerlingguy.nfs : Ensure directories to export exist] ********************
11:47:58  
11:47:58  TASK [geerlingguy.nfs : Copy exports file.] ************************************
11:47:59  ok: [vmu20-01]
11:47:59  
11:47:59  TASK [geerlingguy.nfs : Ensure nfs is running.] ********************************
11:47:59  skipping: [vmu20-01]
11:47:59  
11:47:59  TASK [Allow nfs traffic through the firewall] **********************************
11:47:59  
11:47:59  TASK [firewall-config : Disable firewall] **************************************
11:47:59  skipping: [vmu20-01]
11:47:59  
11:47:59  TASK [firewall-config : Configure firewalld services] **************************
11:48:00  changed: [vmu20-01] => (item=internal - nfs)
11:48:01  changed: [vmu20-01] => (item=internal - mountd)
11:48:01  changed: [vmu20-01] => (item=internal - rpc-bind)
11:48:02  
11:48:02  TASK [firewall-config : Allow ports through the firewall] **********************
11:48:02  changed: [vmu20-01] => (item=internal - 2049/tcp)
11:48:03  changed: [vmu20-01] => (item=internal - 40073/tcp)
11:48:04  changed: [vmu20-01] => (item=internal - 40073/udp)
11:48:05  changed: [vmu20-01] => (item=internal - 445/tcp)
11:48:06  changed: [vmu20-01] => (item=internal - 139/tcp)
11:48:06  changed: [vmu20-01] => (item=internal - 2500-50000/udp)
11:48:07  changed: [vmu20-01] => (item=internal - 2500-50000/tcp)
11:48:07  
11:48:07  TASK [Allow veeam backup ports through the firewall] ***************************
11:48:07  skipping: [vmu20-01]
11:48:07  
11:48:07  TASK [Setup samba-client] ******************************************************
11:48:07  skipping: [vmu20-01]
11:48:07  
11:48:07  TASK [Setup webmin] ************************************************************
11:48:07  
11:48:07  TASK [webmin : include_vars] ***************************************************
11:48:07  ok: [vmu20-01] => (item=/workspace/dettonville/infra/****-datacenter/dev/bootstrap-linux/roles/webmin/vars/Debian.yml)
11:48:08  
11:48:08  TASK [Installing Packages required by webmin] **********************************
11:48:09  ok: [vmu20-01]
11:48:09  
11:48:09  TASK [webmin | Install automatically perl module PERL_MM_USE_DEFAULT] **********
11:48:10  ok: [vmu20-01]
11:48:10  
11:48:10  TASK [webmin | Echo PERL_MM_USE_DEFAULT again] *********************************
11:48:10  ok: [vmu20-01]
11:48:10  
11:48:10  TASK [webmin | Check perl] *****************************************************
11:48:11  ok: [vmu20-01]
11:48:11  
11:48:11  TASK [webmin | Install webmin mandatory dependencies] **************************
11:48:12  ok: [vmu20-01]
11:48:12  
11:48:12  TASK [webmin | Add Optional channel (Debian)] **********************************
11:48:13  ok: [vmu20-01]
11:48:13  
11:48:13  TASK [webmin | Addkey webmin] **************************************************
11:48:15  ok: [vmu20-01]
11:48:15  
11:48:15  TASK [webmin | Update apt-get repo and cache] **********************************
11:48:22  changed: [vmu20-01]
11:48:22  
11:48:22  TASK [webmin | Add Optional channel (RedHat)] **********************************
11:48:22  skipping: [vmu20-01]
11:48:22  
11:48:22  TASK [webmin | Add yum repository key] *****************************************
11:48:22  skipping: [vmu20-01]
11:48:22  
11:48:22  TASK [webmin : Update yum repo and cache] **************************************
11:48:22  skipping: [vmu20-01]
11:48:22  
11:48:22  TASK [webmin | Install webmin package] *****************************************
11:48:24  ok: [vmu20-01]
11:48:24  
11:48:24  TASK [webmin | Remove duplicate entry.] ****************************************
11:48:24  ok: [vmu20-01] => (item=webmin_repo_files)
11:48:24  
11:48:24  TASK [Setup ansible-role-docker] ************************************************
11:48:25  
11:48:25  TASK [ansible-role-docker : Check **** version] ******************************
11:48:25  skipping: [vmu20-01]
11:48:25  
11:48:25  TASK [ansible-role-docker : Docker | Manage OS not supported by docker-ce] ******
11:48:25  skipping: [vmu20-01]
11:48:25  
11:48:25  TASK [ansible-role-docker : Docker | Include Ubuntu specific variables] *********
11:48:25  ok: [vmu20-01]
11:48:25  
11:48:25  TASK [ansible-role-docker : Docker | Include Debian Family specific variables] ***
11:48:25  ok: [vmu20-01]
11:48:25  
11:48:25  TASK [ansible-role-docker : Docker | EE | Check Requirements] *******************
11:48:25  skipping: [vmu20-01]
11:48:25  
11:48:25  TASK [ansible-role-docker : Docker | Storage Driver] ****************************
11:48:25  skipping: [vmu20-01]
11:48:25  
11:48:25  TASK [ansible-role-docker : Docker | Start Installation] ************************
11:48:25  included: /workspace/dettonville/infra/****-datacenter/dev/bootstrap-linux/roles/ansible-role-docker/tasks/ce/apt.yml for vmu20-01
11:48:25  
11:48:25  TASK [ansible-role-docker : Docker | CE | APT | Remove old repo lxc-docker] *****
11:48:26  ok: [vmu20-01]
11:48:26  
11:48:26  TASK [ansible-role-docker : Docker | CE | APT | Install Prerequisits for APT] ***
11:48:28  ok: [vmu20-01]
11:48:28  
11:48:28  TASK [ansible-role-docker : Docker | CE | APT | Add Docker GPG Key] *************
11:48:29  ok: [vmu20-01]
11:48:29  
11:48:29  TASK [ansible-role-docker : Docker | CE | APT | Configure Docker repository] ****
11:48:30  ok: [vmu20-01]
11:48:30  
11:48:30  TASK [ansible-role-docker : Docker | CE | APT | Enable Edge repository] *********
11:48:30  skipping: [vmu20-01]
11:48:30  
11:48:30  TASK [ansible-role-docker : Docker | CE | APT | Perform specific os tasks] ******
11:48:30  included: /workspace/dettonville/infra/****-datacenter/dev/bootstrap-linux/roles/ansible-role-docker/tasks/ce/os/ubuntu.yml for vmu20-01 => (item=/workspace/dettonville/infra/****-datacenter/dev/bootstrap-linux/roles/ansible-role-docker/tasks/ce/os/ubuntu.yml)
11:48:30  
11:48:30  TASK [ansible-role-docker : Docker | CE | Ubuntu | Install the linux-image-extra kernal package] ***
11:48:30  skipping: [vmu20-01]
11:48:30  
11:48:30  TASK [ansible-role-docker : Docker | CE | Ubuntu | Install AppArmor Dependency] ***
11:48:30  skipping: [vmu20-01]
11:48:30  
11:48:30  TASK [ansible-role-docker : Docker | CE | APT | Install docker-ce] **************
11:48:32  ok: [vmu20-01]
11:48:32  
11:48:32  TASK [ansible-role-docker : Docker | Start Installation | Other repo] ***********
11:48:32  skipping: [vmu20-01]
11:48:32  
11:48:32  TASK [ansible-role-docker : Docker | Ensure service starts at boot] *************
11:48:32  ok: [vmu20-01]
11:48:32  
11:48:32  TASK [ansible-role-docker : Docker | Deploy Config] *****************************
11:48:32  included: /workspace/dettonville/infra/****-datacenter/dev/bootstrap-linux/roles/ansible-role-docker/tasks/deploy_config.yml for vmu20-01
11:48:32  
11:48:32  TASK [ansible-role-docker : Docker | Deploy Config | Make sure /etc/docker exists] ***
11:48:33  ok: [vmu20-01]
11:48:33  
11:48:33  TASK [ansible-role-docker : Docker | Deploy Config | Set the Docker configuration] ***
11:48:33  skipping: [vmu20-01] => (item={'key': 'api-cors-header', 'value': ''}) 
11:48:33  skipping: [vmu20-01] => (item={'key': 'authorization-plugins', 'value': ''}) 
11:48:33  skipping: [vmu20-01] => (item={'key': 'bip', 'value': ''}) 
11:48:33  skipping: [vmu20-01] => (item={'key': 'bridge', 'value': ''}) 
11:48:33  skipping: [vmu20-01] => (item={'key': 'cgroup-parent', 'value': ''}) 
11:48:33  skipping: [vmu20-01] => (item={'key': 'cluster-store', 'value': ''}) 
11:48:33  skipping: [vmu20-01] => (item={'key': 'cluster-store-opts', 'value': ''}) 
11:48:33  skipping: [vmu20-01] => (item={'key': 'cluster-advertise', 'value': ''}) 
11:48:33  skipping: [vmu20-01] => (item={'key': 'debug', 'value': ''}) 
11:48:33  skipping: [vmu20-01] => (item={'key': 'default-gateway', 'value': ''}) 
11:48:33  skipping: [vmu20-01] => (item={'key': 'default-gateway-v6', 'value': ''}) 
11:48:33  skipping: [vmu20-01] => (item={'key': 'default-runtime', 'value': ''}) 
11:48:33  skipping: [vmu20-01] => (item={'key': 'default-ulimits', 'value': ''}) 
11:48:33  skipping: [vmu20-01] => (item={'key': 'disable-legacy-registry', 'value': ''}) 
11:48:33  skipping: [vmu20-01] => (item={'key': 'dns', 'value': ''}) 
11:48:33  skipping: [vmu20-01] => (item={'key': 'dns-opts', 'value': ''}) 
11:48:33  skipping: [vmu20-01] => (item={'key': 'dns-search', 'value': ''}) 
11:48:33  skipping: [vmu20-01] => (item={'key': 'exec-opts', 'value': ''}) 
11:48:33  skipping: [vmu20-01] => (item={'key': 'exec-root', 'value': ''}) 
11:48:33  skipping: [vmu20-01] => (item={'key': 'fixed-cidr', 'value': ''}) 
11:48:33  skipping: [vmu20-01] => (item={'key': 'fixed-cidr-v6', 'value': ''}) 
11:48:33  skipping: [vmu20-01] => (item={'key': 'graph', 'value': ''}) 
11:48:33  skipping: [vmu20-01] => (item={'key': 'group', 'value': ''}) 
11:48:33  skipping: [vmu20-01] => (item={'key': 'hosts', 'value': ''}) 
11:48:33  skipping: [vmu20-01] => (item={'key': 'icc', 'value': ''}) 
11:48:33  skipping: [vmu20-01] => (item={'key': 'insecure-registries', 'value': ''}) 
11:48:33  skipping: [vmu20-01] => (item={'key': 'ip', 'value': ''}) 
11:48:33  skipping: [vmu20-01] => (item={'key': 'iptables', 'value': ''}) 
11:48:33  skipping: [vmu20-01] => (item={'key': 'ipv6', 'value': ''}) 
11:48:33  skipping: [vmu20-01] => (item={'key': 'ip-forward', 'value': ''}) 
11:48:33  skipping: [vmu20-01] => (item={'key': 'ip-masq', 'value': ''}) 
11:48:33  skipping: [vmu20-01] => (item={'key': 'labels', 'value': ''}) 
11:48:33  skipping: [vmu20-01] => (item={'key': 'live-restore', 'value': ''}) 
11:48:33  skipping: [vmu20-01] => (item={'key': 'log-driver', 'value': ''}) 
11:48:33  skipping: [vmu20-01] => (item={'key': 'log-level', 'value': ''}) 
11:48:33  skipping: [vmu20-01] => (item={'key': 'log-opts', 'value': ''}) 
11:48:33  skipping: [vmu20-01] => (item={'key': 'max-concurrent-downloads', 'value': ''}) 
11:48:34  skipping: [vmu20-01] => (item={'key': 'max-concurrent-uploads', 'value': ''}) 
11:48:34  skipping: [vmu20-01] => (item={'key': 'mtu', 'value': ''}) 
11:48:34  skipping: [vmu20-01] => (item={'key': 'oom-score-adjust', 'value': ''}) 
11:48:34  skipping: [vmu20-01] => (item={'key': 'pidfile', 'value': ''}) 
11:48:34  skipping: [vmu20-01] => (item={'key': 'raw-logs', 'value': ''}) 
11:48:34  skipping: [vmu20-01] => (item={'key': 'registry-mirrors', 'value': ''}) 
11:48:34  skipping: [vmu20-01] => (item={'key': 'runtimes', 'value': ''}) 
11:48:34  skipping: [vmu20-01] => (item={'key': 'selinux-enabled', 'value': ''}) 
11:48:34  skipping: [vmu20-01] => (item={'key': 'swarm-default-advertise-addr', 'value': ''}) 
11:48:34  skipping: [vmu20-01] => (item={'key': 'storage-driver', 'value': ''}) 
11:48:34  skipping: [vmu20-01] => (item={'key': 'storage-opts', 'value': ''}) 
11:48:34  skipping: [vmu20-01] => (item={'key': 'tls', 'value': ''}) 
11:48:34  skipping: [vmu20-01] => (item={'key': 'tlscacert', 'value': ''}) 
11:48:34  skipping: [vmu20-01] => (item={'key': 'tlscert', 'value': ''}) 
11:48:34  skipping: [vmu20-01] => (item={'key': 'tlskey', 'value': ''}) 
11:48:34  skipping: [vmu20-01] => (item={'key': 'tlsverify', 'value': ''}) 
11:48:34  skipping: [vmu20-01] => (item={'key': 'userland-proxy', 'value': ''}) 
11:48:34  skipping: [vmu20-01] => (item={'key': 'userns-remap', 'value': ''}) 
11:48:34  
11:48:34  TASK [ansible-role-docker : Docker | Deploy Config | Deploy /etc/docker/daemon.json] ***
11:48:34  skipping: [vmu20-01]
11:48:34  
11:48:34  TASK [ansible-role-docker : Docker | Proxy configuration] ***********************
11:48:34  skipping: [vmu20-01]
11:48:34  
11:48:34  TASK [ansible-role-docker : Docker | Add users to docker group] *****************
11:48:34  skipping: [vmu20-01]
11:48:34  
11:48:34  TASK [ansible-role-docker : Docker | Ensure service started] ********************
11:48:34  ok: [vmu20-01]
11:48:34  
11:48:34  TASK [Setup bootstrap-docker-config] *******************************************
11:48:35  
11:48:35  TASK [Allow docker ports through the firewall] *********************************
11:48:35  
11:48:35  TASK [firewall-config : Disable firewall] **************************************
11:48:35  skipping: [vmu20-01]
11:48:35  
11:48:35  TASK [firewall-config : Configure firewalld services] **************************
11:48:36  ok: [vmu20-01] => (item=internal - ssh)
11:48:36  ok: [vmu20-01] => (item=internal - ntp)
11:48:37  ok: [vmu20-01] => (item=internal - webmin)
11:48:37  
11:48:37  TASK [firewall-config : Allow ports through the firewall] **********************
11:48:38  changed: [vmu20-01] => (item=internal - 2375/tcp)
11:48:39  changed: [vmu20-01] => (item=internal - 2376/tcp)
11:48:39  
11:48:39  TASK [docker-config : Check for existing Docker Compose file] ******************
11:48:39  ok: [vmu20-01]
11:48:39  
11:48:39  TASK [docker-config : Install Python docker packages] **************************
11:48:41  ok: [vmu20-01] => (item={'name': 'docker', 'state': 'present', 'virtual_env_state': 'present'})
11:48:42  ok: [vmu20-01] => (item={'name': 'docker-compose', 'version': '', 'path': '/usr/local/bin/docker-compose', 'src': '/usr/local/lib/docker/virtualenv/bin/docker-compose', 'state': 'present', 'virtual_env_state': 'present'})
11:48:43  
11:48:43  TASK [docker-config : Install Python docker packages into docker-python virtualenv] ***
11:48:46  ok: [vmu20-01] => (item={'name': 'docker', 'state': 'present', 'virtual_env_state': 'present'})
11:48:49  ok: [vmu20-01] => (item={'name': 'docker-compose', 'version': '', 'path': '/usr/local/bin/docker-compose', 'src': '/usr/local/lib/docker/virtualenv/bin/docker-compose', 'state': 'present', 'virtual_env_state': 'present'})
11:48:49  
11:48:49  TASK [docker-config : Symlink Python binary to /usr/local/bin/python-docker] ***
11:48:49  ok: [vmu20-01]
11:48:50  
11:48:50  TASK [docker-config : Add user(s) to "docker" group] ***************************
11:48:50  ok: [vmu20-01] => (item=root)
11:48:50  
11:48:50  TASK [docker-config : Create Docker configuration directories] *****************
11:48:51  ok: [vmu20-01] => (item=/etc/docker)
11:48:51  ok: [vmu20-01] => (item=/etc/systemd/system/docker.service.d)
11:48:51  
11:48:51  TASK [docker-config : Docker | Deploy Config | Set the Docker configuration] ***
11:48:51  skipping: [vmu20-01] => (item={'key': 'api-cors-header', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'authorization-plugins', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'bip', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'bridge', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'cgroup-parent', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'cluster-store', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'cluster-store-opts', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'cluster-advertise', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'debug', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'default-gateway', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'default-gateway-v6', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'default-runtime', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'default-ulimits', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'disable-legacy-registry', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'dns', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'dns-opts', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'dns-search', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'exec-opts', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'exec-root', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'fixed-cidr', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'fixed-cidr-v6', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'graph', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'group', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'hosts', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'icc', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'insecure-registries', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'ip', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'iptables', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'ipv6', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'ip-forward', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'ip-masq', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'labels', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'live-restore', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'log-driver', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'log-level', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'log-opts', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'max-concurrent-downloads', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'max-concurrent-uploads', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'mtu', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'oom-score-adjust', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'pidfile', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'raw-logs', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'registry-mirrors', 'value': ''}) 
11:48:51  skipping: [vmu20-01] => (item={'key': 'runtimes', 'value': ''}) 
11:48:52  skipping: [vmu20-01] => (item={'key': 'selinux-enabled', 'value': ''}) 
11:48:52  skipping: [vmu20-01] => (item={'key': 'swarm-default-advertise-addr', 'value': ''}) 
11:48:52  skipping: [vmu20-01] => (item={'key': 'storage-driver', 'value': ''}) 
11:48:52  skipping: [vmu20-01] => (item={'key': 'storage-opts', 'value': ''}) 
11:48:52  skipping: [vmu20-01] => (item={'key': 'tls', 'value': ''}) 
11:48:52  skipping: [vmu20-01] => (item={'key': 'tlscacert', 'value': ''}) 
11:48:52  skipping: [vmu20-01] => (item={'key': 'tlscert', 'value': ''}) 
11:48:52  skipping: [vmu20-01] => (item={'key': 'tlskey', 'value': ''}) 
11:48:52  skipping: [vmu20-01] => (item={'key': 'tlsverify', 'value': ''}) 
11:48:52  skipping: [vmu20-01] => (item={'key': 'userland-proxy', 'value': ''}) 
11:48:52  skipping: [vmu20-01] => (item={'key': 'userns-remap', 'value': ''}) 
11:48:52  
11:48:52  TASK [docker-config : Docker | Deploy Config | Deploy /etc/docker/daemon.json] ***
11:48:52  skipping: [vmu20-01]
11:48:52  
11:48:52  TASK [docker-config : Display docker__daemon_flags] ****************************
11:48:52  ok: [vmu20-01] => 
11:48:52    docker__daemon_flags:
11:48:52    - -H unix://
11:48:52  
11:48:52  TASK [docker-config : Configure Docker daemon options (flags)] *****************
11:48:52  ok: [vmu20-01]
11:48:53  
11:48:53  TASK [docker-config : Configure Docker daemon environment variables] ***********
11:48:53  skipping: [vmu20-01]
11:48:53  
11:48:53  TASK [docker-config : Configure custom systemd unit file override] *************
11:48:53  skipping: [vmu20-01]
11:48:53  
11:48:53  TASK [docker-config : Reload systemd daemon] ***********************************
11:48:53  skipping: [vmu20-01]
11:48:53  
11:48:53  TASK [docker-config : Remove Docker related cron jobs] *************************
11:48:53  skipping: [vmu20-01] => (item={'name': 'Docker disk clean up', 'job': 'docker system prune -af > /dev/null 2>&1', 'schedule': ['0', '0', '*', '*', '0'], 'cron_file': 'docker-disk-clean-up', 'user': 'root'}) 
11:48:53  
11:48:53  TASK [docker-config : Create Docker related cron jobs] *************************
11:48:53  ok: [vmu20-01] => (item={'name': 'Docker disk clean up', 'job': 'docker system prune -af > /dev/null 2>&1', 'schedule': ['0', '0', '*', '*', '0'], 'cron_file': 'docker-disk-clean-up', 'user': 'root'})
11:48:53  
11:48:53  TASK [docker-config : create container-user group] *****************************
11:48:54  ok: [vmu20-01]
11:48:54  
11:48:54  TASK [docker-config : Create docker user] **************************************
11:48:54  ok: [vmu20-01]
11:48:54  
11:48:54  TASK [docker-config : debug] ***************************************************
11:48:54  skipping: [vmu20-01]
11:48:54  
11:48:54  TASK [docker-config : Set docker user info facts] ******************************
11:48:54  ok: [vmu20-01]
11:48:54  
11:48:54  TASK [docker-config : Enable sudo for docker user] *****************************
11:48:54  skipping: [vmu20-01]
11:48:54  
11:48:54  TASK [Setup network] ***********************************************************
11:48:55  
11:48:55  TASK [network : Add the OS specific varibles] **********************************
11:48:55  ok: [vmu20-01] => (item=/workspace/dettonville/infra/****-datacenter/dev/bootstrap-linux/roles/network/vars/Ubuntu.yml)
11:48:55  
11:48:55  TASK [network : Include specific tasks for the OS family] **********************
11:48:55  included: /workspace/dettonville/infra/****-datacenter/dev/bootstrap-linux/roles/network/tasks/setup-Debian.yml for vmu20-01
11:48:55  
11:48:55  TASK [network : Install the required packages in Debian derivatives] ***********
11:48:56  ok: [vmu20-01] => (item=python3-selinux)
11:48:58  ok: [vmu20-01] => (item=bridge-utils)
11:48:59  ok: [vmu20-01] => (item=ifenslave)
11:49:01  ok: [vmu20-01] => (item=iproute2)
11:49:01  
11:49:01  TASK [network : Make sure the include line is there in interfaces file] ********
11:49:01  ok: [vmu20-01]
11:49:01  
11:49:01  TASK [network : Create the directory for interface cfg files] ******************
11:49:01  ok: [vmu20-01]
11:49:01  
11:49:01  TASK [network : include_tasks] *************************************************
11:49:02  included: /workspace/dettonville/infra/****-datacenter/dev/bootstrap-linux/roles/network/tasks/restartscript.yml for vmu20-01
11:49:02  
11:49:02  TASK [network : Create a restart script] ***************************************
11:49:02  changed: [vmu20-01]
11:49:02  
11:49:02  TASK [network : Execute Network Restart] ***************************************
11:49:04  changed: [vmu20-01]
11:49:04  
11:49:04  TASK [network : Cleanup Network Restart script] ********************************
11:49:04  changed: [vmu20-01]
11:49:04  
11:49:04  TASK [Create the network configuration file for network interface devices] *****
11:49:04  
11:49:04  TASK [network : Print ifcfg_result info] ***************************************
11:49:04  ok: [vmu20-01] => 
11:49:04    ifcfg_result:
11:49:04      changed: false
11:49:04      results: []
11:49:04      skipped: true
11:49:04      skipped_reason: No items in the list
11:49:04  
11:49:04  TASK [Setup ****-role-stepca] ***********************************************
11:49:05  
11:49:05  TASK [****-role-stepca : include_vars] **************************************
11:49:05  ok: [vmu20-01] => (item=/workspace/dettonville/infra/****-datacenter/dev/bootstrap-linux/roles/****-role-stepca/vars/Ubuntu.yml)
11:49:05  
11:49:05  TASK [****-role-stepca : Setup step cli] ************************************
11:49:05  included: /workspace/dettonville/infra/****-datacenter/dev/bootstrap-linux/roles/****-role-stepca/tasks/setup-stepca-cli.yml for vmu20-01
11:49:05  
11:49:05  TASK [****-role-stepca : Create step source directory] **********************
11:49:05  ok: [vmu20-01]
11:49:05  
11:49:05  TASK [****-role-stepca : Download Step cli package] *************************
11:49:07  ok: [vmu20-01]
11:49:07  
11:49:07  TASK [****-role-stepca : Debian/Ubuntu | Install Step cli .deb package] *****
11:49:09  ok: [vmu20-01]
11:49:09  
11:49:09  TASK [****-role-stepca : Redhat | Uncompress step-cli binary] ***************
11:49:10  skipping: [vmu20-01]
11:49:10  
11:49:10  TASK [****-role-stepca : Redhat | Ensure step executable] *******************
11:49:10  skipping: [vmu20-01]
11:49:10  
11:49:10  TASK [****-role-stepca : RedHat | Create /usr/local/bin if necessary] *******
11:49:10  skipping: [vmu20-01]
11:49:10  
11:49:10  TASK [****-role-stepca : Redhat | Move step into place] *********************
11:49:10  skipping: [vmu20-01]
11:49:10  
11:49:10  TASK [****-role-stepca : Bootstap step cli configuration] *******************
11:49:10  ok: [vmu20-01]
11:49:10  
11:49:10  TASK [****-role-stepca : Setup systemd service file to server] **************
11:49:11  changed: [vmu20-01]
11:49:11  
11:49:11  TASK [****-role-stepca : Start stepca renewal service] **********************
11:49:12  ok: [vmu20-01]
11:49:12  
11:49:12  TASK [****-role-stepca : Setup step ca server] ******************************
11:49:12  skipping: [vmu20-01]
11:49:12  
11:49:12  TASK [Run deploy-cacerts] *****************************************************
11:49:12  
11:49:12  TASK [deploy-cacerts : include_vars] *******************************************
11:49:12  ok: [vmu20-01]
11:49:12  
11:49:12  TASK [deploy-cacerts : Get common CA cert facts] *******************************
11:49:12  included: /workspace/dettonville/infra/****-datacenter/dev/bootstrap-linux/roles/deploy-cacerts/tasks/get_cert_facts.yml for vmu20-01
11:49:12  
11:49:12  TASK [deploy-cacerts : get_cert_facts | Set ca_intermediate_certs fact] ********
11:49:13  ok: [vmu20-01] => (item={'commonName': 'ca.dettonville.int', 'domainName': 'dettonville.int', 'signerName': 'ca-root', 'country': 'US', 'state': 'New York', 'locality': 'NYC', 'organization': 'Dettonville Internal', 'organizationalUnit': 'Research & Technology', 'email': 'admin@dettonville.int'})
11:49:13  ok: [vmu20-01] => (item={'commonName': 'ca.johnson.int', 'domainName': 'johnson.int', 'signerName': 'ca-root', 'country': 'US', 'state': 'New York', 'locality': 'CSH', 'organization': 'Johnsonville Internal', 'organizationalUnit': 'Mostly Impractical', 'email': 'admin@johnson.int'})
11:49:13  ok: [vmu20-01] => (item={'commonName': 'ca.admin.dettonville.int', 'domainName': 'admin.dettonville.int', 'signerName': 'ca.dettonville.int'})
11:49:13  ok: [vmu20-01] => (item={'commonName': 'ca.media.johnson.int', 'domainName': 'media.johnson.int', 'signerName': 'ca.johnson.int'})
11:49:13  ok: [vmu20-01] => (item={'commonName': 'ca.admin01.johnson.int', 'domainName': 'admin01.johnson.int', 'signerName': 'ca.johnson.int'})
11:49:13  ok: [vmu20-01] => (item={'commonName': 'ca.admin02.johnson.int', 'domainName': 'admin02.johnson.int', 'signerName': 'ca.johnson.int'})
11:49:13  
11:49:13  TASK [deploy-cacerts : get_cert_facts | Set ca_signer_certs] *******************
11:49:13  ok: [vmu20-01]
11:49:13  
11:49:13  TASK [deploy-cacerts : get_cert_facts | Set ca_intermediate_certs_by_domain fact] ***
11:49:14  ok: [vmu20-01] => (item={'commonName': 'ca.dettonville.int', 'domainName': 'dettonville.int', 'signerName': 'ca-root', 'country': 'US', 'state': 'New York', 'locality': 'NYC', 'organization': 'Dettonville Internal', 'organizationalUnit': 'Research & Technology', 'email': 'admin@dettonville.int'})
11:49:14  ok: [vmu20-01] => (item={'commonName': 'ca.johnson.int', 'domainName': 'johnson.int', 'signerName': 'ca-root', 'country': 'US', 'state': 'New York', 'locality': 'CSH', 'organization': 'Johnsonville Internal', 'organizationalUnit': 'Mostly Impractical', 'email': 'admin@johnson.int'})
11:49:14  ok: [vmu20-01] => (item={'commonName': 'ca.admin.dettonville.int', 'domainName': 'admin.dettonville.int', 'signerName': 'ca.dettonville.int'})
11:49:14  ok: [vmu20-01] => (item={'commonName': 'ca.media.johnson.int', 'domainName': 'media.johnson.int', 'signerName': 'ca.johnson.int'})
11:49:14  ok: [vmu20-01] => (item={'commonName': 'ca.admin01.johnson.int', 'domainName': 'admin01.johnson.int', 'signerName': 'ca.johnson.int'})
11:49:14  ok: [vmu20-01] => (item={'commonName': 'ca.admin02.johnson.int', 'domainName': 'admin02.johnson.int', 'signerName': 'ca.johnson.int'})
11:49:14  
11:49:14  TASK [deploy-cacerts : get_cert_facts | Set ca_service_routes fact] ************
11:49:14  ok: [vmu20-01] => (item={'route': 'admin.dettonville.int', 'signerName': 'ca.admin.dettonville.int'})
11:49:14  ok: [vmu20-01] => (item={'route': 'media.johnson.int', 'signerName': 'ca.media.johnson.int'})
11:49:14  ok: [vmu20-01] => (item={'route': 'admin01.johnson.int', 'signerName': 'ca.admin01.johnson.int'})
11:49:14  ok: [vmu20-01] => (item={'route': 'admin02.johnson.int', 'signerName': 'ca.admin02.johnson.int'})
11:49:14  
11:49:14  TASK [deploy-cacerts : get_cert_facts | Set ca_fetch_domains_list] *************
11:49:14  ok: [vmu20-01]
11:49:14  
11:49:14  TASK [deploy-cacerts : distribute_cert | Display cert info] ********************
11:49:14  ok: [vmu20-01] => 
11:49:14    msg:
11:49:14    - keyring_cacerts_base_dir=/usr/share/ca-certs
11:49:14    - ca_domain=johnson.int
11:49:14    - ca_domains_hosted=[]
11:49:14    - 'ca_intermediate_cert_list=[{''commonName'': ''ca.dettonville.int'', ''domainName'': ''dettonville.int'', ''signerName'': ''ca-root'', ''country'': ''US'', ''state'': ''New York'', ''locality'': ''NYC'', ''organization'': ''Dettonville Internal'', ''organizationalUnit'': ''Research & Technology'', ''email'': ''admin@dettonville.int''}, {''commonName'': ''ca.johnson.int'', ''domainName'': ''johnson.int'', ''signerName'': ''ca-root'', ''country'': ''US'', ''state'': ''New York'', ''locality'': ''CSH'', ''organization'': ''Johnsonville Internal'', ''organizationalUnit'': ''Mostly Impractical'', ''email'': ''admin@johnson.int''}, {''commonName'': ''ca.admin.dettonville.int'', ''domainName'': ''admin.dettonville.int'', ''signerName'': ''ca.dettonville.int''}, {''commonName'': ''ca.media.johnson.int'', ''domainName'': ''media.johnson.int'', ''signerName'': ''ca.johnson.int''}, {''commonName'': ''ca.admin01.johnson.int'', ''domainName'': ''admin01.johnson.int'', ''signerName'': ''ca.johnson.int''},
11:49:14      {''commonName'': ''ca.admin02.johnson.int'', ''domainName'': ''admin02.johnson.int'', ''signerName'': ''ca.johnson.int''}]'
11:49:14    - 'ca_service_routes_list=[{''route'': ''admin.dettonville.int'', ''signerName'': ''ca.admin.dettonville.int''}, {''route'': ''media.johnson.int'', ''signerName'': ''ca.media.johnson.int''}, {''route'': ''admin01.johnson.int'', ''signerName'': ''ca.admin01.johnson.int''}, {''route'': ''admin02.johnson.int'', ''signerName'': ''ca.admin02.johnson.int''}]'
11:49:14    - ca_fetch_domains_list=['dettonville.int', 'johnson.int', 'admin.dettonville.int', 'media.johnson.int', 'admin01.johnson.int', 'admin02.johnson.int']
11:49:14  
11:49:14  TASK [deploy-cacerts : Fetch certs from keyring] *******************************
11:49:15  included: /workspace/dettonville/infra/****-datacenter/dev/bootstrap-linux/roles/deploy-cacerts/tasks/fetch_certs.yml for vmu20-01
11:49:15  
11:49:15  TASK [deploy-cacerts : fetch_certs | Remove all existing old CA certs and keys] ***
11:49:15  skipping: [vmu20-01] => (item=/usr/local/ssl/certs) 
11:49:15  skipping: [vmu20-01] => (item=/usr/local/ssl/private) 
11:49:15  skipping: [vmu20-01] => (item=/etc/ssl/private) 
11:49:15  
11:49:15  TASK [deploy-cacerts : fetch_certs | Ensure local cert dirs exist] *************
11:49:15  ok: [vmu20-01] => (item=/usr/local/ssl/certs)
11:49:16  ok: [vmu20-01] => (item=/usr/local/ssl/private)
11:49:16  ok: [vmu20-01] => (item=/etc/ssl/private)
11:49:16  
11:49:16  TASK [deploy-cacerts : fetch_certs | Fetch root ca-cert to /usr/local/ssl/certs] ***
11:49:16  skipping: [vmu20-01] => (item={'src': '/usr/share/ca-certs/ca-root/ca-root.pem', 'dest': '/usr/local/ssl/certs/ca-root.pem'}) 
11:49:16  
11:49:16  TASK [deploy-cacerts : fetch_certs | Fetch certs to /usr/local/ssl/certs] ******
11:49:16  skipping: [vmu20-01] => (item={'src': '/usr/share/ca-certs/johnson.int/vmu20-01.johnson.int.pem', 'dest': '/usr/local/ssl/certs/vmu20-01.johnson.int.pem'}) 
11:49:16  skipping: [vmu20-01] => (item={'src': '/usr/share/ca-certs/johnson.int/vmu20-01.johnson.int.chain.pem', 'dest': '/usr/local/ssl/certs/vmu20-01.johnson.int.chain.pem'}) 
11:49:16  
11:49:16  TASK [deploy-cacerts : fetch_certs | Synchronize cert key to /usr/local/ssl/private] ***
11:49:16  skipping: [vmu20-01] => (item={'src': '/usr/share/ca-certs/johnson.int/vmu20-01.johnson.int-key.pem', 'dest': '/usr/local/ssl/private/vmu20-01.johnson.int-key.pem'}) 
11:49:16  skipping: [vmu20-01] => (item={'src': '/usr/share/ca-certs/johnson.int/vmu20-01.johnson.int-key.pem', 'dest': '/etc/ssl/private/vmu20-01.johnson.int-key.pem'}) 
11:49:16  
11:49:16  TASK [deploy-cacerts : check if vmu20-01.johnson.int.pem exists] ***************
11:49:17  ok: [vmu20-01]
11:49:17  
11:49:17  TASK [deploy-cacerts : check if vmu20-01.johnson.int.pem exists] ***************
11:49:17  ok: [vmu20-01]
11:49:17  
11:49:17  TASK [deploy-cacerts : check if vmu20-01.johnson.int.pem exists] ***************
11:49:18  ok: [vmu20-01]
11:49:18  
11:49:18  TASK [deploy-cacerts : check if vmu20-01.johnson.int-key.pem exists] ***********
11:49:18  ok: [vmu20-01]
11:49:18  
11:49:18  TASK [deploy-cacerts : fetch_certs | Bootstap step cli configuration] **********
11:49:19  ok: [vmu20-01]
11:49:19  
11:49:19  TASK [deploy-cacerts : fetch_certs | Fetch root cert/key from stepca to /usr/local/ssl/certs] ***
11:49:19  skipping: [vmu20-01]
11:49:19  
11:49:19  TASK [deploy-cacerts : fetch_certs | Deploy cert/key to /usr/local/ssl/certs] ***
11:49:19  skipping: [vmu20-01]
11:49:19  
11:49:19  TASK [deploy-cacerts : fetch_certs | Create cert bundle from stepca to /usr/local/ssl/certs] ***
11:49:19  skipping: [vmu20-01]
11:49:19  
11:49:19  TASK [deploy-cacerts : fetch_certs | Setup stepca cert renewal service] ********
11:49:19  included: /workspace/dettonville/infra/****-datacenter/dev/bootstrap-linux/roles/deploy-cacerts/tasks/stepca_renewal_service.yml for vmu20-01
11:49:19  
11:49:19  TASK [deploy-cacerts : Stepca | Bootstap step cli configuration] ***************
11:49:20  ok: [vmu20-01]
11:49:20  
11:49:20  TASK [deploy-cacerts : Stepca | Setup systemd service file to server] **********
11:49:21  changed: [vmu20-01]
11:49:21  
11:49:21  TASK [deploy-cacerts : Stepca | Start stepca renewal service] ******************
11:49:21  ok: [vmu20-01]
11:49:21  
11:49:21  TASK [deploy-cacerts : fetch_certs | Synchronize ca intermediate certs to /usr/local/ssl/certs] ***
11:49:23  changed: [vmu20-01] => (item={'commonName': 'ca.dettonville.int', 'domainName': 'dettonville.int', 'signerName': 'ca-root', 'country': 'US', 'state': 'New York', 'locality': 'NYC', 'organization': 'Dettonville Internal', 'organizationalUnit': 'Research & Technology', 'email': 'admin@dettonville.int'})
11:49:23  changed: [vmu20-01] => (item={'commonName': 'ca.johnson.int', 'domainName': 'johnson.int', 'signerName': 'ca-root', 'country': 'US', 'state': 'New York', 'locality': 'CSH', 'organization': 'Johnsonville Internal', 'organizationalUnit': 'Mostly Impractical', 'email': 'admin@johnson.int'})
11:49:24  changed: [vmu20-01] => (item={'commonName': 'ca.admin.dettonville.int', 'domainName': 'admin.dettonville.int', 'signerName': 'ca.dettonville.int'})
11:49:24  changed: [vmu20-01] => (item={'commonName': 'ca.media.johnson.int', 'domainName': 'media.johnson.int', 'signerName': 'ca.johnson.int'})
11:49:25  changed: [vmu20-01] => (item={'commonName': 'ca.admin01.johnson.int', 'domainName': 'admin01.johnson.int', 'signerName': 'ca.johnson.int'})
11:49:26  changed: [vmu20-01] => (item={'commonName': 'ca.admin02.johnson.int', 'domainName': 'admin02.johnson.int', 'signerName': 'ca.johnson.int'})
11:49:26  
11:49:26  TASK [deploy-cacerts : fetch_certs | Synchronize ca intermediate cert keys to /usr/local/ssl/private] ***
11:49:27  changed: [vmu20-01] => (item={'commonName': 'ca.dettonville.int', 'domainName': 'dettonville.int', 'signerName': 'ca-root', 'country': 'US', 'state': 'New York', 'locality': 'NYC', 'organization': 'Dettonville Internal', 'organizationalUnit': 'Research & Technology', 'email': 'admin@dettonville.int'})
11:49:27  changed: [vmu20-01] => (item={'commonName': 'ca.johnson.int', 'domainName': 'johnson.int', 'signerName': 'ca-root', 'country': 'US', 'state': 'New York', 'locality': 'CSH', 'organization': 'Johnsonville Internal', 'organizationalUnit': 'Mostly Impractical', 'email': 'admin@johnson.int'})
11:49:28  changed: [vmu20-01] => (item={'commonName': 'ca.admin.dettonville.int', 'domainName': 'admin.dettonville.int', 'signerName': 'ca.dettonville.int'})
11:49:28  changed: [vmu20-01] => (item={'commonName': 'ca.media.johnson.int', 'domainName': 'media.johnson.int', 'signerName': 'ca.johnson.int'})
11:49:29  changed: [vmu20-01] => (item={'commonName': 'ca.admin01.johnson.int', 'domainName': 'admin01.johnson.int', 'signerName': 'ca.johnson.int'})
11:49:30  changed: [vmu20-01] => (item={'commonName': 'ca.admin02.johnson.int', 'domainName': 'admin02.johnson.int', 'signerName': 'ca.johnson.int'})
11:49:30  
11:49:30  TASK [deploy-cacerts : fetch_certs | Synchronize service route certs to /usr/local/ssl/certs] ***
11:49:31  changed: [vmu20-01] => (item={'route': 'admin.dettonville.int', 'signerName': 'ca.admin.dettonville.int'})
11:49:31  changed: [vmu20-01] => (item={'route': 'media.johnson.int', 'signerName': 'ca.media.johnson.int'})
11:49:32  changed: [vmu20-01] => (item={'route': 'admin01.johnson.int', 'signerName': 'ca.admin01.johnson.int'})
11:49:32  changed: [vmu20-01] => (item={'route': 'admin02.johnson.int', 'signerName': 'ca.admin02.johnson.int'})
11:49:33  
11:49:33  TASK [deploy-cacerts : fetch_certs | Synchronize service route cert chains to /usr/local/ssl/certs] ***
11:49:33  changed: [vmu20-01] => (item={'route': 'admin.dettonville.int', 'signerName': 'ca.admin.dettonville.int'})
11:49:34  changed: [vmu20-01] => (item={'route': 'media.johnson.int', 'signerName': 'ca.media.johnson.int'})
11:49:35  changed: [vmu20-01] => (item={'route': 'admin01.johnson.int', 'signerName': 'ca.admin01.johnson.int'})
11:49:35  changed: [vmu20-01] => (item={'route': 'admin02.johnson.int', 'signerName': 'ca.admin02.johnson.int'})
11:49:35  
11:49:35  TASK [deploy-cacerts : fetch_certs | Synchronize service route keys to /usr/local/ssl/private] ***
11:49:35  skipping: [vmu20-01] => (item={'route': 'admin.dettonville.int', 'signerName': 'ca.admin.dettonville.int'}) 
11:49:35  skipping: [vmu20-01] => (item={'route': 'media.johnson.int', 'signerName': 'ca.media.johnson.int'}) 
11:49:35  skipping: [vmu20-01] => (item={'route': 'admin01.johnson.int', 'signerName': 'ca.admin01.johnson.int'}) 
11:49:35  skipping: [vmu20-01] => (item={'route': 'admin02.johnson.int', 'signerName': 'ca.admin02.johnson.int'}) 
11:49:35  
11:49:35  TASK [deploy-cacerts : fetch_certs | Synchronize service route keys to trust dir at /etc/ssl/private] ***
11:49:36  skipping: [vmu20-01] => (item={'route': 'admin.dettonville.int', 'signerName': 'ca.admin.dettonville.int'}) 
11:49:36  skipping: [vmu20-01] => (item={'route': 'media.johnson.int', 'signerName': 'ca.media.johnson.int'}) 
11:49:36  skipping: [vmu20-01] => (item={'route': 'admin01.johnson.int', 'signerName': 'ca.admin01.johnson.int'}) 
11:49:36  skipping: [vmu20-01] => (item={'route': 'admin02.johnson.int', 'signerName': 'ca.admin02.johnson.int'}) 
11:49:36  
11:49:36  TASK [deploy-cacerts : Trust certs on node] ************************************
11:49:36  included: /workspace/dettonville/infra/****-datacenter/dev/bootstrap-linux/roles/deploy-cacerts/tasks/trust_cert.yml for vmu20-01
11:49:36  
11:49:36  TASK [deploy-cacerts : trust_cert | ensure trust dir exists for /usr/local/share/ca-certificates] ***
11:49:36  ok: [vmu20-01]
11:49:36  
11:49:36  TASK [deploy-cacerts : trust_cert | Remove all existing old CA certs from /usr/local/share/ca-certificates] ***
11:49:36  skipping: [vmu20-01]
11:49:36  
11:49:36  TASK [deploy-cacerts : trust_cert | Copy root cert to /usr/local/share/ca-certificates for importing] ***
11:49:37  ok: [vmu20-01] => (item={'src': '/usr/local/ssl/certs/ca-root.pem', 'dest': '/usr/local/share/ca-certificates/ca-root.crt'})
11:49:37  
11:49:37  TASK [deploy-cacerts : trust_cert | Copy client to /usr/local/share/ca-certificates for importing] ***
11:49:38  ok: [vmu20-01] => (item={'src': '/usr/local/ssl/certs/vmu20-01.johnson.int.chain.pem', 'dest': '/usr/local/share/ca-certificates/vmu20-01.johnson.int.crt'})
11:49:38  
11:49:38  TASK [deploy-cacerts : trust_cert | Copy intermediate certs to /usr/local/share/ca-certificates for importing] ***
11:49:38  ok: [vmu20-01] => (item=ca.dettonville.int)
11:49:38  ok: [vmu20-01] => (item=ca.johnson.int)
11:49:39  ok: [vmu20-01] => (item=ca.admin.dettonville.int)
11:49:39  ok: [vmu20-01] => (item=ca.media.johnson.int)
11:49:40  ok: [vmu20-01] => (item=ca.admin01.johnson.int)
11:49:40  ok: [vmu20-01] => (item=ca.admin02.johnson.int)
11:49:40  
11:49:40  TASK [deploy-cacerts : trust_cert | Copy service route certs to /usr/local/share/ca-certificates for importing] ***
11:49:41  ok: [vmu20-01] => (item={'route': 'admin.dettonville.int', 'signerName': 'ca.admin.dettonville.int'})
11:49:41  ok: [vmu20-01] => (item={'route': 'media.johnson.int', 'signerName': 'ca.media.johnson.int'})
11:49:42  ok: [vmu20-01] => (item={'route': 'admin01.johnson.int', 'signerName': 'ca.admin01.johnson.int'})
11:49:42  ok: [vmu20-01] => (item={'route': 'admin02.johnson.int', 'signerName': 'ca.admin02.johnson.int'})
11:49:42  
11:49:42  TASK [deploy-cacerts : trust_cert | update CA trust: update-ca-certificates] ***
11:49:47  changed: [vmu20-01]
11:49:47  
11:49:47  TASK [deploy-cacerts : trust_cert | Add service cert to keystore] **************
11:49:48  changed: [vmu20-01] => (item={'route': 'admin.dettonville.int', 'signerName': 'ca.admin.dettonville.int'})
11:49:49  changed: [vmu20-01] => (item={'route': 'media.johnson.int', 'signerName': 'ca.media.johnson.int'})
11:49:50  changed: [vmu20-01] => (item={'route': 'admin01.johnson.int', 'signerName': 'ca.admin01.johnson.int'})
11:49:51  changed: [vmu20-01] => (item={'route': 'admin02.johnson.int', 'signerName': 'ca.admin02.johnson.int'})
11:49:51  
11:49:51  TASK [Setup ****-os-hardening] **********************************************
11:49:51  
11:49:51  TASK [****-os-hardening : Set OS dependent variables] ***********************
11:49:51  ok: [vmu20-01] => (item=/workspace/dettonville/infra/****-datacenter/dev/bootstrap-linux/roles/****-os-hardening/vars/Ubuntu.yml)
11:49:51  
11:49:51  TASK [****-os-hardening : Set OS dependent variables, if not already defined by user] ***
11:49:51  skipping: [vmu20-01] => (item={'key': 'ntp_package', 'value': 'ntp'}) 
11:49:52  ok: [vmu20-01] => (item={'key': 'ntp_service', 'value': 'ntp'})
11:49:52  ok: [vmu20-01] => (item={'key': 'ssh_service', 'value': 'ssh'})
11:49:52  ok: [vmu20-01] => (item={'key': 'grubcfg_location', 'value': '/boot/grub/grub.cfg'})
11:49:52  ok: [vmu20-01] => (item={'key': 'cracklib_package', 'value': 'libpam-cracklib'})
11:49:52  ok: [vmu20-01] => (item={'key': 'pam_password_file', 'value': '/etc/pam.d/common-password'})
11:49:52  ok: [vmu20-01] => (item={'key': 'os_packages_pam_ccreds', 'value': 'libpam-ccreds'})
11:49:52  ok: [vmu20-01] => (item={'key': 'os_packages_pam_passwdqc', 'value': 'libpam-passwdqc'})
11:49:52  ok: [vmu20-01] => (item={'key': 'os_packages_pam_cracklib', 'value': 'libpam-cracklib'})
11:49:52  ok: [vmu20-01] => (item={'key': 'os_nologin_shell_path', 'value': '/usr/sbin/nologin'})
11:49:52  ok: [vmu20-01] => (item={'key': 'os_shadow_perms', 'value': {'owner': 'root', 'group': 'shadow', 'mode': '0640'}})
11:49:52  ok: [vmu20-01] => (item={'key': 'os_passwd_perms', 'value': {'owner': 'root', 'group': 'root', 'mode': '0644'}})
11:49:52  ok: [vmu20-01] => (item={'key': 'harden_linux_os_env_umask', 'value': '027'})
11:49:52  ok: [vmu20-01] => (item={'key': 'os_auth_uid_min', 'value': 1000})
11:49:52  ok: [vmu20-01] => (item={'key': 'os_auth_gid_min', 'value': 1000})
11:49:52  ok: [vmu20-01] => (item={'key': 'os_auth_sys_uid_min', 'value': 100})
11:49:52  ok: [vmu20-01] => (item={'key': 'os_auth_sys_uid_max', 'value': 999})
11:49:52  ok: [vmu20-01] => (item={'key': 'os_auth_sys_gid_min', 'value': 100})
11:49:52  ok: [vmu20-01] => (item={'key': 'os_auth_sys_gid_max', 'value': 999})
11:49:52  ok: [vmu20-01] => (item={'key': 'os_useradd_mail_dir', 'value': '/var/mail'})
11:49:52  ok: [vmu20-01] => (item={'key': 'modprobe_package', 'value': 'kmod'})
11:49:52  ok: [vmu20-01] => (item={'key': 'auditd_package', 'value': 'auditd'})
11:49:52  ok: [vmu20-01] => (item={'key': 'tally2_path', 'value': '/usr/share/pam-configs/tally2'})
11:49:52  ok: [vmu20-01] => (item={'key': 'passwdqc_path', 'value': '/usr/share/pam-configs/passwdqc'})
11:49:52  
11:49:52  TASK [****-os-hardening : install auditd package | package-08] **************
11:49:54  ok: [vmu20-01]
11:49:54  
11:49:54  TASK [****-os-hardening : configure auditd | package-08] ********************
11:49:55  ok: [vmu20-01]
11:49:55  
11:49:55  TASK [****-os-hardening : create limits.d-directory if it does not exist | sysctl-31a, sysctl-31b] ***
11:49:55  ok: [vmu20-01]
11:49:55  
11:49:55  TASK [****-os-hardening : create additional limits config file -> 10.hardcore.conf | sysctl-31a, sysctl-31b] ***
11:49:56  ok: [vmu20-01]
11:49:56  
11:49:56  TASK [****-os-hardening : set 10.hardcore.conf perms to 0400 and root ownership] ***
11:49:56  ok: [vmu20-01]
11:49:56  
11:49:56  TASK [****-os-hardening : remove 10.hardcore.conf config file] **************
11:49:56  skipping: [vmu20-01]
11:49:56  
11:49:56  TASK [****-os-hardening : create login.defs | os-05, os-05b] ****************
11:49:57  ok: [vmu20-01]
11:49:57  
11:49:57  TASK [****-os-hardening : find files with write-permissions for group] ******
11:49:57  skipping: [vmu20-01] => (item=/usr/local/sbin) 
11:49:57  skipping: [vmu20-01] => (item=/usr/local/bin) 
11:49:57  skipping: [vmu20-01] => (item=/usr/sbin) 
11:49:57  skipping: [vmu20-01] => (item=/usr/bin) 
11:49:57  skipping: [vmu20-01] => (item=/sbin) 
11:49:57  skipping: [vmu20-01] => (item=/bin) 
11:49:57  
11:49:57  TASK [****-os-hardening : minimize access on found files] *******************
11:49:57  
11:49:57  TASK [****-os-hardening : change shadow ownership to root and mode to 0600 | os-02] ***
11:49:57  skipping: [vmu20-01]
11:49:57  
11:49:57  TASK [****-os-hardening : change passwd ownership to root and mode to 0644 | os-03] ***
11:49:57  skipping: [vmu20-01]
11:49:57  
11:49:57  TASK [****-os-hardening : change su-binary to only be accessible to user and group root] ***
11:49:57  skipping: [vmu20-01]
11:49:57  
11:49:57  TASK [****-os-hardening : set option hidepid for proc filesystem] ***********
11:49:58  skipping: [vmu20-01]
11:49:58  
11:49:58  TASK [****-os-hardening : install modprobe to disable filesystems | os-10] ***
11:49:58  skipping: [vmu20-01]
11:49:58  
11:49:58  TASK [****-os-hardening : check if efi is installed] ************************
11:49:58  skipping: [vmu20-01]
11:49:58  
11:49:58  TASK [****-os-hardening : remove vfat from fs-list if efi is used] **********
11:49:58  skipping: [vmu20-01]
11:49:58  
11:49:58  TASK [****-os-hardening : remove used filesystems from fs-list] *************
11:49:58  skipping: [vmu20-01]
11:49:58  
11:49:58  TASK [****-os-hardening : disable unused filesystems | os-10] ***************
11:49:58  skipping: [vmu20-01]
11:49:58  
11:49:58  TASK [****-os-hardening : add pinerolo_profile.sh to profile.d] *************
11:49:59  ok: [vmu20-01]
11:49:59  
11:49:59  TASK [****-os-hardening : remove pinerolo_profile.sh from profile.d] ********
11:49:59  skipping: [vmu20-01]
11:49:59  
11:49:59  TASK [****-os-hardening : create securetty] *********************************
11:49:59  ok: [vmu20-01]
11:49:59  
11:49:59  TASK [****-os-hardening : remove suid/sgid bit from binaries in blacklist | os-06] ***
11:50:00  ok: [vmu20-01] => (item=/usr/bin/rcp)
11:50:00  ok: [vmu20-01] => (item=/usr/bin/rlogin)
11:50:01  ok: [vmu20-01] => (item=/usr/bin/rsh)
11:50:01  ok: [vmu20-01] => (item=/usr/libexec/openssh/ssh-keysign)
11:50:02  ok: [vmu20-01] => (item=/usr/lib/openssh/ssh-keysign)
11:50:02  ok: [vmu20-01] => (item=/sbin/netreport)
11:50:02  ok: [vmu20-01] => (item=/usr/sbin/usernetctl)
11:50:03  ok: [vmu20-01] => (item=/usr/sbin/userisdnctl)
11:50:03  ok: [vmu20-01] => (item=/usr/sbin/pppd)
11:50:04  ok: [vmu20-01] => (item=/usr/bin/lockfile)
11:50:04  ok: [vmu20-01] => (item=/usr/bin/mail-lock)
11:50:04  ok: [vmu20-01] => (item=/usr/bin/mail-unlock)
11:50:05  ok: [vmu20-01] => (item=/usr/bin/mail-touchlock)
11:50:05  ok: [vmu20-01] => (item=/usr/bin/dotlockfile)
11:50:06  ok: [vmu20-01] => (item=/usr/bin/arping)
11:50:06  ok: [vmu20-01] => (item=/usr/sbin/uuidd)
11:50:06  ok: [vmu20-01] => (item=/usr/bin/mtr)
11:50:07  ok: [vmu20-01] => (item=/usr/lib/evolution/camel-lock-helper-1.2)
11:50:07  ok: [vmu20-01] => (item=/usr/lib/pt_chown)
11:50:08  ok: [vmu20-01] => (item=/usr/lib/eject/dmcrypt-get-device)
11:50:08  ok: [vmu20-01] => (item=/usr/lib/mc/cons.saver)
11:50:08  
11:50:08  TASK [****-os-hardening : find binaries with suid/sgid set | os-06] *********
11:50:42  ok: [vmu20-01]
11:50:42  
11:50:42  TASK [****-os-hardening : gather files from which to remove suids/sgids and remove system white-listed files | os-06] ***
11:50:42  ok: [vmu20-01]
11:50:42  
11:50:42  TASK [****-os-hardening : remove suid/sgid bit from all binaries except in system and user whitelist | os-06] ***
11:50:43  
11:50:43  TASK [****-os-hardening : get UID_MIN from login.defs] **********************
11:50:43  skipping: [vmu20-01]
11:50:43  
11:50:43  TASK [****-os-hardening : calculate UID_MAX from UID_MIN by substracting 1] ***
11:50:43  skipping: [vmu20-01]
11:50:43  
11:50:43  TASK [****-os-hardening : set UID_MAX on Debian-systems if no login.defs exist] ***
11:50:43  skipping: [vmu20-01]
11:50:43  
11:50:43  TASK [****-os-hardening : set UID_MAX on other systems if no login.defs exist] ***
11:50:43  skipping: [vmu20-01]
11:50:43  
11:50:43  TASK [****-os-hardening : get all system accounts] **************************
11:50:43  skipping: [vmu20-01]
11:50:43  
11:50:43  TASK [****-os-hardening : remove always ignored system accounts from list] ***
11:50:43  skipping: [vmu20-01]
11:50:43  
11:50:43  TASK [****-os-hardening : change system accounts not on the user provided ignore-list] ***
11:50:43  
11:50:43  TASK [****-os-hardening : Get user accounts | os-09] ************************
11:50:44  ok: [vmu20-01]
11:50:44  
11:50:44  TASK [****-os-hardening : delete rhosts-files from system | os-09] **********
11:50:44  ok: [vmu20-01] => (item=root)
11:50:45  ok: [vmu20-01] => (item=daemon)
11:50:45  ok: [vmu20-01] => (item=bin)
11:50:45  ok: [vmu20-01] => (item=sys)
11:50:46  ok: [vmu20-01] => (item=sync)
11:50:46  ok: [vmu20-01] => (item=games)
11:50:46  ok: [vmu20-01] => (item=man)
11:50:47  ok: [vmu20-01] => (item=lp)
11:50:47  ok: [vmu20-01] => (item=mail)
11:50:48  ok: [vmu20-01] => (item=news)
11:50:48  ok: [vmu20-01] => (item=uucp)
11:50:48  ok: [vmu20-01] => (item=proxy)
11:50:49  ok: [vmu20-01] => (item=www-data)
11:50:49  ok: [vmu20-01] => (item=backup)
11:50:50  ok: [vmu20-01] => (item=list)
11:50:50  ok: [vmu20-01] => (item=irc)
11:50:50  ok: [vmu20-01] => (item=gnats)
11:50:51  ok: [vmu20-01] => (item=nobody)
11:50:51  ok: [vmu20-01] => (item=systemd-network)
11:50:51  ok: [vmu20-01] => (item=systemd-resolve)
11:50:52  ok: [vmu20-01] => (item=systemd-timesync)
11:50:52  ok: [vmu20-01] => (item=messagebus)
11:50:53  ok: [vmu20-01] => (item=syslog)
11:50:53  ok: [vmu20-01] => (item=_apt)
11:50:53  ok: [vmu20-01] => (item=tss)
11:50:54  ok: [vmu20-01] => (item=uuidd)
11:50:54  ok: [vmu20-01] => (item=tcpdump)
11:50:55  ok: [vmu20-01] => (item=landscape)
11:50:55  ok: [vmu20-01] => (item=pollinate)
11:50:55  ok: [vmu20-01] => (item=usbmux)
11:50:56  ok: [vmu20-01] => (item=sshd)
11:50:56  ok: [vmu20-01] => (item=systemd-coredump)
11:50:57  ok: [vmu20-01] => (item=packer)
11:50:57  ok: [vmu20-01] => (item=lxd)
11:50:57  ok: [vmu20-01] => (item=ntp)
11:50:58  ok: [vmu20-01] => (item=postfix)
11:50:58  ok: [vmu20-01] => (item=_rpc)
11:50:59  ok: [vmu20-01] => (item=statd)
11:50:59  ok: [vmu20-01] => (item=administrator)
11:50:59  ok: [vmu20-01] => (item=****)
11:51:00  ok: [vmu20-01] => (item=container-user)
11:51:00  ok: [vmu20-01] => (item=nslcd)
11:51:00  
11:51:00  TASK [****-os-hardening : delete hosts.equiv from system | os-01] ***********
11:51:01  ok: [vmu20-01]
11:51:01  
11:51:01  TASK [****-os-hardening : delete .netrc-files from system | os-09] **********
11:51:01  ok: [vmu20-01] => (item=root)
11:51:02  ok: [vmu20-01] => (item=daemon)
11:51:02  ok: [vmu20-01] => (item=bin)
11:51:02  ok: [vmu20-01] => (item=sys)
11:51:03  ok: [vmu20-01] => (item=sync)
11:51:03  ok: [vmu20-01] => (item=games)
11:51:04  ok: [vmu20-01] => (item=man)
11:51:04  ok: [vmu20-01] => (item=lp)
11:51:05  ok: [vmu20-01] => (item=mail)
11:51:05  ok: [vmu20-01] => (item=news)
11:51:05  ok: [vmu20-01] => (item=uucp)
11:51:06  ok: [vmu20-01] => (item=proxy)
11:51:06  ok: [vmu20-01] => (item=www-data)
11:51:07  ok: [vmu20-01] => (item=backup)
11:51:07  ok: [vmu20-01] => (item=list)
11:51:07  ok: [vmu20-01] => (item=irc)
11:51:08  ok: [vmu20-01] => (item=gnats)
11:51:08  ok: [vmu20-01] => (item=nobody)
11:51:09  ok: [vmu20-01] => (item=systemd-network)
11:51:09  ok: [vmu20-01] => (item=systemd-resolve)
11:51:09  ok: [vmu20-01] => (item=systemd-timesync)
11:51:10  ok: [vmu20-01] => (item=messagebus)
11:51:10  ok: [vmu20-01] => (item=syslog)
11:51:11  ok: [vmu20-01] => (item=_apt)
11:51:11  ok: [vmu20-01] => (item=tss)
11:51:11  ok: [vmu20-01] => (item=uuidd)
11:51:12  ok: [vmu20-01] => (item=tcpdump)
11:51:12  ok: [vmu20-01] => (item=landscape)
11:51:12  ok: [vmu20-01] => (item=pollinate)
11:51:13  ok: [vmu20-01] => (item=usbmux)
11:51:13  ok: [vmu20-01] => (item=sshd)
11:51:14  ok: [vmu20-01] => (item=systemd-coredump)
11:51:14  ok: [vmu20-01] => (item=packer)
11:51:14  ok: [vmu20-01] => (item=lxd)
11:51:15  ok: [vmu20-01] => (item=ntp)
11:51:15  ok: [vmu20-01] => (item=postfix)
11:51:16  ok: [vmu20-01] => (item=_rpc)
11:51:16  ok: [vmu20-01] => (item=statd)
11:51:17  ok: [vmu20-01] => (item=administrator)
11:51:17  ok: [vmu20-01] => (item=****)
11:51:17  ok: [vmu20-01] => (item=container-user)
11:51:18  ok: [vmu20-01] => (item=nslcd)
11:51:18  
11:51:18  TASK [****-os-hardening : remove unused repositories] ***********************
11:51:18  skipping: [vmu20-01] => (item=CentOS-Debuginfo) 
11:51:18  skipping: [vmu20-01] => (item=CentOS-Media) 
11:51:18  skipping: [vmu20-01] => (item=CentOS-Vault) 
11:51:18  
11:51:18  TASK [****-os-hardening : get yum-repository-files] *************************
11:51:18  skipping: [vmu20-01]
11:51:18  
11:51:18  TASK [****-os-hardening : activate gpg-check for config files] **************
11:51:18  skipping: [vmu20-01] => (item=/etc/yum.conf) 
11:51:18  skipping: [vmu20-01] => (item=/etc/dnf/dnf.conf) 
11:51:18  skipping: [vmu20-01] => (item=/etc/yum/pluginconf.d/rhnplugin.conf) 
11:51:18  
11:51:18  TASK [****-os-hardening : remove deprecated or insecure packages | package-01 - package-09] ***
11:51:18  skipping: [vmu20-01]
11:51:18  
11:51:18  TASK [****-os-hardening : remove deprecated or insecure packages | package-01 - package-09] ***
11:51:20  ok: [vmu20-01]
11:51:21  
11:51:21  TASK [****-os-hardening : configure selinux | selinux-01] *******************
11:51:21  skipping: [vmu20-01]
11:51:21  
11:51:21  TASK [****-os-hardening : Gather EC2 Facts] *********************************
11:51:21  skipping: [vmu20-01]
11:51:21  
11:51:21  TASK [****-os-hardening : Get resource tags from EC2 Facts] *****************
11:51:21  skipping: [vmu20-01]
11:51:21  
11:51:21  TASK [****-os-hardening : debug] ********************************************
11:51:21  skipping: [vmu20-01]
11:51:21  
11:51:21  TASK [****-os-hardening : Set the Hostname to the Name tag] *****************
11:51:21  skipping: [vmu20-01]
11:51:21  
11:51:21  TASK [****-os-hardening : Set Permissions on bootloader config] *************
11:51:21  skipping: [vmu20-01]
11:51:21  
11:51:21  TASK [****-os-hardening : Set Boot Loader Password] *************************
11:51:21  skipping: [vmu20-01]
11:51:21  
11:51:21  TASK [****-os-hardening : Set Permissions on /etc/ssh/sshd_config] **********
11:51:21  skipping: [vmu20-01]
11:51:21  
11:51:21  TASK [****-os-hardening : Disable X11 Forwarding] ***************************
11:51:21  skipping: [vmu20-01]
11:51:21  
11:51:21  TASK [****-os-hardening : Set SSH MaxAuthTries to 4 or less] ****************
11:51:21  skipping: [vmu20-01]
11:51:21  
11:51:21  TASK [****-os-hardening : Disable SSH Root Login] ***************************
11:51:21  skipping: [vmu20-01]
11:51:21  
11:51:21  TASK [****-os-hardening : Disable SSH Root Login] ***************************
11:51:21  skipping: [vmu20-01]
11:51:21  
11:51:21  TASK [****-os-hardening : Use Only Approved Cipher in Counter Mode] *********
11:51:21  skipping: [vmu20-01]
11:51:21  
11:51:21  TASK [****-os-hardening : Set Idle Timeout Interval for User Login] *********
11:51:21  skipping: [vmu20-01]
11:51:21  
11:51:21  TASK [****-os-hardening : Set Idle Timeout Interval for User Login] *********
11:51:21  skipping: [vmu20-01]
11:51:21  
11:51:21  TASK [****-os-hardening : Set SSH Banner] ***********************************
11:51:22  skipping: [vmu20-01]
11:51:22  
11:51:22  TASK [****-os-hardening : Reload ssh] ***************************************
11:51:22  skipping: [vmu20-01]
11:51:22  
11:51:22  TASK [****-os-hardening : Set Password Requirement Parameters Using pam_cracklib (Install)] ***
11:51:22  skipping: [vmu20-01]
11:51:22  
11:51:22  TASK [****-os-hardening : Limit Password Reuse] *****************************
11:51:22  skipping: [vmu20-01]
11:51:22  
11:51:22  TASK [****-os-hardening : Restrict Access to the su Command] ****************
11:51:22  skipping: [vmu20-01]
11:51:22  
11:51:22  TASK [****-os-hardening : update pam on Debian systems] *********************
11:51:22  skipping: [vmu20-01]
11:51:22  
11:51:22  TASK [****-os-hardening : remove pam ccreds to disable password caching] ****
11:51:22  skipping: [vmu20-01]
11:51:22  
11:51:22  TASK [****-os-hardening : remove pam_cracklib, because it does not play nice with passwdqc] ***
11:51:22  skipping: [vmu20-01]
11:51:22  
11:51:22  TASK [****-os-hardening : install the package for strong password checking] ***
11:51:22  skipping: [vmu20-01]
11:51:22  
11:51:22  TASK [****-os-hardening : configure passwdqc] *******************************
11:51:22  skipping: [vmu20-01]
11:51:22  
11:51:22  TASK [****-os-hardening : remove passwdqc] **********************************
11:51:22  skipping: [vmu20-01]
11:51:22  
11:51:22  TASK [****-os-hardening : install tally2] ***********************************
11:51:22  skipping: [vmu20-01]
11:51:22  
11:51:22  TASK [****-os-hardening : configure tally2] *********************************
11:51:22  skipping: [vmu20-01]
11:51:22  
11:51:22  TASK [****-os-hardening : delete tally2 when retries is 0] ******************
11:51:22  skipping: [vmu20-01]
11:51:22  
11:51:22  TASK [****-os-hardening : remove pam_cracklib, because it does not play nice with passwdqc] ***
11:51:22  skipping: [vmu20-01]
11:51:22  
11:51:22  TASK [****-os-hardening : install the package for strong password checking] ***
11:51:22  skipping: [vmu20-01]
11:51:22  
11:51:22  TASK [****-os-hardening : remove passwdqc] **********************************
11:51:23  skipping: [vmu20-01]
11:51:23  
11:51:23  TASK [****-os-hardening : configure passwdqc and tally via central system-auth confic] ***
11:51:23  skipping: [vmu20-01]
11:51:23  
11:51:23  TASK [****-os-hardening : Set Password Requirement Parameters Using pam_cracklib (Configure)] ***
11:51:23  skipping: [vmu20-01]
11:51:23  
11:51:23  TASK [****-os-hardening : Gather package facts] *****************************
11:51:23  skipping: [vmu20-01]
11:51:23  
11:51:23  TASK [****-os-hardening : NSA 2.3.3.5 Upgrade Password Hashing Algorithm to SHA-512] ***
11:51:23  skipping: [vmu20-01]
11:51:23  
11:51:23  TASK [****-os-hardening : Set Password Expiration Days] *********************
11:51:23  skipping: [vmu20-01]
11:51:23  
11:51:23  TASK [****-os-hardening : Set Password Expiration Days] *********************
11:51:23  skipping: [vmu20-01]
11:51:23  
11:51:23  TASK [****-os-hardening : Set Default umask for Users] **********************
11:51:23  skipping: [vmu20-01]
11:51:23  
11:51:23  TASK [****-os-hardening : Set Warning Banner for Standard Login Services] ***
11:51:23  skipping: [vmu20-01] => (item=/etc/motd) 
11:51:23  skipping: [vmu20-01] => (item=/etc/issue) 
11:51:23  skipping: [vmu20-01] => (item=/etc/issue.net) 
11:51:23  
11:51:23  TASK [****-os-hardening : Configure NTP - Install Package] ******************
11:51:23  skipping: [vmu20-01]
11:51:23  
11:51:23  TASK [****-os-hardening : Configure NTP - Update Config File] ***************
11:51:23  skipping: [vmu20-01]
11:51:23  
11:51:23  TASK [****-os-hardening : Set User/Group Owner and Permission on /etc/crontab] ***
11:51:24  ok: [vmu20-01]
11:51:24  
11:51:24  TASK [****-os-hardening : Set User/Group Owner and Permission on /etc/cron.hourly] ***
11:51:24  ok: [vmu20-01]
11:51:24  
11:51:24  TASK [****-os-hardening : Set User/Group Owner and Permission on /etc/cron.daily] ***
11:51:25  ok: [vmu20-01]
11:51:25  
11:51:25  TASK [****-os-hardening : Set User/Group Owner and Permission on /etc/cron.weekly] ***
11:51:25  ok: [vmu20-01]
11:51:25  
11:51:25  TASK [****-os-hardening : Set User/Group Owner and Permission on /etc/cron.monthly] ***
11:51:26  ok: [vmu20-01]
11:51:26  
11:51:26  TASK [****-os-hardening : Set User/Group Owner and Permission on /etc/cron.d] ***
11:51:26  ok: [vmu20-01]
11:51:26  
11:51:26  TASK [****-os-hardening : Restrict cron to Authorized Users (Remove cron.deny)] ***
11:51:26  ok: [vmu20-01]
11:51:26  
11:51:26  TASK [****-os-hardening : Restrict at to Authorized Users (Remove at.deny)] ***
11:51:27  ok: [vmu20-01]
11:51:27  
11:51:27  TASK [****-os-hardening : Restrict at to Authorized Users] ******************
11:51:27  changed: [vmu20-01]
11:51:27  
11:51:27  TASK [****-os-hardening : Restrict cron to Authorized Users] ****************
11:51:28  changed: [vmu20-01]
11:51:28  
11:51:28  TASK [****-os-hardening : Restrict Core Dumps - update limits] **************
11:51:28  ok: [vmu20-01]
11:51:28  
11:51:28  TASK [****-os-hardening : Restrict Core Dumps - cleanup kernal params] ******
11:51:29  ok: [vmu20-01]
11:51:29  
11:51:29  TASK [****-os-hardening : Restrict Core Dumps - remove apport] **************
11:51:30  ok: [vmu20-01]
11:51:30  
11:51:30  TASK [****-os-hardening : Protect sysctl.conf] ******************************
11:51:30  ok: [vmu20-01]
11:51:30  
11:51:30  TASK [****-os-hardening : Set Daemon umask, do config for rhel-family | NSA 2.2.4.1] ***
11:51:30  skipping: [vmu20-01]
11:51:30  
11:51:30  TASK [****-os-hardening : Install initramfs-tools] **************************
11:51:39  ok: [vmu20-01]
11:51:39  
11:51:39  TASK [****-os-hardening : Rebuild initramfs with starting pack of modules, if module loading at runtime is disabled] ***
11:51:40  ok: [vmu20-01]
11:51:40  
11:51:40  TASK [****-os-hardening : Create a combined sysctl-dict if overwrites are defined] ***
11:51:40  ok: [vmu20-01]
11:51:40  
11:51:40  TASK [****-os-hardening : Change various sysctl-settings, look at the sysctl-vars file for documentation] ***
11:51:41  ok: [vmu20-01] => (item={'key': 'fs.protected_hardlinks', 'value': 1})
11:51:41  ok: [vmu20-01] => (item={'key': 'fs.protected_symlinks', 'value': 1})
11:51:42  ok: [vmu20-01] => (item={'key': 'fs.suid_dumpable', 'value': 0})
11:51:42  ok: [vmu20-01] => (item={'key': 'kernel.core_uses_pid', 'value': 1})
11:51:42  ok: [vmu20-01] => (item={'key': 'kernel.kptr_restrict', 'value': 2})
11:51:43  ok: [vmu20-01] => (item={'key': 'kernel.kexec_load_disabled', 'value': 1})
11:51:43  ok: [vmu20-01] => (item={'key': 'kernel.sysrq', 'value': 0})
11:51:44  ok: [vmu20-01] => (item={'key': 'kernel.randomize_va_space', 'value': 2})
11:51:44  ok: [vmu20-01] => (item={'key': 'kernel.yama.ptrace_scope', 'value': 1})
11:51:44  ok: [vmu20-01] => (item={'key': 'net.ipv4.ip_forward', 'value': 1})
11:51:45  ok: [vmu20-01] => (item={'key': 'net.ipv6.conf.all.forwarding', 'value': 0})
11:51:45  ok: [vmu20-01] => (item={'key': 'net.ipv4.conf.all.rp_filter', 'value': 1})
11:51:46  ok: [vmu20-01] => (item={'key': 'net.ipv4.conf.default.rp_filter', 'value': 1})
11:51:46  ok: [vmu20-01] => (item={'key': 'net.ipv4.icmp_echo_ignore_broadcasts', 'value': 1})
11:51:46  ok: [vmu20-01] => (item={'key': 'net.ipv4.icmp_ignore_bogus_error_responses', 'value': 1})
11:51:47  ok: [vmu20-01] => (item={'key': 'net.ipv4.icmp_ratelimit', 'value': 100})
11:51:47  ok: [vmu20-01] => (item={'key': 'net.ipv4.icmp_ratemask', 'value': 88089})
11:51:48  ok: [vmu20-01] => (item={'key': 'net.ipv4.tcp_timestamps', 'value': 0})
11:51:48  ok: [vmu20-01] => (item={'key': 'net.ipv4.conf.all.arp_ignore', 'value': 1})
11:51:48  ok: [vmu20-01] => (item={'key': 'net.ipv4.conf.all.arp_announce', 'value': 2})
11:51:49  ok: [vmu20-01] => (item={'key': 'net.ipv4.tcp_rfc1337', 'value': 1})
11:51:49  ok: [vmu20-01] => (item={'key': 'net.ipv4.tcp_syncookies', 'value': 1})
11:51:50  ok: [vmu20-01] => (item={'key': 'net.ipv4.conf.all.shared_media', 'value': 1})
11:51:50  ok: [vmu20-01] => (item={'key': 'net.ipv4.conf.default.shared_media', 'value': 1})
11:51:51  ok: [vmu20-01] => (item={'key': 'net.ipv4.conf.all.accept_source_route', 'value': 0})
11:51:51  ok: [vmu20-01] => (item={'key': 'net.ipv4.conf.default.accept_source_route', 'value': 0})
11:51:52  ok: [vmu20-01] => (item={'key': 'net.ipv6.conf.all.accept_source_route', 'value': 0})
11:51:52  ok: [vmu20-01] => (item={'key': 'net.ipv6.conf.default.accept_source_route', 'value': 0})
11:51:52  ok: [vmu20-01] => (item={'key': 'net.ipv4.conf.all.send_redirects', 'value': 0})
11:51:53  ok: [vmu20-01] => (item={'key': 'net.ipv4.conf.default.send_redirects', 'value': 0})
11:51:53  ok: [vmu20-01] => (item={'key': 'net.ipv4.conf.all.log_martians', 'value': 1})
11:51:54  ok: [vmu20-01] => (item={'key': 'net.ipv4.conf.default.log_martians', 'value': 1})
11:51:54  ok: [vmu20-01] => (item={'key': 'net.ipv4.conf.default.accept_redirects', 'value': 0})
11:51:54  ok: [vmu20-01] => (item={'key': 'net.ipv4.conf.all.accept_redirects', 'value': 0})
11:51:55  ok: [vmu20-01] => (item={'key': 'net.ipv4.conf.all.secure_redirects', 'value': 0})
11:51:55  ok: [vmu20-01] => (item={'key': 'net.ipv4.conf.default.secure_redirects', 'value': 0})
11:51:57  ok: [vmu20-01] => (item={'key': 'net.ipv6.conf.default.accept_redirects', 'value': 0})
11:51:57  ok: [vmu20-01] => (item={'key': 'net.ipv6.conf.all.accept_redirects', 'value': 0})
11:51:57  ok: [vmu20-01] => (item={'key': 'net.ipv6.conf.all.disable_ipv6', 'value': 1})
11:51:58  ok: [vmu20-01] => (item={'key': 'net.ipv6.conf.all.accept_ra', 'value': 0})
11:51:58  ok: [vmu20-01] => (item={'key': 'net.ipv6.conf.default.accept_ra', 'value': 0})
11:51:59  ok: [vmu20-01] => (item={'key': 'net.ipv6.conf.default.router_solicitations', 'value': 0})
11:51:59  ok: [vmu20-01] => (item={'key': 'net.ipv6.conf.default.accept_ra_rtr_pref', 'value': 0})
11:52:00  ok: [vmu20-01] => (item={'key': 'net.ipv6.conf.default.accept_ra_pinfo', 'value': 0})
11:52:00  ok: [vmu20-01] => (item={'key': 'net.ipv6.conf.default.accept_ra_defrtr', 'value': 0})
11:52:01  ok: [vmu20-01] => (item={'key': 'net.ipv6.conf.default.autoconf', 'value': 0})
11:52:01  ok: [vmu20-01] => (item={'key': 'net.ipv6.conf.default.dad_transmits', 'value': 0})
11:52:01  ok: [vmu20-01] => (item={'key': 'net.ipv6.conf.default.max_addresses', 'value': 1})
11:52:02  ok: [vmu20-01] => (item={'key': 'vm.mmap_min_addr', 'value': 65536})
11:52:02  ok: [vmu20-01] => (item={'key': 'vm.mmap_rnd_bits', 'value': 32})
11:52:03  ok: [vmu20-01] => (item={'key': 'vm.mmap_rnd_compat_bits', 'value': 16})
11:52:03  ok: [vmu20-01] => (item={'key': 'net.core.rmem_default', 'value': 65536})
11:52:03  ok: [vmu20-01] => (item={'key': 'net.core.wmem_default', 'value': 65536})
11:52:04  ok: [vmu20-01] => (item={'key': 'net.core.wmem_max', 'value': 12582912})
11:52:04  ok: [vmu20-01] => (item={'key': 'net.core.rmem_max', 'value': 12582912})
11:52:05  ok: [vmu20-01] => (item={'key': 'net.ipv4.tcp_rmem', 'value': '10240 87380 12582912'})
11:52:05  ok: [vmu20-01] => (item={'key': 'net.ipv4.tcp_wmem', 'value': '10240 87380 12582912'})
11:52:06  ok: [vmu20-01] => (item={'key': 'net.ipv4.tcp_mem', 'value': '12582912 12582912 12582912'})
11:52:06  ok: [vmu20-01] => (item={'key': 'net.ipv4.tcp_window_scaling', 'value': 1})
11:52:07  ok: [vmu20-01] => (item={'key': 'net.ipv4.tcp_sack', 'value': 1})
11:52:07  ok: [vmu20-01] => (item={'key': 'net.ipv4.tcp_no_metrics_save', 'value': 1})
11:52:07  ok: [vmu20-01] => (item={'key': 'net.core.netdev_max_backlog', 'value': 5000})
11:52:07  
11:52:07  TASK [****-os-hardening : Change various sysctl-settings on rhel6-hosts or older, look at the sysctl-vars file for documentation] ***
11:52:08  skipping: [vmu20-01]
11:52:08  
11:52:08  TASK [****-os-hardening : Apply ufw defaults] *******************************
11:52:08  ok: [vmu20-01]
11:52:08  
11:52:08  TASK [****-os-hardening : Disable DCCP] *************************************
11:52:09  ok: [vmu20-01]
11:52:09  
11:52:09  TASK [****-os-hardening : Disable SCTP] *************************************
11:52:09  ok: [vmu20-01]
11:52:09  
11:52:09  TASK [****-os-hardening : Disable RDS] **************************************
11:52:10  ok: [vmu20-01]
11:52:10  
11:52:10  TASK [****-os-hardening : Disable TIPC] *************************************
11:52:10  ok: [vmu20-01]
11:52:10  
11:52:10  TASK [****-os-hardening : Disable cramfs] ***********************************
11:52:11  ok: [vmu20-01]
11:52:11  
11:52:11  TASK [****-os-hardening : Disable freevxfs] *********************************
11:52:11  ok: [vmu20-01]
11:52:11  
11:52:11  TASK [****-os-hardening : Disable hfs] **************************************
11:52:11  ok: [vmu20-01]
11:52:12  
11:52:12  TASK [****-os-hardening : Disable hfsplus] **********************************
11:52:12  ok: [vmu20-01]
11:52:12  
11:52:12  TASK [****-os-hardening : Disable jffs2] ************************************
11:52:12  ok: [vmu20-01]
11:52:12  
11:52:12  TASK [****-os-hardening : Disable squashfs] *********************************
11:52:13  ok: [vmu20-01]
11:52:13  
11:52:13  TASK [****-os-hardening : Disable udf] **************************************
11:52:13  ok: [vmu20-01]
11:52:13  
11:52:13  RUNNING HANDLER [firewall-config : reload firewalld] ***************************
11:52:17  changed: [vmu20-01]
11:52:17  
11:52:17  RUNNING HANDLER [bootstrap-linux-core : Restart journald] **********************
11:52:18  changed: [vmu20-01] => (item=systemd-journald)
11:52:18  
11:52:18  RUNNING HANDLER [ldap-client : restart nscd] ***********************************
11:52:19  changed: [vmu20-01]
11:52:19  
11:52:19  RUNNING HANDLER [ldap-client : restart nslcd] **********************************
11:52:20  changed: [vmu20-01]
11:52:20  
11:52:20  RUNNING HANDLER [firewall-config : reload firewalld] ***************************
11:52:23  changed: [vmu20-01]
11:52:23  
11:52:23  RUNNING HANDLER [firewall-config : reload firewalld] ***************************
11:52:26  changed: [vmu20-01]
11:52:26  
11:52:26  RUNNING HANDLER [****-role-stepca : reload systemctl] ***********************
11:52:29  changed: [vmu20-01]
11:52:29  
11:52:29  RUNNING HANDLER [deploy-cacerts : reload systemctl] ****************************
11:52:30  changed: [vmu20-01]
11:52:30  
11:52:30  PLAY [Bootstrap CI/CD node] ****************************************************
11:52:30  skipping: no hosts matched
11:52:30  
11:52:30  PLAY [Setup Jenkins Agent] *****************************************************
11:52:30  skipping: no hosts matched
11:52:30  
11:52:30  PLAY [Setup iscsi clients] *****************************************************
11:52:30  skipping: no hosts matched
11:52:30  
11:52:30  PLAY [Setup ntp clients] *******************************************************
11:52:30  
11:52:30  PLAY [Setup mergerfs nodes] ****************************************************
11:52:30  skipping: no hosts matched
11:52:30  
11:52:30  PLAY [Install veeam-agent] *****************************************************
11:52:30  skipping: no hosts matched
11:52:30  
11:52:30  PLAY [Configure veeam-agent jobs] **********************************************
11:52:30  skipping: no hosts matched
11:52:30  
11:52:30  PLAY [Bootstrap **** node] **************************************************
11:52:30  skipping: no hosts matched
11:52:30  
11:52:30  PLAY [Configure Step-ca cli for step clients] **********************************
11:52:30  
11:52:30  PLAY [Setup ca_root and cacerts] ***********************************************
11:52:30  skipping: no hosts matched
11:52:30  
11:52:30  PLAY [Create CA certs for cert_node] *******************************************
11:52:30  
11:52:30  PLAY [Deploy CA certs to cert_node] ********************************************
11:52:30  
11:52:30  PLAY [Bootstrap kvm hosts] *****************************************************
11:52:30  skipping: no hosts matched
11:52:30  
11:52:30  PLAY [Deploy VM] ***************************************************************
11:52:30  skipping: no hosts matched
11:52:30  
11:52:30  PLAY [Bootstrap docker nodes] **************************************************
11:52:30  skipping: no hosts matched
11:52:30  
11:52:30  PLAY [Create, tag and push docker images (ldap, jenkins, etc) to registry] *****
11:52:30  skipping: no hosts matched
11:52:30  
11:52:30  PLAY [Setup docker control plane node] *****************************************
11:52:30  skipping: no hosts matched
11:52:30  
11:52:30  PLAY [Setup docker admin node : mail, nfs, docker (traefik, portainer, watchdog, ldap, etc)] ***
11:52:30  skipping: no hosts matched
11:52:30  
11:52:30  PLAY [Setup docker media node] *************************************************
11:52:30  skipping: no hosts matched
11:52:30  
11:52:30  PLAY [Setup docker ml node] ****************************************************
11:52:30  skipping: no hosts matched
11:52:31  
11:52:31  PLAY [Deploy ProxMox Cluster] **************************************************
11:52:31  skipping: no hosts matched
11:52:31  
11:52:31  PLAY [Deploy VSphere Datacenter] ***********************************************
11:52:31  skipping: no hosts matched
11:52:31  
11:52:31  PLAY [Bootstrap VMware ESXi servers] *******************************************
11:52:31  skipping: no hosts matched
11:52:31  
11:52:31  PLAY [VMware Upgrade ESXi servers] *********************************************
11:52:31  skipping: no hosts matched
11:52:31  
11:52:31  PLAY [VMware Remount VM Datastores] ********************************************
11:52:31  skipping: no hosts matched
11:52:31  
11:52:31  PLAY [Bootstrap openstack] *****************************************************
11:52:31  skipping: no hosts matched
11:52:31  
11:52:31  PLAY [Bootstrap k8s cluster] ***************************************************
11:52:31  skipping: no hosts matched
11:52:31  
11:52:31  PLAY [Bootstrap openstack cloud] ***********************************************
11:52:31  skipping: no hosts matched
11:52:31  
11:52:31  PLAY [Install AWX] *************************************************************
11:52:31  skipping: no hosts matched
11:52:31  
11:52:31  PLAY [Install FOG server] ******************************************************
11:52:31  skipping: no hosts matched
11:52:31  
11:52:31  PLAY [Setup nginx] *************************************************************
11:52:31  skipping: no hosts matched
11:52:31  
11:52:31  PLAY [Bootstrap iDRAC Automation] **********************************************
11:52:31  skipping: no hosts matched
11:52:31  
11:52:31  PLAY [Get iDRAC LC Ready Status] ***********************************************
11:52:31  skipping: no hosts matched
11:52:31  
11:52:31  PLAY [Change iDRAC NTP Attributes] *********************************************
11:52:31  skipping: no hosts matched
11:52:31  
11:52:31  PLAY RECAP *********************************************************************
11:52:31  vmu20-01                   : ok=278  changed=42   unreachable=0    failed=0    skipped=151  rescued=0    ignored=0   
11:52:31  
[Pipeline] }
[Pipeline] // withCredentials
[Pipeline] }
[Pipeline] // script
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage (hide)
[Pipeline] { (Declarative: Post Actions) (hide)
[Pipeline] script (hide)
[Pipeline] { (hide)
[Pipeline] fileExists (hide)
[Pipeline] sh (hide)
11:54:40  + tail -n 50 ansible.log
[Pipeline] echo (hide)
11:54:42  sendEmailReport(): buildStatus=[SUCCESS]
[Pipeline] readFile (hide)
[Pipeline] emailextrecipients (hide)
11:54:42  Not sending mail to unregistered user lj020326@gmail.com because your SCM claimed this was associated with a user ID ‘lj020326' which your security realm does not recognize; you may need changes in your SCM plugin
[Pipeline] mail (hide)
[Pipeline] emailextrecipients (hide)
11:54:43  Not sending mail to unregistered user lj020326@gmail.com because your SCM claimed this was associated with a user ID ‘lj020326' which your security realm does not recognize; you may need changes in your SCM plugin
[Pipeline] emailext (hide)
11:54:43  Sending email to: admin@dettonville.org lee.james.johnson@gmail.com
[Pipeline] }
[Pipeline] // script
[Pipeline] echo (hide)
11:54:43  Empty current workspace dir
[Pipeline] }
[Pipeline] // stage
[Pipeline] }
[Pipeline] // timeout
[Pipeline] }
[Pipeline] // timestamps
[Pipeline] }
[Pipeline] // node
[Pipeline] End of Pipeline
Finished: SUCCESS

```