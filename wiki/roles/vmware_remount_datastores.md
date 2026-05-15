---
title: VMware Remount Datastores Role Documentation
role: vmware_remount_datastores
category: VMware Management
type: Ansible Role
tags: vmware, datastore, remount, nfs
---

## Summary

The `vmware_remount_datastores` role is designed to unmount and then remount specified NFS datastores on ESXi hosts managed by a vCenter server. This role ensures that the datastores are correctly configured and available for use after any necessary maintenance or changes.

## Variables

| Variable Name                         | Default Value                                                                 | Description                                                                                                                                 |
|---------------------------------------|-------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------|
| `role_vmware_remount_datastores__vcenter_hostname` | `"vcenter.example.int"`                                                       | The hostname of the vCenter server.                                                                                                         |
| `role_vmware_remount_datastores__vcenter_username` | `"administrator"`                                                             | The username to authenticate with the vCenter server.                                                                                       |
| `role_vmware_remount_datastores__vcenter_password` | `"password"`                                                                  | The password for the vCenter user. **Note:** It is recommended to use Ansible Vault or environment variables for sensitive information.     |
| `role_vmware_remount_datastores__vcenter_python_pip_depends` | <pre>\- pyVmomi</pre>                                                       | List of Python packages required by the role, specifically `pyVmomi`.                                                                         |
| `role_vmware_remount_datastores__vmware_host_datastores` | <pre>\- name: 'nfs_ds1'<br>&nbsp;&nbsp;server: 'control01.example.int'<br>&nbsp;&nbsp;path: '/data/datacenter/vmware'<br>&nbsp;&nbsp;type: 'nfs'<br>&nbsp;&nbsp;esxi_hosts:<br>&nbsp;&nbsp;&nbsp;- "esx01.example.int"<br>&nbsp;&nbsp;&nbsp;- "esx02.example.int"</pre> | A list of datastores to be managed, including their names, server details, paths, types, and associated ESXi hosts.                             |

## Usage

To use the `vmware_remount_datastores` role, include it in your playbook and provide the necessary variables. Here is an example playbook:

```yaml
---
- name: Manage VMware Datastores
  hosts: localhost
  gather_facts: no
  roles:
    - role: vmware_remount_datastores
      vars:
        role_vmware_remount_datastores__vcenter_hostname: "vcenter.example.int"
        role_vmware_remount_datastores__vcenter_username: "administrator"
        role_vmware_remount_datastores__vcenter_password: "{{ lookup('env', 'VCENTER_PASSWORD') }}"
        role_vmware_remount_datastores__vmware_host_datastores:
          - name: 'nfs_ds1'
            server: 'control01.example.int'
            path: '/data/datacenter/vmware'
            type: 'nfs'
            esxi_hosts:
              - "esx01.example.int"
              - "esx02.example.int"
```

## Dependencies

- The `pyVmomi` Python package is required for interacting with the vCenter API. This role installs it using Ansible's `pip` module.
- The `community.vmware` collection must be installed in your Ansible environment.

To install the `community.vmware` collection, run:

```bash
ansible-galaxy collection install community.vmware
```

## Best Practices

- **Security:** Avoid hardcoding sensitive information such as passwords. Use Ansible Vault or environment variables to manage secrets.
- **Validation:** Ensure that the vCenter server and ESXi hosts are correctly configured and accessible from the control machine running the playbook.
- **Testing:** Test the role in a non-production environment before applying it to production systems.

## Molecule Tests

This role does not currently include Molecule tests. Consider adding them for automated testing of the role's functionality.

## Backlinks

- [defaults/main.yml](../../roles/vmware_remount_datastores/defaults/main.yml)
- [tasks/main.yml](../../roles/vmware_remount_datastores/tasks/main.yml)