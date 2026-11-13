---
title: "Bootstrap Linux Mount Role"
role: roles/bootstrap_linux_mount
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_linux_mount]
---

```yaml
---
title: Bootstrap Linux Mount Role
role: bootstrap_linux_mount
category: System Configuration
type: Role
summary: |
  The `bootstrap_linux_mount` role is designed to manage and configure mount points on Linux systems. It provides a flexible way to define and mount various filesystems, including tmpfs, and manage swap files. This role is particularly useful for setting up consistent mount configurations across multiple servers.

variables: |
  | Variable Name                          | Default Value                                                                 | Description                                                                                                                                                       |
  |----------------------------------------|-------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------|
  | bootstrap_linux_mount__list            | `[]`                                                                           | List of mount points to be configured.                                                                                                                        |
  | bootstrap_linux_mount__state           | `mounted`                                                                       | Desired state of the mount points.                                                                                                                            |
  | bootstrap_linux_mount__fstab           | `/etc/fstab`                                                                     | Path to the fstab file where mount entries will be added.                                                                                                    |
  | bootstrap_linux_mount__backup_fstab    | `true`                                                                          | Whether to backup the fstab file before making changes.                                                                                                     |
  | bootstrap_linux_mount__disable_swap    | `false`                                                                         | Whether to disable swap file configuration.                                                                                                                   |
  | bootstrap_linux_mount__swap_disk       | `{ file: /swap.img, size: 4G }`                                                  | Configuration for the swap file, including file path and size.                                                                                               |
  | bootstrap_linux_mount__systemd_service_config | `{}`                                                                      | Configuration for systemd service related to mounts.                                                                                                         |
  | bootstrap_linux_mount__list__tmpdir     | `[{ name: "/tmp", src: "tmpfs", fstype: "tmpfs", options: "defaults,nosuid,nodev,noexec,mode=1777" }]` | Default configuration for tmpfs mount points.                                                                                                              |

usage: |
  To use the `bootstrap_linux_mount` role, include it in your playbook and define the mount points you want to configure in the `bootstrap_linux_mount__list` variable. Here is an example:

  ```yaml
  - hosts: all
    roles:
      - role: bootstrap_linux_mount
        vars:
          bootstrap_linux_mount__list:
            - name: "/mnt/data"
              src: "/dev/sda1"
              fstype: "ext4"
              options: "defaults"
            - name: "/mnt/nfs"
              src: "192.168.1.1:/export"
              fstype: "nfs"
              options: "defaults"
  ```

dependencies: |
  This role does not have any external dependencies. It relies on the standard Ansible modules and should work with any Linux distribution supported by Ansible.

best_practices: |
  - Always test the role in a development environment before applying it to production systems.
  - Use descriptive names and options for mount points to ensure clarity and maintainability.
  - Regularly review and update the mount configurations to reflect changes in the system's requirements.
  - Consider backing up the fstab file before making changes to prevent accidental data loss.

backlinks: |
  - [defaults/main.yml](../../roles/bootstrap_linux_mount/defaults/main.yml)
  - [tasks/main.yml](../../roles/bootstrap_linux_mount/tasks/main.yml)
```