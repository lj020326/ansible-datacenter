---
title: "Bootstrap systemd service Role"
role: bootstrap_systemd_service
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_systemd_service]
---

# Bootstrap systemd service Role

This Ansible role is designed to bootstrap a systemd service on a target system. It provides a flexible way to define and configure systemd services, including setting up the necessary directories, creating default configuration files, and ensuring the systemd service unit files are properly configured and reloaded.

## Variables

| Variable Name                              | Default Value                                                                 | Description                                                                                                                                                                                                                                                                                                                                                                                                 |
|--------------------------------------------|-------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `ansible_unit_test`                        | `false`                                                                       | Flag to enable unit testing mode.                                                                                                                                                                                                                                                                                                                                                                                               |
| `ansible_unit_test_prefix_dir`             | `""`                                                                          | Prefix directory for unit testing.                                                                                                                                                                                                                                                                                                                                                                                                   |
| `bootstrap_systemd_service__force_update`  | `true`                                                                        | Force update of the systemd service file.                                                                                                                                                                                                                                                                                                                                                                                                   |
| `bootstrap_systemd_service__root_dir`      | `{{ ansible_unit_test_prefix_dir }}`                                           | Root directory for the service configuration.                                                                                                                                                                                                                                                                                                                                                                                                   |
| `bootstrap_systemd_service__default_dir`   | `/etc/default`                                                                | Directory for default configuration files.                                                                                                                                                                                                                                                                                                                                                                                                                               |
| `bootstrap_systemd_service__systemd_dir`   | `/etc/systemd/system`                                                          | Directory for systemd service unit files.                                                                                                                                                                                                                                                                                                                                                                                                                               |
| `bootstrap_systemd_service__envs`          | `[]`                                                                          | List of environment variables to be set for the service.                                                                                                                                                                                                                                                                                                                                                                                                   |
| `bootstrap_systemd_service__unit_description` | `{{ bootstrap_systemd_service__name }} Service` | Description of the systemd service unit.                                                                                                                                                                                                                                                                                                                                                                                                                               |
| `bootstrap_systemd_service__service_type`  | `simple`                                                                      | Type of the systemd service.                                                                                                                                                                                                                                                                                                                                                                                                                               |
| `bootstrap_systemd_service__install_wantedby` | `multi-user.target`                                                           | Target for the systemd service to be installed with.                                                                                                                                                                                                                                                                                                                                                                                                   |
| `bootstrap_systemd_service__restart`       | `false`                                                                       | Flag to restart the service after configuration.                                                                                                                                                                                                                                                                                                                                                                                                   |
| `bootstrap_systemd_service__name`          | (required)                                                                      | Name of the systemd service.                                                                                                                                                                                                                                                                                                                                                                                                                               |
| `bootstrap_systemd_service__service_execstart` | (required)                                                                      | Command to execute the service.                                                                                                                                                                                                                                                                                                                                                                                                                               |

## Usage

To use this role, include it in your playbook and provide the necessary variables. Below is an example of how to use this role:

```yaml
- hosts: all
  roles:
    - role: bootstrap_systemd_service
      vars:
        bootstrap_systemd_service__name: my_service
        bootstrap_systemd_service__service_execstart: /usr/bin/my_service
        bootstrap_systemd_service__envs:
          - "ENV_VAR1=value1"
          - "ENV_VAR2=value2"
```

## Dependencies

This role does not have any external dependencies. It relies solely on the standard Ansible modules.

## Best Practices

- Ensure that the `bootstrap_systemd_service__name` and `bootstrap_systemd_service__service_execstart` variables are defined.
- Use the `bootstrap_systemd_service__envs` variable to set any necessary environment variables for the service.
- Consider setting `bootstrap_systemd_service__force_update` to `false` if you do not want to force the update of the systemd service file.
- Use the `bootstrap_systemd_service__restart` variable to control whether the service should be restarted after configuration.
- Verify that the systemd service unit file is properly configured and reload the systemd daemon if necessary.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_systemd_service/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_systemd_service/tasks/main.yml)
- [handlers/main.yml](../../roles/bootstrap_systemd_service/handlers/main.yml)