---
title: "bootstrap_linux_mount Role"
original_path: roles/bootstrap_linux_mount/README.md
category: Ansible Roles
tags:
  - Ansible
  - Mounting
  - Linux
  - Devices
harvested_date: '2026-08-07T18:07:09.297058+00:00'
source_type: legacy_markdown
---

# bootstrap_linux_mount Role

An Ansible role for mounting devices on Linux systems. This role manages the mounting of filesystems by creating or updating entries in the `/etc/fstab` file and ensuring the specified mount state.

## Role Variables

The following is a list of variables used by this role:

| Variable | Description | Default |
|----------|-------------|---------|
| `bootstrap_linux_mount__list` | List of dictionaries holding all devices that need to be mounted. | `[]` |
| `name` | Mount point (e.g., `/`) | No default |
| `src` | Device or remote filesystem to be mounted (e.g., `/dev/mapper/root`) | No default |
| `fstype` | Filesystem type (e.g., `ext4`) | No default |
| `opts` | Mount options (e.g., `noatime,errors=remount-ro`) | `omit` (written to fstab as "defaults") |
| `state` | Desired state of the mount (`mounted` or `unmounted`) | `mounted` |
| `dump` | Used by the dump command to determine which filesystems need to be dumped | `omit` (written to fstab as "0") |
| `passno` | Used by fsck to determine the order in which filesystems are checked | `omit` (written to fstab as "0") |
| `fstab` | Path to the fstab file | `/etc/fstab` |

## Example Playbook

Here is an example playbook that uses the `bootstrap_linux_mount` role:

```yaml
- hosts: servers
  become: true
  vars:
    bootstrap_linux_mount__list:
      - name: /
        src: /dev/mapper/root
        fstype: ext4
        opts: noatime,errors=remount-ro
        state: mounted
  roles:
    - bootstrap_linux_mount
```

## Requirements

- Ansible 2.9 or higher
- Linux system with appropriate permissions to mount filesystems

## Author

OpenHands

## License

This project is licensed under the MIT License.

## Related Documentation

- [Ansible Mount Module Documentation](https://docs.ansible.com/ansible/latest/modules/mount_module.html)
- [Understanding the fstab File](https://www.linux.com/tutorials/how-resolve-issues-fstab-file/)

## Backlinks

(If applicable, list any backlinks to this documentation page)