---
title: Bootstrap Linux User Role Documentation
role: bootstrap_linux_user
category: Ansible Roles
type: Configuration Management
tags: linux, user-management, ansible-role
---

## Summary

The `bootstrap_linux_user` role is designed to manage and configure users on Linux systems. It allows for the creation of system users, setting their shell, groups, SSH keys, and more. The role also includes functionality to stop processes for specified users if required.

## Variables

| Variable Name                              | Default Value                                                                                     | Description                                                                                                                                                                                                 |
|--------------------------------------------|---------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_linux_user__admin_sudo_groups`  | `{ Debian: sudo, Ubuntu: sudo, CentOS: wheel }`                                                   | A dictionary mapping Linux distributions to their default sudo groups.                                                                                                                                        |
| `bootstrap_linux_user__admin_sudo_group`   | `"{{ bootstrap_linux_user__admin_sudo_groups[ansible_facts['distribution']] }}"`                    | The sudo group for the admin user based on the detected distribution.                                                                                                                                         |
| `bootstrap_linux_user__stop_user_processes`| `false`                                                                                           | A boolean flag to determine whether to stop processes for users being managed by this role.                                                                                                                   |
| `bootstrap_linux_user__admin_username`     | `administrator`                                                                                   | The username of the admin user to be created or configured.                                                                                                                                                 |
| `bootstrap_linux_user__admin_ssh_auth_key` | `changeme`                                                                                        | The SSH public key for the admin user. This should be replaced with a valid SSH key.                                                                                                                        |
| `bootstrap_linux_user__admin_user`         | `{ name: "{{ bootstrap_linux_user__admin_username }}", generate_ssh_key: false, system: true, shell: /bin/bash }` | A dictionary containing details of the admin user to be created or configured.                                                                                                                              |
| `bootstrap_linux_user__list`               | `[ "{{ bootstrap_linux_user__admin_user }}" ]`                                                      | A list of users to be managed by this role. Each user can be specified as a string (username) or a dictionary with detailed configuration options.                                                             |
| `bootstrap_linux_user__hash_seed`          | `sldkfjlkenwq4tm;24togk34t`                                                                       | A seed used for password hashing. This should be kept secret and unique to your environment.                                                                                                                |
| `bootstrap_linux_user__update_password`    | `always`                                                                                          | Controls when passwords are updated. Options include `always`, `on_create`, or `never`.                                                                                                                     |
| `bootstrap_linux_user__credentials`        | `{}`                                                                                              | A dictionary for storing user credentials, if needed. This is currently not used in the provided tasks but can be extended for future use cases.                                                              |

## Usage

To use this role, include it in your playbook and configure the variables as needed. Here's an example:

```yaml
- hosts: all
  roles:
    - role: bootstrap_linux_user
      vars:
        bootstrap_linux_user__admin_username: my_admin
        bootstrap_linux_user__admin_ssh_auth_key: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC..."
```

## Dependencies

This role does not have any external dependencies. It relies on standard Ansible modules available in the Ansible distribution.

## Tags

- `bootstrap-linux-user` - This tag can be used to run only tasks related to this role.
- `stop-processes` - This tag can be used to specifically target the task that stops user processes.

## Best Practices

1. **Security**: Always replace the default SSH key (`changeme`) with a valid public SSH key for secure access.
2. **Customization**: Customize the `bootstrap_linux_user__list` variable to include additional users and their configurations as needed.
3. **Testing**: Use Molecule tests (if available) to ensure the role behaves as expected in different environments.

## Molecule Tests

This role does not currently have Molecule tests included. Consider adding them for better testing coverage.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_linux_user/defaults/main.yml)
- [tasks/init-vars.yml](../../roles/bootstrap_linux_user/tasks/init-vars.yml)
- [tasks/main.yml](../../roles/bootstrap_linux_user/tasks/main.yml)
- [tasks/stop-user-processes.yml](../../roles/bootstrap_linux_user/tasks/stop-user-processes.yml)

---

This documentation provides a comprehensive overview of the `bootstrap_linux_user` role, including its purpose, configuration options, usage examples, and best practices.