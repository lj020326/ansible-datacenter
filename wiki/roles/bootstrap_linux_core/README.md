```markdown
---
title: Linux Bootstrap Role Documentation
original_path: roles/bootstrap_linux_core/README.md
category: Ansible Roles
tags: [linux, bootstrap, ansible, centos, ubuntu]
---

# Linux Bootstrap Role

This role bootstraps a Linux node (CentOS/Ubuntu) by performing two main steps:
1. Copying an SSH key and disabling root password login.
2. Configuring the system.

## Requirements

- A CentOS instance with root SSH access using a password.
- An account with sudo privileges will be created, and root user login will be disabled.
- The role sets the hostname of the host using a DNS query, requiring that the inventory hostname resolves to a single IPv4 address.

## Role Variables

| Variable Name                                      | Description                                                                                         | Default Value                                    |
|----------------------------------------------------|-----------------------------------------------------------------------------------------------------|--------------------------------------------------|
| `bootstrap_linux_core__ansible_username`           | The name of the admin account.                                                                      | `deploy`                                         |
| `bootstrap_linux_core__ansible_authorized_public_sshkey` | The path to the SSH key to be added for the admin user.                                             | `~/.ssh/id_rsa.pub`                              |
| `bootstrap_linux_core__default_path`               | The default path to be set.                                                                         | `/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin` |
| `bootstrap_linux_core__ansible_ssh_allowed_ips`    | An array of IPs allowed to connect via SSH; ensure this includes your current IP or access will be lost after the role runs. | N/A                                              |

## Dependencies

- None

## Usage

### First Pass

Execute the playbook with the root user and the `bootstrap` tag:

**Inventory:**
```ini
[bootstrap]
somehost.somedomain.com ansible_ssh_pass=ched3bYg8Doiv6h
```

**Playbook:**
```yaml
- hosts: bootstrap
  remote_user: root
  gather_facts: false

  roles:
    - { role: bootstrap, bootstrap_operation: 'bootstrap' }
```

### Second Pass

Execute the playbook with the newly created admin user and the `configure` tag:

**Inventory:**
```ini
[somegroup]
somehost.somedomain.com
```

**Playbook:**
```yaml
- hosts: somegroup
  remote_user: deploy
  become: true
  gather_facts: false

  roles:
    - { role: bootstrap, bootstrap_operation: 'configure' }
```

## Backlinks

- [Ansible Roles Documentation](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html)
- [Linux System Administration](https://www.tldp.org/LDP/sag/html/index.html)

```

This improved Markdown document maintains the original content while adhering to clean, professional formatting standards suitable for GitHub rendering.