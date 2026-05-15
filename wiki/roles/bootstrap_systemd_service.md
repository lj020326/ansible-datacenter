---
title: Bootstrap Systemd Service Role Documentation
role: bootstrap_systemd_service
category: Ansible Roles
type: Configuration Management
tags: systemd, service, automation, ansible

---

## Summary

The `bootstrap_systemd_service` role is designed to automate the creation and management of systemd services on Linux systems. It handles the creation of necessary directories, writing default configuration files, generating systemd service unit files, and reloading the systemd manager configuration to ensure that the new or updated service is recognized by the system.

## Variables

| Variable Name                             | Default Value                                      | Description                                                                 |
|-------------------------------------------|----------------------------------------------------|-----------------------------------------------------------------------------|
| `bootstrap_systemd_service__name`         | *Not defined* (required)                         | The name of the systemd service to be created.                              |
| `bootstrap_systemd_service__Service_ExecStart` | *Not defined* (required)                       | The command to start the service, e.g., `/usr/bin/my-service`.              |
| `ansible_unit_test`                     | `false`                                            | Enables unit testing mode for the role.                                   |
| `ansible_unit_test_prefix_dir`            | `""`                                               | Prefix directory used during unit tests.                                    |
| `bootstrap_systemd_service__force_update` | `true`                                             | Forces an update of the systemd service file if it already exists.          |
| `bootstrap_systemd_service__root_dir`     | `"{{ ansible_unit_test_prefix_dir }}"`             | The root directory for the role, typically used during unit tests.        |
| `bootstrap_systemd_service__default_dir`  | `/etc/default`                                     | Directory where default configuration files for the service are stored.   |
| `bootstrap_systemd_service__systemd_dir`  | `/etc/systemd/system`                              | Directory where systemd service unit files are stored.                    |
| `bootstrap_systemd_service__envs`         | `[]`                                               | List of environment variables to be set for the service.                  |
| `bootstrap_systemd_service__Unit_Description` | `"{{ bootstrap_systemd_service__name }} Service"` | Description of the systemd service unit.                                  |
| `bootstrap_systemd_service__Service_Type` | `simple`                                           | Type of the service, e.g., simple, forking, oneshot, etc.                 |
| `bootstrap_systemd_service__Install_WantedBy` | `multi-user.target`                              | Target to which the service is installed, typically multi-user.target.    |
| `bootstrap_systemd_service__Restart`      | `false`                                            | Specifies whether the service should be restarted automatically.            |

## Usage

To use this role, you need to define at least the `bootstrap_systemd_service__name` and `bootstrap_systemd_service__Service_ExecStart` variables in your playbook or inventory.

### Example Playbook

```yaml
- name: Bootstrap a systemd service
  hosts: all
  roles:
    - role: bootstrap_systemd_service
      vars:
        bootstrap_systemd_service__name: my-service
        bootstrap_systemd_service__Service_ExecStart: /usr/bin/my-service
        bootstrap_systemd_service__envs:
          - MY_ENV_VAR=value1
          - ANOTHER_ENV_VAR=value2
```

## Dependencies

This role does not have any external dependencies.

## Best Practices

- Always define the `bootstrap_systemd_service__name` and `bootstrap_systemd_service__Service_ExecStart` variables to ensure the role functions correctly.
- Use the `bootstrap_systemd_service__envs` variable to pass environment variables to your service, ensuring that it has all necessary configuration.

## Molecule Tests

This role includes molecule tests to verify its functionality. To run the tests, navigate to the role directory and execute:

```bash
molecule test
```

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_systemd_service/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_systemd_service/tasks/main.yml)
- [handlers/main.yml](../../roles/bootstrap_systemd_service/handlers/main.yml)

---

This documentation provides a comprehensive overview of the `bootstrap_systemd_service` role, including its purpose, variables, usage, and best practices. For further details or troubleshooting, refer to the linked source files.