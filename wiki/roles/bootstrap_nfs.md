---
title: "Bootstrap NFS Role"
role: bootstrap_nfs
category: Storage
type: Role
tags: [ansible, role, bootstrap_nfs]
---

# Bootstrap NFS Role

The `bootstrap_nfs` role is designed to set up and configure NFS (Network File System) on a server. It installs the necessary NFS utilities, configures the NFS exports, and ensures that the NFS server is running. This role is particularly useful for setting up shared storage solutions in a networked environment.

## Variables

| Variable Name                | Default Value       | Description                                                                 |
|------------------------------|---------------------|-----------------------------------------------------------------------------|
| `bootstrap_nfs__exports`     | `[]`                | List of directories to be exported via NFS.                                |
| `bootstrap_nfs__rpcbind_state` | `started`           | Desired state of the rpcbind service.                                      |
| `bootstrap_nfs__rpcbind_enabled` | `true`              | Whether the rpcbind service should be enabled.                              |

## Usage

To use the `bootstrap_nfs` role, include it in your playbook and define the necessary variables. Here is an example playbook:

```yaml
---
- hosts: nfs_servers
  roles:
    - role: bootstrap_nfs
      vars:
        bootstrap_nfs__exports:
          - "/export/dir1 *(rw,sync,no_subtree_check)"
          - "/export/dir2 *(ro,sync,no_subtree_check)"
```

## Dependencies

This role does not have any external dependencies. It relies on the standard Ansible modules such as `apt`, `yum`, `service`, and the NFS utilities available on the target system.

## Best Practices

- Ensure that the directories specified in `bootstrap_nfs__exports` exist on the target system.
- Use appropriate NFS export options based on your security and performance requirements.
- Regularly review and update the NFS export configuration to reflect changes in your network environment.

## Related Files

- [defaults/main.yml](../../roles/bootstrap_nfs/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_nfs/tasks/main.yml)
- [handlers/main.yml](../../roles/bootstrap_nfs/handlers/main.yml)