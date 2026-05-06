---
title: Bootstrap Ansible User Role Documentation
role: bootstrap_ansible_user
category: Roles
type: Configuration Management
tags: ansible, user-management, automation
---

## Summary

The `bootstrap_ansible_user` role is designed to create and configure a dedicated Ansible management user on target Linux systems. This role ensures that the specified user has the necessary permissions and configurations to facilitate automated infrastructure management tasks.

## Variables

| Variable Name                             | Default Value                              | Description                                                                 |
|-------------------------------------------|--------------------------------------------|-----------------------------------------------------------------------------|
| `bootstrap_ansible_user__os_local_admin_user` | `root`                                     | The local administrative user used for initial SSH access.                  |
| `bootstrap_ansible_user__os_local_admin_password` | `changeme!`                                | The password for the local administrative user (used only if necessary).    |
| `bootstrap_ansible_user__os_python_interpreter` | `python3`                                  | The Python interpreter to use on the target system.                         |
| `bootstrap_ansible_user__ansible_username`  | `ansible`                                    | The username of the Ansible management user to be created.                  |
| `bootstrap_ansible_user__ansible_user`    | `{ name: "{{ bootstrap_ansible_user__ansible_username }}", generate_ssh_key: false, system: true, shell: /bin/bash }` | A dictionary defining properties of the Ansible management user.          |

## Usage

To use this role, include it in your playbook and optionally override any default variables as needed. Here is an example:

```yaml
- name: Bootstrap Ansible User on Target Hosts
  hosts: all
  become: yes
  roles:
    - role: bootstrap_ansible_user
      vars:
        bootstrap_ansible_user__ansible_username: my_ansible_user
```

## Dependencies

This role depends on the `bootstrap_linux_user` role to perform the actual user creation and configuration. Ensure that this dependency is available in your Ansible environment.

## Tags

No specific tags are defined within this role. However, you can apply custom tags when running the playbook if needed.

## Best Practices

- **Security**: Avoid using plain text passwords for `bootstrap_ansible_user__os_local_admin_password`. Consider using Ansible Vault or other secure methods to handle sensitive information.
- **Customization**: Modify the `bootstrap_ansible_user__ansible_user` dictionary to suit your specific requirements, such as enabling SSH key generation or changing the user shell.

## Molecule Tests

This role does not include Molecule tests. Ensure that you manually test the role in a safe environment before deploying it to production systems.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_ansible_user/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_ansible_user/tasks/main.yml)