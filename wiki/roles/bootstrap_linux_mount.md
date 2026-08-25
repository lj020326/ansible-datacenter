---
title: Bootstrap Linux Mount Role Documentation
role: bootstrap_linux_mount
category: Ansible Roles
type: Configuration Management
---

## Summary

The `bootstrap_linux_mount` role is designed to manage filesystem mounts on Linux systems. It allows users to define custom mount points, configure swap files, and ensure that these configurations are properly reflected in the `/etc/fstab` file. The role supports various distributions and provides flexibility in managing both permanent and temporary mounts.

## Variables

| Variable Name                          | Default Value                                                                 | Description                                                                                                                                                                                                 |
|----------------------------------------|-------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_linux_mount__list`          | `[]`                                                                          | A list of mount points to be configured. Each item should include `name`, `src`, and `fstype`. Additional options like `options`, `dump`, and `passno` can also be specified.                                      |
| `bootstrap_linux_mount__state`         | `mounted`                                                                     | The desired state for the mounts (`mounted`, `unmounted`).                                                                                                                                                  |
| `bootstrap_linux_mount__fstab`         | `/etc/fstab`                                                                  | Path to the fstab file where mount points will be added or modified.                                                                                                                                        |
| `bootstrap_linux_mount__backup_fstab`  | `true`                                                                        | Whether to create a backup of the existing `/etc/fstab` before making any changes.                                                                                                                        |
| `bootstrap_linux_mount__disable_swap`  | `false`                                                                       | If set to `true`, swap file configuration will be skipped.                                                                                                                                                  |
| `bootstrap_linux_mount__swap_disk`     | `{ file: '/swap.img', size: '4G' }`                                          | Configuration for the swap file, including the path and size.                                                                                                                                             |
| `bootstrap_linux_mount__systemd_service_config` | `{}`                                                                      | A dictionary to configure systemd services related to mounts (not used in the provided tasks).                                                                                                                |
| `bootstrap_linux_mount__list__tmpdir`  | `[ { name: "/tmp", src: "tmpfs", fstype: "tmpfs", options: "defaults,nosuid,nodev,noexec,mode=1777" } ]` | A default list of mount points that can be overridden or extended by the `bootstrap_linux_mount__list` variable.                                                                                           |

## Usage

To use the `bootstrap_linux_mount` role, include it in your playbook and define the necessary variables as needed. Here is an example:

```yaml
- name: Configure mounts on Linux systems
  hosts: all
  roles:
    - role: bootstrap_linux_mount
      vars:
        bootstrap_linux_mount__list:
          - name: "/mnt/data"
            src: "/dev/sdb1"
            fstype: "ext4"
            options: "defaults,noatime"
            dump: 0
            passno: 2
```

In this example, a new mount point `/mnt/data` is configured with the specified source device and filesystem type.

## Dependencies

This role does not have any external dependencies. It relies on standard Ansible modules available in the `ansible.posix` collection for managing mounts.

## Best Practices

- **Backup Fstab**: Always ensure that `bootstrap_linux_mount__backup_fstab` is set to `true` to prevent accidental data loss due to incorrect fstab modifications.
- **Swap Configuration**: If you do not need a swap file, explicitly disable it by setting `bootstrap_linux_mount__disable_swap: true`.
- **Custom Mounts**: Use the `bootstrap_linux_mount__list` variable to define all custom mount points. This ensures that your configuration is centralized and easy to manage.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_linux_mount/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_linux_mount/tasks/main.yml)