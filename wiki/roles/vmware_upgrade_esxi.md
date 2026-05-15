---
title: VMware ESXi Upgrade Role Documentation
role: vmware_upgrade_esxi
category: Ansible Roles
type: Infrastructure Management
tags: vmware, esxi, upgrade, ansible
---

## Summary

The `vmware_upgrade_esxi` role is designed to automate the process of upgrading VMware ESXi hosts. It checks for running VMs and either waits until they are stopped or forces a reboot if specified. The role then puts the host into maintenance mode, installs the specified ESXi upgrade package from a local ISO directory or a remote patch depot, and handles the necessary software profile updates.

## Variables

| Variable Name                         | Default Value                                                                                   | Description                                                                                                                                                                                                 |
|---------------------------------------|-------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `role_vmware_upgrade_esxi__ansible_user` | `root`                                                                                          | The user account used to connect to the ESXi host.                                                                                                                                                           |
| `role_vmware_upgrade_esxi__vmware_force_reboot` | `false`                                                                                         | If set to `true`, forces a reboot of the ESXi host even if there are running VMs.                                                                                                                            |
| `role_vmware_upgrade_esxi__vmware_iso_dir` | `/vmfs/volumes/nfs_ds1/iso-repos/vmware`                                                          | The directory on the ESXi host where the upgrade ISO is located.                                                                                                                                               |
| `role_vmware_upgrade_esxi__vmware_target_dist` | `VMware-ESXi-7.0U3e-19898904-depot.zip`                                                        | The name of the ESXi upgrade package file in the specified ISO directory.                                                                                                                                    |
| `role_vmware_upgrade_esxi__vmware_target_profile` | `ESXi-7.0U3e-19898904-standard`                                                              | The target software profile to apply during the upgrade process.                                                                                                                                               |
| `role_vmware_upgrade_esxi__vmware_use_local` | `true`                                                                                          | If set to `true`, uses a local ISO file for the upgrade; otherwise, it uses a remote patch depot URL.                                                                                                          |
| `role_vmware_upgrade_esxi__vmware_patch_depot_url` | `https://hostupdate.vmware.com/software/VUM/PRODUCTION/main/vmw-depot-index.xml`              | The URL of the VMware patch depot to use if `vmware_use_local` is set to `false`.                                                                                                                            |
| `role_vmware_upgrade_esxi__vmware_esxi_password` | `"{{ vault__vmware_esxi_password }}"`                                                           | The password for the ESXi host, which should be stored in an Ansible Vault.                                                                                                                                |

## Usage

To use this role, include it in your playbook and provide the necessary variables as needed. Here is an example:

```yaml
- name: Upgrade VMware ESXi hosts
  hosts: esxi_hosts
  become: yes
  vars:
    role_vmware_upgrade_esxi__vmware_force_reboot: true
    role_vmware_upgrade_esxi__vmware_iso_dir: /path/to/local/iso
    role_vmware_upgrade_esxi__vmware_target_dist: VMware-ESXi-7.0U3e-19898904-depot.zip
    role_vmware_upgrade_esxi__vmware_target_profile: ESXi-7.0U3e-19898904-standard
  roles:
    - vmware_upgrade_esxi
```

## Dependencies

This role does not have any external dependencies other than the Ansible VMware modules, which should be installed in your environment.

## Best Practices

1. **Backup Configuration**: Always ensure you have a backup of your ESXi host configuration before performing an upgrade.
2. **Network Availability**: Ensure that the network is stable and that there are no ongoing operations on the ESXi hosts during the upgrade process.
3. **Inventory Management**: Use Ansible inventory to manage your ESXi hosts and apply the role accordingly.

## Molecule Tests

This role does not currently include Molecule tests. Consider adding them for better testing coverage.

## Backlinks

- [defaults/main.yml](../../roles/vmware_upgrade_esxi/defaults/main.yml)
- [tasks/main.yml](../../roles/vmware_upgrade_esxi/tasks/main.yml)

---

**Note**: Variables starting with `__internal_var` are internal to the role and should not be overridden in your inventory or command line.