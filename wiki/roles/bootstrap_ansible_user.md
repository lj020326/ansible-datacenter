---
title: Bootstrap Ansible User Role Documentation
role: bootstrap_ansible_user
category: Roles
type: Ansible Role
tags: ansible, role, user-management, automation
---

## Summary

The `bootstrap_ansible_user` role is designed to automate the setup of an Ansible management user on target Linux systems. This includes creating a dedicated system user for running Ansible playbooks and optionally setting up a Python virtual environment for managing dependencies.

## Variables

| Variable Name                             | Default Value                                      | Description                                                                 |
|-------------------------------------------|----------------------------------------------------|-----------------------------------------------------------------------------|
| `bootstrap_ansible_user__os_local_admin_user` | `root`                                             | The local admin user on the target system used to perform initial setup.    |
| `bootstrap_ansible_user__os_local_admin_password` | `changeme!`                                      | Password for the local admin user (used only if password authentication is required). |
| `bootstrap_ansible_user__os_python_interpreter` | `python3`                                        | The Python interpreter to use on the target system.                         |
| `bootstrap_ansible_user__ansible_username`      | `ansible`                                          | The username for the Ansible management user to be created.                 |
| `bootstrap_ansible_user__ansible_user`        | `{ name: "{{ bootstrap_ansible_user__ansible_username }}", generate_ssh_key: false, system: true, shell: /bin/bash }` | A dictionary containing details of the Ansible management user.           |

## Usage

To use this role in your playbook, include it as follows:

```yaml
- hosts: all
  become: yes
  roles:
    - role: bootstrap_ansible_user
      vars:
        bootstrap_ansible_user__os_local_admin_password: "securepassword"
```

### Example Playbook

Here is an example playbook that demonstrates how to use the `bootstrap_ansible_user` role:

```yaml
---
- name: Bootstrap Ansible User on Target Systems
  hosts: webservers
  become: yes
  roles:
    - role: bootstrap_ansible_user
      vars:
        bootstrap_ansible_user__os_local_admin_password: "securepassword"
```

## Dependencies

This role depends on the following roles:

- `bootstrap_linux_user`: Used to create and configure the Ansible management user.
- `bootstrap_pip`: Used to set up a Python virtual environment for managing dependencies.

## Best Practices

1. **Security**: Ensure that the password for the local admin user is strong and not hard-coded in your playbooks. Consider using Ansible Vault or environment variables for sensitive information.
2. **SSH Keys**: It's recommended to use SSH keys instead of passwords for authentication. Set `generate_ssh_key` to `true` in the `bootstrap_ansible_user__ansible_user` dictionary if you want the role to generate an SSH key pair for the Ansible user.
3. **Python Interpreter**: Verify that the specified Python interpreter (`python3`) is installed on your target systems.

## Molecule Tests

This role includes Molecule tests to ensure its functionality. To run the tests, navigate to the role directory and execute:

```bash
molecule test
```

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_ansible_user/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_ansible_user/tasks/main.yml)