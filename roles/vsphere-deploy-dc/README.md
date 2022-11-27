vcsa-deploy
=========

Deploy a vCenter Server Appliance or Platform Services Controller from OVA to a target ESXi node.

Fork of https://github.com/vmware/ansible-role-vcsa

Requirements
------------

pyvmomi

Role Variables
--------------

```yaml
vcenter_repo_dir: '/opt/repo'
vsphere_deploy_dc_vcsa_iso: 'VMware-VCSA-all-6.7.0-9451876.iso'
vcsa_task_directory: '/opt/ansible/roles/vcsa-deploy/tasks'

vsphere_deploy_dc_ovftool: '/mnt/vcsa/ovftool/lin64/ovftool'
vsphere_deploy_dc_vcsa_ova: 'vcsa/VMware-vCenter-Server-Appliance-6.7.0.14000-9451876_OVF10.ova'
vsphere_deploy_dc_vcenter_mount_dir: '/mnt'

vsphere_deploy_dc_vcenter_appliance_type: 'embedded'

vsphere_deploy_dc_vcenter_net_addr_family: 'ipv4'
vsphere_deploy_dc_vcenter_network_ip_scheme: 'static'
vsphere_deploy_dc_vcenter_disk_mode: 'thin'
vsphere_deploy_dc_vcenter_ssh_enable: true

vsphere_deploy_dc_vcenter_appliance_name: 'vcenter'
vsphere_deploy_dc_vcenter_appliance_size: 'medium'

target_esxi_username: '{{ vault_esxi_username }}'
target_esxi_password: '{{ vault_esxi_password }}'
target_esx_datastore: 'local-t410-3TB'
target_esx_portgroup: 'Management'

vcenter_time_sync_tools: false

vsphere_deploy_dc_vcenter_password: '{{ vault_vcenter_password }}'
vsphere_deploy_dc_vcenter_fqdn: 'vcenter.local.domain'
vsphere_deploy_dc_vcenter_ip: '192.168.0.25'
vsphere_deploy_dc_vcenter_netmask: '255.255.0.0'
vsphere_deploy_dc_vcenter_gateway: '192.168.0.1'
vsphere_deploy_dc_vcenter_net_prefix: '16'

dns_servers: '192.168.0.1,192.168.0.2'
ntp_servers: '132.163.96.1,132.163.97.1'

vsphere_deploy_dc_vcenter_password: '{{ vault_vcenter_password }}'
vsphere_deploy_dc_vcenter_site_name: 'Default-Site'
vsphere_deploy_dc_vcenter_sso_domain: 'vsphere.local'
```

Dependencies
------------

An Ansible Vault file must exist and include the following variables:

```yaml
vault_esxi_username: 'root'
vault_esxi_password: 'password'
vault_vcenter_password: 'password'
```

The vCenter Server Appliance ISO must be accessible to the role/playbook.

Example Playbook
----------------

```yaml
---
- hosts: all
  connection: local
  gather_facts: false
  
  roles:
    - vcsa-deploy
```
