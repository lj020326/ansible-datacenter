---
title: Deploy vCenter Server Appliance or Platform Services Controller
original_path: roles/bootstrap_vsphere/README.md
source_type: legacy_markdown
category: Ansible Role
tags:
  - vCenter
  - VCSA
  - ESXi
  - VMware
  - Ansible
harvested_date: '2026-08-07T18:07:09.461439+00:00'
---

# Deploy vCenter Server Appliance or Platform Services Controller

This Ansible role deploys a vCenter Server Appliance (VCSA) or Platform Services Controller (PSC) from an OVA file to a target ESXi node. It is a fork of the [vmware/ansible-role-vcsa](https://github.com/vmware/ansible-role-vcsa) repository.

## Requirements

- `pyvmomi`

## Role Variables

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

vsphere_deploy_dc_vcenter_site_name: 'Default-Site'
vsphere_deploy_dc_vcenter_sso_domain: 'vsphere.local'
```

## Dependencies

An Ansible Vault file must exist and include the following variables:

```yaml
vault_esxi_username: 'root'
vault_esxi_password: 'password'
vault_vcenter_password: 'password'
```

The vCenter Server Appliance ISO must be accessible to the role/playbook.

## Example Playbook

```yaml
---
- hosts: all
  connection: local
  gather_facts: false

  roles:
    - vcsa-deploy
```

## Expected Outcomes

After running this playbook, a vCenter Server Appliance or Platform Services Controller should be deployed on the target ESXi node with the specified configuration.

## Troubleshooting

If you encounter issues during deployment, check the following:

- Ensure that the vCenter Server Appliance ISO is accessible and properly mounted.
- Verify that the target ESXi node is reachable and that the provided credentials are correct.
- Check the Ansible logs for any error messages or warnings.

## Contributing

If you would like to contribute to this role, please follow these steps:

1. Fork the repository and create a new branch.
2. Make your changes and commit them with descriptive messages.
3. Submit a pull request with a clear description of your changes.