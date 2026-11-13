---
title: "Bootstrap Linux User Role"
role: bootstrap_linux_user
category: System
type: Role
tags: [ansible, role, bootstrap_linux_user]
---

# Bootstrap Linux User Role

## Summary

The `bootstrap_linux_user` role is designed to manage user accounts on Linux systems. It provides a flexible and comprehensive way to create, update, and manage user accounts, including setting up SSH keys, managing group memberships, and handling user processes.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_linux_user__admin_sudo_groups` | `{ "Debian": "sudo", "Ubuntu": "sudo", "CentOS": "wheel" }` | A dictionary mapping Linux distributions to their default admin sudo groups. |
| `bootstrap_linux_user__admin_sudo_group` | `{{ bootstrap_linux_user__admin_sudo_groups[ansible_facts['distribution']] }}` | The sudo group for admin users, determined based on the distribution. |
| `bootstrap_linux_user__stop_user_processes` | `false` | Whether to stop user processes when removing a user. |
| `bootstrap_linux_user__admin_username` | `administrator` | The username for the admin user. |
| `bootstrap_linux_user__admin_ssh_auth_key` | `changeme` | The SSH authentication key for the admin user. |
| `bootstrap_linux_user__admin_user` | `{ "name": "{{ bootstrap_linux_user__admin_username }}", "generate_ssh_key": false, "system": true, "shell": "/bin/bash" }` | A dictionary containing the configuration for the admin user. |
| `bootstrap_linux_user__list` | `[ "{{ bootstrap_linux_user__admin_user }}" ]` | A list of users to be managed by the role. |
| `bootstrap_linux_user__hash_seed` | `sldkfjlkenwq4tm;24togk34t` | A seed value for password hashing. |
| `bootstrap_linux_user__update_password` | `always` | When to update the user passwords. |
| `bootstrap_linux_user__credentials` | `{}` | A dictionary for storing user credentials. |

## Usage

To use the `bootstrap_linux_user` role, include it in your playbook and define the necessary variables. Here is an example playbook:

```yaml
---
- hosts: all
  roles:
    - role: bootstrap_linux_user
      vars:
        bootstrap_linux_user__list:
          - name: john
            groups: sudo
            shell: /bin/bash
          - name: jane
            groups: sudo, docker
            shell: /bin/zsh
```

## Dependencies

This role does not have any external dependencies. It uses standard Ansible modules to manage users and groups.

## Best Practices

- Always review the default variables and adjust them according to your security policies.
- Ensure that the SSH keys are properly managed and secured.
- Regularly update the role to benefit from the latest features and security improvements.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_linux_user/defaults/main.yml)
- [tasks/init-vars.yml](../../roles/bootstrap_linux_user/tasks/init-vars.yml)
- [tasks/main.yml](../../roles/bootstrap_linux_user/tasks/main.yml)
- [tasks/stop-user-processes.yml](../../roles/bootstrap_linux_user/tasks/stop-user-processes.yml)