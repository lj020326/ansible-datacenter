```markdown
---
title: Configure rsyncd Role Documentation
original_path: roles/bootstrap_rsyncd/README.md
category: Ansible Roles
tags: [rsync, ansible, configuration]
---

# Configure rsyncd Role

This role is used to synchronize filesystems between hosts using the rsync daemon. It removes the rsync configuration after executing the rsync command.

## Role Variables

- `local_filesystem_path`: The filesystem path on the source host that needs to be transferred.
- `remote_filesystem_path`: The filesystem path on the remote host.
- `remote_host`: The address of the remote host.
- `source_host`: The address of the source host.

## Dependencies

- Root privileges are required for this role.

## Example Playbook

```yaml
---
- name: Synchronize file systems
  hosts: localhost
  gather_facts: no
  become: true
  roles:
    - bootstrap_rsyncd_config
```

## Backlinks

- [Ansible Roles Documentation](../README.md)
```

This improved Markdown document includes a standardized YAML frontmatter, clear headings, and a "Backlinks" section for better navigation.