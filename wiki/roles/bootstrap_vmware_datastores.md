---
title: Bootstrap VMware Datastores Role Documentation
role: bootstrap_vmware_datastores
category: VMware Management
type: Ansible Role
tags: vmware, datastore, nfs, esxi, ansible
---

## Summary

The `bootstrap_vmware_datastores` role is designed to manage VMware datastores on ESXi hosts. It handles the installation of necessary Python dependencies, unmounts existing datastores if required, and mounts new NFS-based datastores onto specified ESXi hosts.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_vmware_datastores__hostname` | `"{{ vcenter_hostname }}"` | The hostname or IP address of the VMware vCenter server. |
| `bootstrap_vmware_datastores__username` | `"{{ vcenter_username }}"` | The username for authenticating with the VMware vCenter server. |
| `bootstrap_vmware_datastores__password` | `"{{ vcenter_password }}"` | The password for authenticating with the VMware vCenter server. |
| `bootstrap_vmware_datastores__python_pip_depends` | `[ "pyVmomi" ]` | A list of Python packages to be installed via pip, required for interacting with VMware APIs. |
| `bootstrap_vmware_datastores__unmount_datastores_first` | `false` | A boolean flag indicating whether existing datastores should be unmounted before mounting new ones. |
| `bootstrap_vmware_datastores__host_datastores` | Refer to example below | A list of dictionaries defining the datastores to be mounted on ESXi hosts, including details like name, server, path, type, and associated ESXi hosts. |

**Example for `bootstrap_vmware_datastores__host_datastores`:**
```yaml
- name: nfs_ds1
  server: control01.example.int
  path: /data/datacenter/vmware
  type: nfs
  esxi_hosts:
    - esx01.example.int
    - esx02.example.int
```

## Usage

To use the `bootstrap_vmware_datastores` role, include it in your playbook and provide the necessary variables. Below is an example of how to integrate this role into a playbook:

```yaml
- name: Bootstrap VMware Datastores on ESXi Hosts
  hosts: esxi_hosts
  gather_facts: false
  roles:
    - role: bootstrap_vmware_datastores
      vars:
        bootstrap_vmware_datastores__hostname: "vcenter.example.int"
        bootstrap_vmware_datastores__username: "admin"
        bootstrap_vmware_datastores__password: "secure_password"
        bootstrap_vmware_datastores__unmount_datastores_first: true
        bootstrap_vmware_datastores__host_datastores:
          - name: nfs_ds1
            server: control01.example.int
            path: /data/datacenter/vmware
            type: nfs
            esxi_hosts:
              - esx01.example.int
              - esx02.example.int
```

## Dependencies

- `ansible.builtin.pip` module for installing Python packages.
- `community.vmware.vmware_host_datastore` module from the Ansible VMware collection, which requires the `pyVmomi` library.

Ensure that the following collections are installed:

```bash
ansible-galaxy collection install community.vmware
```

## Best Practices

1. **Security**: Ensure that sensitive information such as passwords is stored securely using Ansible Vault.
2. **Validation**: Set `validate_certs: true` in production environments to validate SSL certificates of the vCenter server.
3. **Testing**: Use Molecule tests to verify the role's functionality before deploying it in a production environment.

## Molecule Tests

This role includes Molecule tests to ensure its functionality. To run the tests, execute:

```bash
molecule test
```

Ensure that you have Docker installed and running on your system as Molecule uses Docker containers for testing.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_vmware_datastores/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_vmware_datastores/tasks/main.yml)