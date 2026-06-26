---
title: Bootstrap Linux User Role Documentation
role: bootstrap_linux_user
category: Ansible Roles
type: Configuration Management
---

## Summary

The `bootstrap_linux_user` role is designed to automate the creation and management of user accounts on Linux systems. It handles tasks such as creating system users, setting up SSH keys, managing groups, and optionally stopping processes for specified users. This role ensures that all necessary configurations are applied consistently across different Linux distributions.

## Variables

| Variable Name                             | Default Value                                                                                       | Description                                                                                                                                                                                                 |
|-------------------------------------------|-----------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_linux_user__admin_sudo_groups` | `{ Debian: sudo, Ubuntu: sudo, CentOS: wheel }`                                                    | A dictionary mapping Linux distributions to their respective default sudo groups.                                                                                                                             |
| `bootstrap_linux_user__admin_sudo_group`  | `"{{ bootstrap_linux_user__admin_sudo_groups[ansible_facts['distribution']] }}"`                      | The sudo group for the admin user based on the detected distribution.                                                                                                                                       |
| `bootstrap_linux_user__stop_user_processes` | `false`                                                                                             | A boolean flag to determine whether to stop processes for users being managed by this role.                                                                                                                   |
| `bootstrap_linux_user__admin_username`      | `administrator`                                                                                     | The username of the admin user to be created or managed.                                                                                                                                                      |
| `bootstrap_linux_user__admin_ssh_auth_key`  | `changeme`                                                                                            | The SSH public key for the admin user. This should be replaced with a valid SSH key in production environments.                                                                                             |
| `bootstrap_linux_user__admin_user`          | `{ name: "{{ bootstrap_linux_user__admin_username }}", generate_ssh_key: false, system: true, shell: /bin/bash }` | A dictionary containing details about the admin user, such as username, whether to generate an SSH key, if it's a system user, and the default shell. |
| `bootstrap_linux_user__list`              | `[ "{{ bootstrap_linux_user__admin_user }}" ]`                                                        | A list of users to be managed by this role. Each user can be specified either as a string (username) or a dictionary with detailed attributes.     |
| `bootstrap_linux_user__hash_seed`         | `sldkfjlkenwq4tm;24togk34t`                                                                          | A seed used for password hashing to ensure consistent results across different runs.                                                                                                                          |
| `bootstrap_linux_user__update_password`   | `always`                                                                                            | Specifies when the user's password should be updated. Options include `always`, `on_create`, and `never`.                                                                                                    |
| `bootstrap_linux_user__credentials`       | `{}`                                                                                                | A dictionary to store credentials or other sensitive information related to users, if needed.                                                                                                                   |

## Usage

To use the `bootstrap_linux_user` role, you need to define the necessary variables in your playbook or inventory files and include the role in your playbook.

### Example Playbook

```yaml
---
- name: Bootstrap Linux Users
  hosts: all
  become: yes
  roles:
    - role: bootstrap_linux_user
      vars:
        bootstrap_linux_user__admin_username: my_admin
        bootstrap_linux_user__admin_ssh_auth_key: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC..."
        bootstrap_linux_user__list:
          - name: user1
            system: false
            shell: /bin/zsh
          - name: user2
            groups: sudo
```

### Example Inventory

```ini
[webservers]
web1.example.com
web2.example.com

[webservers:vars]
bootstrap_linux_user__admin_username=admin
bootstrap_linux_user__admin_ssh_auth_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC..."
```

## Dependencies

This role does not have any external dependencies. It relies solely on Ansible core modules.

## Best Practices

- **Security**: Always replace the default `bootstrap_linux_user__admin_ssh_auth_key` with a valid SSH public key.
- **Customization**: Use the `bootstrap_linux_user__list` variable to define additional users and their attributes as needed.
- **Testing**: Test the role in a staging environment before applying it to production systems to ensure that all configurations are applied correctly.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_linux_user/defaults/main.yml)
- [tasks/init-vars.yml](../../roles/bootstrap_linux_user/tasks/init-vars.yml)
- [tasks/main.yml](../../roles/bootstrap_linux_user/tasks/main.yml)
- [tasks/stop-user-processes.yml](../../roles/bootstrap_linux_user/tasks/stop-user-processes.yml)