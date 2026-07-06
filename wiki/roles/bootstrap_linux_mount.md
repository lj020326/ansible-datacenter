---
title: Bootstrap Linux Mount Role Documentation
role: bootstrap_linux_mount
category: Ansible Roles
type: Technical Documentation
---

## Summary

The `bootstrap_linux_mount` role is designed to manage and configure mount points on Linux systems using Ansible. It allows users to define custom mounts, handle swap file configurations, and ensure that these settings are correctly applied and reflected in the `/etc/fstab` file.

## Variables

| Variable Name                          | Default Value                                                                                     | Description                                                                                                                                                                                                 |
|----------------------------------------|---------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_linux_mount__list`          | `[]`                                                                                            | A list of dictionaries defining mount points to be configured. Each dictionary should include keys like `name`, `src`, `fstype`, and optionally `options`, `dump`, `passno`, and `state`.               |
| `bootstrap_linux_mount__state`         | `mounted`                                                                                         | The desired state for the mounts (e.g., `mounted`, `unmounted`).                                                                                                                                              |
| `bootstrap_linux_mount__fstab`         | `/etc/fstab`                                                                                    | Path to the fstab file where mount points will be configured.                                                                                                                                                 |
| `bootstrap_linux_mount__backup_fstab`  | `true`                                                                                          | Whether to back up the existing fstab file before making changes.                                                                                                                                             |
| `bootstrap_linux_mount__disable_swap`  | `false`                                                                                         | If set to true, swap configuration will be skipped.                                                                                                                                                           |
| `bootstrap_linux_mount__swap_disk`     | `{ file: /swap.img, size: 4G }`                                                                   | Configuration for the swap disk, including the file path and size.                                                                                                                                          |
| `bootstrap_linux_mount__systemd_service_config` | `{}`                                                                                        | A dictionary to configure systemd services related to mounts (not used in the provided snippet).                                                                                                                |
| `bootstrap_linux_mount__list__tmpdir`  | `- name: "/tmp"<br>- src: "tmpfs"<br>- fstype: "tmpfs"<br>- options: "defaults,nosuid,nodev,noexec,mode=1777"` | A predefined list of mount points that can be included in the `bootstrap_linux_mount__list`.                                                                                                                |

## Usage

To use this role, include it in your playbook and define the necessary variables. Here is an example:

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

## Dependencies

This role does not have any external dependencies. However, it relies on the `ansible.posix.mount` module, which is part of the Ansible POSIX collection.

## Best Practices

- **Backup Fstab**: Always ensure that `bootstrap_linux_mount__backup_fstab` is set to `true` to prevent accidental data loss.
- **Swap Configuration**: If you do not require swap space, set `bootstrap_linux_mount__disable_swap` to `true`.
- **Custom Mounts**: Define all custom mounts in the `bootstrap_linux_mount__list` variable. Use the predefined list as a reference for formatting.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_linux_mount/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_linux_mount/tasks/main.yml)