---
title: Bootstrap FOG Role Documentation
role: bootstrap_fog
category: Ansible Roles
type: Installation and Configuration
tags: fogproject, ansible-role, automation

---

## Summary

The `bootstrap_fog` role is designed to automate the installation and updating of the Free Open Ghost (FOG) project on a target system. This role handles user creation, directory setup, cloning of the FOG repository from GitHub, and running the unattended installation script.

## Variables

| Variable Name         | Default Value  | Description                                                                 |
|-----------------------|----------------|-----------------------------------------------------------------------------|
| `fog_user`            | `fog`          | The username under which FOG will be installed.                             |
| `fog_branch`          | `master`       | The branch of the FOG project to clone from GitHub.                         |
| `fog_dhcp_server`     | `false`        | A flag indicating whether a DHCP server should be configured (not used in current tasks). |

## Usage

To use this role, include it in your playbook and optionally override any default variables as needed:

```yaml
- hosts: fog_servers
  roles:
    - role: bootstrap_fog
      vars:
        fog_user: customfoguser
        fog_branch: develop
```

### Example Playbook

Here is an example of how to use the `bootstrap_fog` role in a playbook:

```yaml
---
- name: Install and configure FOG on target servers
  hosts: fog_servers
  become: yes
  roles:
    - role: bootstrap_fog
      vars:
        fog_user: fogadmin
        fog_branch: latest_release
```

## Dependencies

This role has the following dependencies:

- `ansible.builtin.git` for cloning the FOG repository.
- `ansible.builtin.command` for running the installation script.
- `ansible.builtin.user` and `ansible.builtin.file` for user and directory management.
- `ansible.builtin.apt` (only if the target OS is Debian-based) to ensure `unattended-upgrades` is not installed.

## Tags

This role does not define any specific tags, but you can use the default Ansible tags such as `always`, `never`, or custom tags to control task execution.

## Best Practices

- Ensure that the target system has internet access to clone the FOG repository from GitHub.
- Verify that the specified user has sufficient permissions for installation and configuration tasks.
- Review the `temp_settings.j2` template file to ensure it contains all necessary configurations for your environment.

## Molecule Tests

This role does not include Molecule tests. However, you can create a test scenario using Molecule to validate the role's functionality in different environments.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_fog/defaults/main.yml)
- [tasks/install.yml](../../roles/bootstrap_fog/tasks/install.yml)
- [tasks/main.yml](../../roles/bootstrap_fog/tasks/main.yml)
- [tasks/update.yml](../../roles/bootstrap_fog/tasks/update.yml)

---

This documentation provides a comprehensive overview of the `bootstrap_fog` role, including its purpose, configuration options, usage examples, and best practices.