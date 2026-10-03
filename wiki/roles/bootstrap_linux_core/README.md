---
title: "Linux Bootstrap"
tags: ["Linux", "Bootstrap", "CentOS", "Ubuntu", "SSH", "Ansible"]
---

# Linux Bootstrap

This role will bootstrap a Linux (CentOS/Ubuntu) node.

It consists of two steps:
1. The first step will copy an SSH key and disable root password login.
2. The second step will configure the system.

## Requirements

- A CentOS instance with root SSH access with a password.
- An account with sudo privileges will be created, and the root user login will be disabled.
- The role will set the hostname of the host using a DNS query. For this, it is required that the inventory hostname resolves to a single IPv4 address.

## Role Variables

### Name of Admin Account

- `bootstrap_linux_core__ansible_username`: The name of the user admin account, default: `deploy`
- `bootstrap_linux_core__ansible_authorized_public_sshkey`: The path to the SSH key to be added for the admin user, default: `~/.ssh/id_rsa.pub`
- `bootstrap_linux_core__default_path`: The path to be set as default: `/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin`
- `bootstrap_linux_core__ansible_ssh_allowed_ips`: An array of IPs allowed to connect via SSH. Ensure this includes your current IP or access to the server will be impossible after this role has run.

## Dependencies

None

## Usage

### First Pass

You must first execute the playbook with the root user and the bootstrap tag, like so:

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
    - { role: bootstrap_linux_core, bootstrap_operation: 'bootstrap' }
```

### Second Pass

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
    - { role: bootstrap_linux_core, bootstrap_operation: 'configure' }
```

## Notes

- The `gather_facts: false` directive is used to speed up the playbook execution by skipping the facts gathering step, which is not needed for this role.
- This role is compatible with Ansible 2.9 and later.

## Idempotency

This role is idempotent, meaning it can be run multiple times without causing unintended side effects.

## Troubleshooting

If you lose SSH access after running this role, ensure that your IP address is included in the `bootstrap_linux_core__ansible_ssh_allowed_ips` variable.

## Backlinks

[List any related pages or backlinks here]