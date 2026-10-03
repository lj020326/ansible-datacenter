---
title: "Bootstrap AWX Config Role"
role: bootstrap_awx_config
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_awx_config]
---

# Bootstrap AWX Config Role

The `bootstrap_awx_config` Ansible role is designed to configure and initialize an AWX/Automation Controller instance. This role sets up the necessary organizations, users, projects, job templates, and schedules to facilitate automated workflows within AWX. It ensures that the AWX instance is ready for use by creating a clean environment and setting up essential configurations.

## Variables

| Variable Name                              | Default Value                           | Description                                                                 |
|--------------------------------------------|-----------------------------------------|-----------------------------------------------------------------------------|
| `bootstrap_awx_config__force_update`       | `false`                                 | Force update of AWX configurations.                                         |
| `bootstrap_awx_config__org_name`           | `'ExampleOrg'`                          | Name of the organization to be created in AWX.                              |
| `bootstrap_awx_config__awx_url`            | `'panel.example.org'`                   | URL of the AWX/Automation Controller instance.                              |
| `bootstrap_awx_config__admin_username`     | `'admin'`                               | Username of the AWX admin.                                                  |
| `bootstrap_awx_config__admin_password`     | `'<< strong-password >>'`               | Password of the AWX admin.                                                  |
| `bootstrap_awx_config__secret_key`         | `'<< strong-password >>'`               | Secret key for AWX.                                                         |
| `bootstrap_awx_config__pg_password`        | `'<< strong-password >>'`               | Password for the PostgreSQL database used by AWX.                            |
| `bootstrap_awx_config__update_schedule_start` | `'20210101T000000'`                  | Start time for the update schedule.                                         |
| `bootstrap_awx_config__update_schedule_frequency` | `'HOURLY'`                    | Frequency of the update schedule.                                           |
| `bootstrap_awx_config__update_schedule_interval` | `1`                         | Interval for the update schedule.                                           |
| `bootstrap_awx_config__deploy_source`      | `'https://github.com/spantaleev/matrix-docker-ansible-deploy.git'` | Source repository for deployment.                                           |
| `bootstrap_awx_config__deploy_branch`      | `'master'`                              | Branch of the source repository to use for deployment.                      |

## Usage

To use the `bootstrap_awx_config` role, include it in your playbook and set the necessary variables. Here is an example playbook:

```yaml
---
- hosts: localhost
  roles:
    - role: bootstrap_awx_config
      vars:
        bootstrap_awx_config__org_name: "MyOrg"
        bootstrap_awx_config__awx_url: "https://awx.example.com"
        bootstrap_awx_config__admin_username: "admin"
        bootstrap_awx_config__admin_password: "strong-password"
        bootstrap_awx_config__secret_key: "strong-password"
        bootstrap_awx_config__pg_password: "strong-password"
        bootstrap_awx_config__deploy_source: "https://github.com/myorg/my-repo.git"
        bootstrap_awx_config__deploy_branch: "main"
```

## Dependencies

This role requires the `awx.awx` collection to be installed. You can install it using the following command:

```bash
ansible-galaxy collection install awx.awx
```

## Best Practices

1. **Security**: Ensure that the passwords and secret keys are stored securely and not hardcoded in the playbook.
2. **Backup**: Always take a backup of the AWX configuration before applying any changes.
3. **Testing**: Test the role in a development environment before applying it to production.
4. **Documentation**: Document the changes made by the role for future reference.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_awx_config/defaults/main.yml)
- [tasks/cleanup_defaults.yml](../../roles/bootstrap_awx_config/tasks/cleanup_defaults.yml)
- [tasks/main.yml](../../roles/bootstrap_awx_config/tasks/main.yml)
- [tasks/master_token.yml](../../roles/bootstrap_awx_config/tasks/master_token.yml)
- [tasks/projects_awx.yml](../../roles/bootstrap_awx_config/tasks/projects_awx.yml)
- [tasks/schedules_awx.yml](../../roles/bootstrap_awx_config/tasks/schedules_awx.yml)
- [tasks/templates_awx.yml](../../roles/bootstrap_awx_config/tasks/templates_awx.yml)
- [tasks/users_org_inventory_awx.yml](../../roles/bootstrap_awx_config/tasks/users_org_inventory_awx.yml)