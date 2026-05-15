---
title: "AWX Configuration Bootstrap Role"
role: bootstrap_awx_config
category: Ansible Roles
type: Automation
tags: awx, automation-controller, ansible, configuration

---

## Summary

The `bootstrap_awx_config` role is designed to automate the initial setup and configuration of an AWX (Ansible Tower) or Automation Controller instance. This includes cleaning up default configurations, setting up organizations, users, inventories, projects, job templates, and schedules. The role ensures that the AWX instance is ready for production use by customizing it according to specified parameters.

## Variables

| Variable Name                              | Default Value                                      | Description                                                                 |
|--------------------------------------------|----------------------------------------------------|-----------------------------------------------------------------------------|
| `bootstrap_awx_config__force_update`       | `false`                                            | Forces the update of existing configurations.                               |
| `bootstrap_awx_config__org_name`           | `ExampleOrg`                                       | The name of the organization to be created in AWX/Automation Controller.    |
| `bootstrap_awx_config__awx_url`            | `panel.example.org`                                | The URL of the AWX/Automation Controller instance.                          |
| `bootstrap_awx_config__admin_username`     | `admin`                                            | The username for the admin account in AWX/Automation Controller.            |
| `bootstrap_awx_config__admin_password`     | `<< strong-password >>`                            | The password for the admin account in AWX/Automation Controller.            |
| `bootstrap_awx_config__secret_key`         | `<< strong-password >>`                            | A secret key used by AWX/Automation Controller for cryptographic operations.  |
| `bootstrap_awx_config__pg_password`        | `<< strong-password >>`                            | The password for the PostgreSQL database used by AWX/Automation Controller. |
| `bootstrap_awx_config__update_schedule_start` | `20210101T000000`                                 | The start time for scheduled updates in iCal format.                        |
| `bootstrap_awx_config__update_schedule_frequency` | `HOURLY`                                        | The frequency of scheduled updates (e.g., HOURLY, DAILY).                   |
| `bootstrap_awx_config__update_schedule_interval` | `1`                                              | The interval for the scheduled updates based on the specified frequency.    |
| `bootstrap_awx_config__deploy_source`      | `https://github.com/spantaleev/matrix-docker-ansible-deploy.git` | The source URL of the deployment repository.                                |
| `bootstrap_awx_config__deploy_branch`      | `master`                                           | The branch to be used from the deployment repository.                       |

## Usage

To use this role, include it in your playbook and provide any necessary variables as needed. Here is an example playbook:

```yaml
---
- name: Bootstrap AWX Configuration
  hosts: localhost
  gather_facts: false
  vars:
    bootstrap_awx_config__org_name: MyOrg
    bootstrap_awx_config__awx_url: mypanel.example.org
    bootstrap_awx_config__admin_password: myStrongPassword123!
    bootstrap_awx_config__secret_key: anotherStrongKey456!
    bootstrap_awx_config__pg_password: yetAnotherStrongPass789!
  roles:
    - role: bootstrap_awx_config
```

## Dependencies

This role depends on the `awx.awx` collection, which provides modules for managing AWX/Automation Controller. Ensure that this collection is installed in your Ansible environment:

```bash
ansible-galaxy collection install awx.awx
```

## Best Practices

- **Security**: Always use strong passwords and secret keys for sensitive variables.
- **Customization**: Modify the default values to suit your specific requirements.
- **Testing**: Use Molecule tests to verify the role's functionality in a controlled environment.

## Molecule Tests

This role includes Molecule tests to ensure its correctness. To run the tests, execute:

```bash
molecule test
```

Ensure that you have Docker installed and running on your system for the tests to work properly.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_awx_config/defaults/main.yml)
- [tasks/cleanup_defaults.yml](../../roles/bootstrap_awx_config/tasks/cleanup_defaults.yml)
- [tasks/main.yml](../../roles/bootstrap_awx_config/tasks/main.yml)
- [tasks/master_token.yml](../../roles/bootstrap_awx_config/tasks/master_token.yml)
- [tasks/projects_awx.yml](../../roles/bootstrap_awx_config/tasks/projects_awx.yml)
- [tasks/schedules_awx.yml](../../roles/bootstrap_awx_config/tasks/schedules_awx.yml)
- [tasks/templates_awx.yml](../../roles/bootstrap_awx_config/tasks/templates_awx.yml)
- [tasks/users_org_inventory_awx.yml](../../roles/bootstrap_awx_config/tasks/users_org_inventory_awx.yml)