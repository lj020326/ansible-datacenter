---
title: "bootstrap_linux_mount Role Documentation"
role: bootstrap_linux_mount
category: Ansible Roles
type: Configuration Management
tags: linux, mount, fstab, swap, tmpfs
---

## Summary

The `bootstrap_linux_mount` role is designed to manage filesystem mounts on Linux systems. It allows users to define custom mount points and options via variables, ensuring they are correctly configured in the `/etc/fstab` file. Additionally, it provides functionality to disable system swap if required, which can be particularly useful for Kubernetes nodes.

## Variables

| Variable Name                           | Default Value                                      | Description                                                                 |
|-----------------------------------------|----------------------------------------------------|-----------------------------------------------------------------------------|
| `bootstrap_linux_mount__list`           | `[]`                                               | A list of dictionaries defining mount points and their properties.          |
| `bootstrap_linux_mount__state`          | `mounted`                                          | The desired state for the mounts (e.g., mounted, present).                  |
| `bootstrap_linux_mount__fstab`          | `/etc/fstab`                                       | Path to the fstab file where mount configurations will be written.        |
| `bootstrap_linux_mount__backup_fstab`   | `true`                                             | Whether to back up the existing fstab file before making changes.           |
| `bootstrap_linux_mount__disable_swap`   | `false`                                            | If set to true, disables system swap and removes swap entries from fstab.   |
| `bootstrap_linux_mount__systemd_service_config` | `{}`                                          | Configuration for systemd services related to mounts (not used in this role).|
| `bootstrap_linux_mount__list__tmpdir`   | `- name: "/tmp"<br>&nbsp;&nbsp;src: "tmpfs"<br>&nbsp;&nbsp;fstype: "tmpfs"<br>&nbsp;&nbsp;options: "defaults,nosuid,nodev,noexec,mode=1777"` | Default configuration for the `/tmp` directory using `tmpfs`.             |

## Usage

To use this role, include it in your playbook and define the necessary variables. Here is an example:

```yaml
- hosts: all
  roles:
    - role: bootstrap_linux_mount
      vars:
        bootstrap_linux_mount__list:
          - name: "/mnt/data"
            src: "/dev/sdb1"
            fstype: "ext4"
            options: "defaults,noatime"
            dump: "0"
            passno: "2"
        bootstrap_linux_mount__disable_swap: true
```

This example configures a mount point for `/mnt/data` and disables system swap.

## Dependencies

- No external dependencies are required for this role. However, it utilizes the `ansible.posix.mount` module, which is part of the Ansible POSIX collection.

## Best Practices

1. **Backup Fstab**: Always ensure that `bootstrap_linux_mount__backup_fstab` is set to `true` to prevent data loss in case of errors.
2. **Disable Swap for Kubernetes Nodes**: If deploying Kubernetes nodes, consider setting `bootstrap_linux_mount__disable_swap` to `true`.
3. **Custom Mount Options**: Use the `options`, `dump`, and `passno` parameters to fine-tune mount behavior according to your requirements.

## Molecule Tests

This role does not include Molecule tests at this time. However, it is recommended to write and run tests to ensure the role behaves as expected in different environments.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_linux_mount/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_linux_mount/tasks/main.yml)