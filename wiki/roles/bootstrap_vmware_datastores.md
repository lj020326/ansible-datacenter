---
title: "Bootstrap Vmware Datastores Role"
role: roles/bootstrap_vmware_datastores
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_vmware_datastores]
---

# Role Documentation: `bootstrap_vmware_datastores`

## Overview

The `bootstrap_vmware_datastores` role is designed to manage VMware datastores on ESXi hosts using Ansible. This role can install necessary Python dependencies, unmount existing datastores if required, and mount new NFS-based datastores onto specified ESXi hosts.

## Role Variables

### Default Variables (`defaults/main.yml`)

| Variable Name                                | Description                                                                 | Default Value                                       |
|----------------------------------------------|-----------------------------------------------------------------------------|-----------------------------------------------------|
| `bootstrap_vmware_datastores__hostname`      | The hostname of the vCenter server.                                         | `{{ vcenter_hostname }}`                            |
| `bootstrap_vmware_datastores__username`      | The username to authenticate with the vCenter server.                       | `{{ vcenter_username }}`                            |
| `bootstrap_vmware_datastores__password`      | The password to authenticate with the vCenter server.                       | `{{ vcenter_password }}`                            |
| `bootstrap_vmware_datastores__python_pip_depends` | A list of Python packages required for this role, specifically `pyVmomi`. | `['pyVmomi']`                                       |
| `bootstrap_vmware_datastores__unmount_datastores_first` | Whether to unmount existing datastores before mounting new ones.  | `false`                                             |
| `bootstrap_vmware_datastores__host_datastores` | A list of datastores to be managed, including their type, server, path, and associated ESXi hosts. | Refer to the example below                          |

**Example of `bootstrap_vmware_datastores__host_datastores`:**

```yaml
bootstrap_vmware_datastores__host_datastores:
  - name: nfs_ds1
    server: control01.example.int
    path: /data/datacenter/vmware
    type: nfs
    esxi_hosts:
      - esx01.example.int
      - esx02.example.int
```

## Tasks

### Task Breakdown (`tasks/main.yml`)

1. **Install Common Pip Libraries**
   - Installs the Python packages listed in `bootstrap_vmware_datastores__python_pip_depends`.
   
   ```yaml
   - name: Install common pip libs # noqa: package-latest
     when:
       - bootstrap_vmware_datastores__python_pip_depends is defined
       - not (bootstrap_vmware_datastores__python_pip_depends is none)
     ansible.builtin.pip:
       name: "{{ bootstrap_vmware_datastores__python_pip_depends }}"
       state: latest
   ```

2. **Display Configuration Variables**
   - Debug tasks to display the `bootstrap_vmware_datastores__host_datastores` and `bootstrap_vmware_datastores__unmount_datastores_first` variables for verification.
   
   ```yaml
   - name: Display bootstrap_vmware_datastores__host_datastores
     ansible.builtin.debug:
       var: bootstrap_vmware_datastores__host_datastores
   
   - name: Display bootstrap_vmware_datastores__unmount_datastores_first
     ansible.builtin.debug:
       var: bootstrap_vmware_datastores__unmount_datastores_first
   ```

3. **Remove/Unmount Datastores**
   - Unmounts existing datastores if `bootstrap_vmware_datastores__unmount_datastores_first` is set to `true`.
   
   ```yaml
   - name: Remove/Unmount Datastores
     when: bootstrap_vmware_datastores__unmount_datastores_first
     community.vmware.vmware_host_datastore:
       hostname: "{{ bootstrap_vmware_datastores__hostname }}"
       username: "{{ bootstrap_vmware_datastores__username }}"
       password: "{{ bootstrap_vmware_datastores__password }}"
       validate_certs: false
       esxi_hostname: "{{ hostvars[item.1]['ansible_host'] }}"
       datastore_name: "{{ item.0.name }}"
       state: absent
     loop: "{{ bootstrap_vmware_datastores__host_datastores | subelements('esxi_hosts', {'skip_missing': true}) }}"
     loop_control:
       label: "{{ item.1 }}"
   ```

