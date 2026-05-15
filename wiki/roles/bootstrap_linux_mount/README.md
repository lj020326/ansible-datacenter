```markdown
---
title: bootstrap_linux_mount Role Documentation
original_path: roles/bootstrap_linux_mount/README.md
category: Ansible Roles
tags: [ansible, role, linux, mount]
---

# bootstrap_linux_mount Role

An Ansible role for mounting devices.

## Role Variables

```yaml
# List of dictionaries holding all devices that need to be mounted.
bootstrap_linux_mount__list:
  - name: /                         # NO default
    src: /dev/mapper/root           # NO default
    fstype: ext4                    # NO default
    opts: noatime,errors=remount-ro # Default: omit (written to fstab as "defaults")
    state: present                  # Default: "mounted"
    dump: 0                         # Default: omit (written to fstab as "0")
    passno: 1                       # Default: omit (written to fstab as "0")
    fstab: /etc/fstab               # Default: "/etc/fstab"
```

## Example Playbook

```yaml
- hosts: servers
  roles:
    - { role: bootstrap_linux_mount, become: true }
```

## Backlinks

- [Ansible Roles Documentation](../README.md)
```

This Markdown document is now standardized for GitHub rendering with clear structure, proper headings, and an added "Backlinks" section. The YAML frontmatter includes a title, original path, category, and tags for better organization and searchability.