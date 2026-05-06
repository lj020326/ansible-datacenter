---
title: Bootstrap NFS Role Documentation
role: bootstrap_nfs
category: Ansible Roles
type: Configuration Management
tags: nfs, rpcbind, automation, ansible
---

## Summary

The `bootstrap_nfs` role is designed to automate the setup and configuration of Network File System (NFS) on target hosts. This includes installing necessary NFS utilities, configuring directories for export, setting up the `/etc/exports` file, and ensuring that both `rpcbind` and NFS services are running as specified.

## Variables

| Variable Name                 | Default Value                             | Description                                                                 |
|-------------------------------|-------------------------------------------|-----------------------------------------------------------------------------|
| `bootstrap_nfs__exports`      | `[]`                                      | A list of directories to be exported by NFS. Each entry should include the directory path and export options separated by a space (e.g., `/mnt/nfs *(rw,sync)`). |
| `bootstrap_nfs__rpcbind_state`| `started`                                 | The desired state for the `rpcbind` service (`started`, `stopped`).         |
| `bootstrap_nfs__rpcbind_enabled`| `true`                                   | Whether the `rpcbind` service should be enabled to start on boot (`true`, `false`). |

## Usage

To use the `bootstrap_nfs` role, include it in your playbook and define the necessary variables as required. Below is an example of how you might configure and use this role:

```yaml
- hosts: nfs_servers
  roles:
    - role: bootstrap_nfs
      vars:
        bootstrap_nfs__exports:
          - "/mnt/nfs *(rw,sync)"
          - "/var/www/html 192.168.1.0/24(rw,no_subtree_check)"
```

## Dependencies

- **OS-Specific Variables**: The role dynamically includes OS-specific variables based on the target host's distribution and version.
- **Fedora Overrides**: If the target host is a Fedora system, additional overrides are included from `Fedora.yml`.

## Tags

- **reload nfs**: This tag can be used to specifically trigger the handler that reloads NFS exports.

Example usage with tags:

```bash
ansible-playbook -i inventory playbook.yml --tags "reload nfs"
```

## Best Practices

1. **Define Exports Carefully**: Ensure that the directories and export options specified in `bootstrap_nfs__exports` are correctly configured to meet your security requirements.
2. **Use Tags for Specific Tasks**: Utilize tags like `reload nfs` to perform specific tasks without running the entire playbook.

## Molecule Tests

This role does not include Molecule tests at this time. Consider adding Molecule scenarios to ensure the role behaves as expected across different environments.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_nfs/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_nfs/tasks/main.yml)
- [handlers/main.yml](../../roles/bootstrap_nfs/handlers/main.yml)