4. **Mount Datastore**
   - Mounts NFS datastores onto the specified ESXi hosts.
   
   ```yaml
   - name: Mount datastore
     block:
       - name: Mount NFS datastores
         community.vmware.vmware_host_datastore:
           hostname: "{{ bootstrap_vmware_datastores__hostname }}"
           username: "{{ bootstrap_vmware_datastores__username }}"
           password: "{{ bootstrap_vmware_datastores__password }}"
           validate_certs: false
           datastore_name: "{{ item.0.name }}"
           datastore_type: "{{ item.0.type }}"
           nfs_server: "{{ item.0.server }}"
           nfs_path: "{{ item.0.path }}"
           nfs_ro: false
           esxi_hostname: "{{ hostvars[item.1]['ansible_host'] | d(omit) }}"
           state: present
         loop: "{{ bootstrap_vmware_datastores__host_datastores | subelements('esxi_hosts', {'skip_missing': true}) }}"
         loop_control:
           label: "{{ item.1 }}"
         register: vmware_mount_status
     rescue:
       - name: Display vmware_mount_status
         ansible.builtin.debug:
           var: vmware_mount_status
       - name: Unmount datastore for problem hosts
         when: item.failed
         community.vmware.vmware_host_datastore:
           hostname: "{{ bootstrap_vmware_datastores__hostname }}"
           username: "{{ bootstrap_vmware_datastores__username }}"
           password: "{{ bootstrap_vmware_datastores__password }}"
           validate_certs: false
           datastore_name: "{{ item.item.0.name }}"
           esxi_hostname: "{{ hostvars[item.item.1]['ansible_host'] | d(omit) }}"
           state: absent
         loop: "{{ vmware_mount_status.results }}"
         loop_control:
           label: "{{ item.item.1 }} unmounting {{ item.item.0.name }}"
       - name: Remount datastore for problem hosts
         when: item.failed
         community.vmware.vmware_host_datastore:
           hostname: "{{ bootstrap_vmware_datastores__hostname }}"
           username: "{{ bootstrap_vmware_datastores__username }}"
           password: "{{ bootstrap_vmware_datastores__password }}"
           validate_certs: false
           datastore_name: "{{ item.item.0.name }}"
           datastore_type: "{{ item.item.0.type }}"
           nfs_server: "{{ item.item.0.server }}"
           nfs_path: "{{ item.item.0.path }}"
           nfs_ro: false
           esxi_hostname: "{{ hostvars[item.item.1]['ansible_host'] | d(omit) }}"
           state: present
         loop: "{{ vmware_mount_status.results }}"
         loop_control:
           label: "{{ item.item.1 }} mounting {{ item.item.0.name }}"
   ```

## Usage

### Example Playbook

```yaml
---
- name: Manage VMware Datastores
  hosts: localhost
  gather_facts: no
  vars_files:
    - vars/vcenter_credentials.yml
  roles:
    - role: bootstrap_vmware_datastores
      vars:
        bootstrap_vmware_datastores__hostname: vcenter.example.int
        bootstrap_vmware_datastores__username: admin@vsphere.local
        bootstrap_vmware_datastores__password: "{{ vcenter_password }}"
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

### Notes

- **Double-underscore variables** are internal to the role and should not be modified outside of this context.
- Ensure that the `vcenter_hostname`, `vcenter_username`, and `vcenter_password` are correctly defined in your inventory or passed as extra vars.
- The `bootstrap_vmware_datastores__host_datastores` variable must contain a list of datastores with their respective configurations.

## Troubleshooting

- **Failed Mounts**: If a datastore fails to mount, the role will attempt to unmount and then remount it on the affected ESXi hosts. Debug information is displayed using `ansible.builtin.debug`.
- **Authentication Issues**: Ensure that the provided credentials have sufficient permissions to manage datastores on the vCenter server.

## Conclusion

The `bootstrap_vmware_datastores` role provides a robust mechanism for managing VMware datastores, ensuring that NFS-based datastores are correctly mounted onto ESXi hosts. By leveraging Ansible's powerful automation capabilities, this role simplifies the process of configuring and maintaining your VMware environment.