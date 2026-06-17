---
title: "vmware_remount_datastores Role"
role: vmware_remount_datastores
category: VMware Management
type: Ansible Role
tags: vmware, datastore, nfs, ansible
---

## Summary

The `vmware_remount_datastores` role is designed to manage NFS datastores in a VMware environment. It unmounts and then remounts specified NFS datastores on ESXi hosts using the `community.vmware.vmware_host_datastore` module. This ensures that any changes or issues with the datastores can be addressed by re-mounting them.

## Variables

| Variable Name                | Default Value                                                                 | Description                                                                 |
|------------------------------|-------------------------------------------------------------------------------|-----------------------------------------------------------------------------|
| `vcenter_hostname`           | `"vcenter.example.int"`                                                       | The hostname of the vCenter server.                                         |
| `vcenter_username`           | `"administrator"`                                                             | The username to authenticate with the vCenter server.                       |
| `vcenter_password`           | `"password"`                                                                  | The password for the vCenter user.                                          |
| `vcenter_python_pip_depends` | `[ 'pyVmomi' ]`                                                               | List of Python packages required by the role, primarily `pyVmomi`.          |
| `vmware_host_datastores`     | <pre>\- name: 'nfs_ds1'<br>&nbsp;&nbsp;server: 'control01.example.int'<br>&nbsp;&nbsp;path: '/data/datacenter/vmware'<br>&nbsp;&nbsp;type: 'nfs'<br>&nbsp;&nbsp;esxi_hosts:<br>&nbsp;&nbsp;&nbsp;- "esx01.example.int"<br>&nbsp;&nbsp;&nbsp;- "esx02.example.int"</pre> | List of datastores to manage, including their server, path, type, and ESXi hosts. |

## Usage

To use the `vmware_remount_datastores` role, include it in your playbook and define the necessary variables as shown below:

```yaml
- name: Remount NFS Datastores on VMware ESXi Hosts
  hosts: localhost
  gather_facts: no
  roles:
    - vmware_remount_datastores

  vars:
    vcenter_hostname: "vcenter.example.int"
    vcenter_username: "administrator"
    vcenter_password: "password"
    vmware_host_datastores:
      - name: 'nfs_ds1'
        server: 'control01.example.int'
        path: '/data/datacenter/vmware'
        type: 'nfs'
        esxi_hosts:
          - "esx01.example.int"
          - "esx02.example.int"
```

## Dependencies

- `community.vmware` collection
- Python package `pyVmomi`

Ensure that the required Ansible collections and Python packages are installed before running this role.

## Best Practices

- Always ensure that the vCenter credentials provided have sufficient permissions to manage datastores.
- Use secure methods for handling sensitive information such as passwords, e.g., Ansible Vault.
- Test changes in a non-production environment before applying them to production systems.

## Molecule Tests

This role does not currently include any Molecule tests. Consider adding tests to ensure the role behaves as expected under various conditions.

## Backlinks

- [defaults/main.yml](../../roles/vmware_remount_datastores/defaults/main.yml)
- [tasks/main.yml](../../roles/vmware_remount_datastores/tasks/main.yml)