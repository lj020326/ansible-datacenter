---
title: "bootstrap_linux_mount Role Documentation"
role: bootstrap_linux_mount
category: Ansible Roles
type: Technical Documentation
tags: ansible, role, linux, mount, fstab
---

## Summary

The `bootstrap_linux_mount` Ansible role is designed to manage and configure filesystem mounts on Linux systems. It allows users to define custom mount points, specify their source devices or filesystem types, and ensure they are correctly added to the `/etc/fstab` file. The role supports conditional mounting based on the filesystem type and provides options for backing up the existing `fstab` before making changes.

## Variables

| Variable Name                         | Default Value                                                                 | Description                                                                                                                                                                                                 |
|---------------------------------------|-------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_linux_mount__list`         | `[]`                                                                          | A list of dictionaries, each representing a mount point with keys like `name`, `src`, `fstype`, and optional `options`, `dump`, `passno`, `fstab`, and `state`.                                                                 |
| `bootstrap_linux_mount__state`        | `mounted`                                                                     | The desired state for the mounts. Can be `mounted`, `unmounted`, or `present` (for adding to `/etc/fstab`).                                                                                                    |
| `bootstrap_linux_mount__fstab`        | `/etc/fstab`                                                                  | Path to the fstab file where mount points will be added.                                                                                                                                                      |
| `bootstrap_linux_mount__backup_fstab`   | `true`                                                                        | Whether to back up the existing fstab file before making changes.                                                                                                                                             |
| `bootstrap_linux_mount__systemd_service_config` | `{}`                                                                    | A dictionary for configuring systemd services related to mounts (not currently used in this role).                                                                                                            |
| `bootstrap_linux_mount__list__tmpdir` | `- name: "/tmp"<br>- src: "tmpfs"<br>- fstype: "tmpfs"<br>- options: "defaults,nosuid,nodev,noexec,mode=1777"` | A default example entry in the list of mounts, specifically configuring `/tmp` as a `tmpfs` with specific mount options.                                                                                      |

## Usage

To use this role, include it in your playbook and define the `bootstrap_linux_mount__list` variable to specify the desired mount points. Here is an example:

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
```

This example will mount `/dev/sdb1` at `/mnt/data` with the specified filesystem type and options.

## Dependencies

- No external dependencies are required for this role.
- The role utilizes Ansible's built-in modules such as `mount`, `include_vars`, `debug`, and `set_fact`.

## Tags

- **bootstrap_linux_mount**: This tag can be used to run only tasks related to the `bootstrap_linux_mount` role.

Example of running with tags:

```bash
ansible-playbook -i inventory playbook.yml --tags bootstrap_linux_mount
```

## Best Practices

- Always back up your `/etc/fstab` file before making changes, especially when automating mount configurations.
- Ensure that the specified devices and filesystem types are correct to avoid system instability.
- Use specific tags to target only the tasks related to this role during playbook execution.

## Molecule Tests

This role does not currently include Molecule tests. However, it is recommended to write and run tests to ensure the role functions as expected across different Linux distributions and versions.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_linux_mount/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_linux_mount/tasks/main.yml)