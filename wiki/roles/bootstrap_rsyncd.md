---
title: Bootstrap Rsyncd Role Documentation
role: bootstrap_rsyncd
category: Ansible Roles
type: Configuration Management
tags: rsync, automation, configuration
---

## Summary

The `bootstrap_rsyncd` role is designed to automate the installation and configuration of the `rsync` daemon (`rsyncd`) on target hosts. It ensures that `rsync` is installed, configures the `rsyncd.conf` file, sets up SELinux policies if necessary, and manages the `rsyncd` service state. Additionally, it provides tasks for synchronizing files between source and remote hosts.

## Variables

| Variable Name                      | Default Value                                    | Description                                                                 |
|------------------------------------|--------------------------------------------------|-----------------------------------------------------------------------------|
| `role_bootstrap_rsyncd__packages`  | `['rsync']`                                      | List of packages to install.                                                |
| `role_bootstrap_rsyncd__config`    | `/etc/rsyncd.conf`                               | Path to the rsync daemon configuration file.                                |
| `role_bootstrap_rsyncd__service`   | `rsyncd.service`                                 | Name of the rsync service.                                                  |
| `role_bootstrap_rsyncd__temp_sudoers_file` | `/etc/sudoers.d/rsyncuser`                  | Path to the temporary sudoers file for granting `NOPASSWD` permissions.     |

## Usage

### Example Playbook

```yaml
- hosts: all
  roles:
    - role: bootstrap_rsyncd
      vars:
        role_bootstrap_rsyncd__remote_host: "target.example.com"
        role_bootstrap_rsyncd__source_filesystem_path: "/path/to/source/files"
        role_bootstrap_rsyncd__remote_filesystem_path: "/path/to/remote/files"
```

### Synchronizing Files

To synchronize files from a source host to a remote host, ensure the following variables are defined:

- `role_bootstrap_rsyncd__source_host`: The hostname or IP address of the source host.
- `role_bootstrap_rsyncd__source_filesystem_path`: The path on the source host containing the files to be synchronized.
- `role_bootstrap_rsyncd__remote_host`: The hostname or IP address of the remote host.
- `role_bootstrap_rsyncd__remote_filesystem_path`: The path on the remote host where files will be synchronized.

### Configuring SELinux

If SELinux is in enforcing mode, the role will create a local policy to allow `rsync` operations and enable the `rsync_full_access` boolean. This ensures that `rsync` can operate without being blocked by SELinux policies.

## Dependencies

- **Ansible**: The role requires Ansible 2.9 or later.
- **OS Family**: The role is primarily tested on Red Hat Enterprise Linux (RHEL) and CentOS distributions, but it should work on other Linux distributions with minor adjustments.

## Best Practices

1. **Backup Configuration Files**: Always ensure that the `rsyncd.conf` file is backed up before making changes to prevent data loss.
2. **SELinux Management**: When SELinux is in enforcing mode, carefully manage SELinux policies to avoid unintended disruptions.
3. **User Permissions**: Ensure that the user running the Ansible playbook has the necessary permissions to install packages and modify system files.

## Molecule Tests

This role does not currently include Molecule tests. Consider adding Molecule scenarios to ensure the role behaves as expected across different environments.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_rsyncd/defaults/main.yml)
- [tasks/execute_sync.yml](../../roles/bootstrap_rsyncd/tasks/execute_sync.yml)
- [tasks/main.yml](../../roles/bootstrap_rsyncd/tasks/main.yml)
- [tasks/rsync_cleanup.yml](../../roles/bootstrap_rsyncd/tasks/rsync_cleanup.yml)
- [tasks/rsync_listener.yml](../../roles/bootstrap_rsyncd/tasks/rsync_listener.yml)
- [tasks/rsync_prep.yml](../../roles/bootstrap_rsyncd/tasks/rsync_prep.yml)

---

This documentation provides a comprehensive overview of the `bootstrap_rsyncd` role, including its purpose, variables, usage, dependencies, best practices, and backlinks to the source code.