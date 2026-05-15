```markdown
---
title: bootstrap_linux_upgrade Role Documentation
original_path: roles/bootstrap_linux_upgrade/README.md
category: Ansible Roles
tags: [ansible, role, linux, upgrade]
---

# bootstrap_linux_upgrade

An Ansible role for upgrading the base OS.

## Requirements

None.

## Role Variables

| Variable       | Description            | Default | Required |
|----------------|------------------------|---------|----------|
| reboot_default | Run reboot by default. | `true`  | No       |

## Dependencies

None.

## Example Playbook

Here's how to use the role in a playbook:

```yaml
- hosts: all
  become: true
  become_method: sudo
  tasks:
    - name: Include upgrade
      ansible.builtin.include_role:
        name: bootstrap_linux_upgrade
```

## References

- [cisagov/ansible-role-upgrade](https://github.com/cisagov/ansible-role-upgrade)

## Backlinks

- [Ansible Roles Documentation](../README.md)
```

This improved version maintains the original content while adhering to clean, professional Markdown standards suitable for GitHub rendering. It includes a YAML frontmatter with additional metadata and ensures clear structure and proper headings.