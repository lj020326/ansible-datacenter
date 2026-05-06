---
title: "bootstrap_awx_config Role Documentation"
role: bootstrap_awx_config
category: Ansible Roles
type: Configuration
tags: awx, automation-controller, ansible, configuration

---

## Summary

The `bootstrap_awx_config` role is designed to automate the initial setup and configuration of an AWX (Ansible Automation Controller) instance. This includes cleaning up default configurations, setting up organizations, users, inventories, projects, job templates, and schedules. The role ensures that the AWX instance is configured according to best practices and can be easily customized through variables.

## Variables

| Variable Name                         | Default Value                                      | Description                                                                 |
|---------------------------------------|--------------------------------------------------|-----------------------------------------------------------------------------|
| `bootstrap_awx_force_update`          | `false`                                          | Forces an update of existing configurations.                                  |
| `bootstrap_awx_org_name`              | `ExampleOrg`                                     | The name of the organization to be created in AWX.                            |
| `bootstrap_awx_awx_url`               | `panel.example.org`                              | The URL where the AWX instance is accessible.                                 |
| `bootstrap_awx_admin_username`        | `admin`                                          | The username for the admin account in AWX.                                    |
| `bootstrap_awx_admin_password`        | `<< strong-password >>`                          | The password for the admin account in AWX. **Ensure this is a strong password**.|
| `bootstrap_awx_secret_key`            | `<< strong-password >>`                          | A secret key used by AWX for cryptographic signing. **Ensure this is a strong password**. |
| `bootstrap_awx_pg_password`           | `<< strong-password >>`                          | The PostgreSQL database password for AWX. **Ensure this is a strong password**. |
| `bootstrap_awx_update_schedule_start` | `20210101T000000`                                | The start time for the update schedule in iCal format.                        |
| `bootstrap_awx_update_schedule_frequency` | `HOURLY`                                       | The frequency of the update schedule (e.g., HOURLY, DAILY).                   |
| `bootstrap_awx_update_schedule_interval` | `1`                                             | The interval for the update schedule.                                         |
| `bootstrap_awx_deploy_source`         | `https://github.com/spantaleev/matrix-docker-ansible-deploy.git` | The URL of the Git repository containing playbooks and other resources.     |
| `bootstrap_awx_deploy_branch`         | `master`                                         | The branch to be used from the deploy source repository.                      |

## Usage

To use this role, include it in your playbook as follows:

```yaml
- hosts: awx_servers
  roles:
    - role: bootstrap_awx_config
      vars:
        bootstrap_awx_org_name: MyOrg
        bootstrap_awx_awx_url: myawx.example.com
        bootstrap_awx_admin_password: 'my_secure_password'
        bootstrap_awx_secret_key: 'another_secure_key'
        bootstrap_awx_pg_password: 'yet_another_secure_key'
```

Ensure that the `bootstrap_awx_admin_password`, `bootstrap_awx_secret_key`, and `bootstrap_awx_pg_password` are set to strong, unique passwords.

## Dependencies

- The role requires the `awx.awx` collection. Ensure this is installed using:
  ```bash
  ansible-galaxy collection install awx.awx
  ```
- Kubernetes (`kubectl`) must be installed on the control node and configured to access the AWX instance.
- The AWX instance should already be deployed and accessible at `bootstrap_awx_awx_url`.

## Tags

This role uses tags to allow selective execution of tasks:

- `cleanup`: Cleans up default configurations in AWX.
- `users_org_inventory`: Configures users, organizations, and inventories.
- `projects`: Sets up projects in AWX.
- `templates`: Creates job templates in AWX.
- `schedules`: Configures schedules for job templates.

Example usage with tags:
```bash
ansible-playbook -i inventory playbook.yml --tags "cleanup,users_org_inventory"
```

## Best Practices

- **Security**: Ensure all passwords and secret keys are stored securely. Consider using Ansible Vault to encrypt sensitive variables.
- **Customization**: Customize the `bootstrap_awx_deploy_source` and `bootstrap_awx_deploy_branch` to point to your own repository containing playbooks and resources.
- **Testing**: Use Molecule tests (if available) to verify the role's functionality in different environments.

## Molecule Tests

This role does not include Molecule tests. However, it is recommended to create and run Molecule tests to ensure the role behaves as expected across various scenarios.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_awx_config/defaults/main.yml)
- [tasks/cleanup_defaults.yml](../../roles/bootstrap_awx_config/tasks/cleanup_defaults.yml)
- [tasks/main.yml](../../roles/bootstrap_awx_config/tasks/main.yml)
- [tasks/master_token.yml](../../roles/bootstrap_awx_config/tasks/master_token.yml)
- [tasks/projects_awx.yml](../../roles/bootstrap_awx_config/tasks/projects_awx.yml)
- [tasks/schedules_awx.yml](../../roles/bootstrap_awx_config/tasks/schedules_awx.yml)
- [tasks/templates_awx.yml](../../roles/bootstrap_awx_config/tasks/templates_awx.yml)
- [tasks/users_org_inventory_awx.yml](../../roles/bootstrap_awx_config/tasks/users_org_inventory_awx.yml)

---

This documentation provides a comprehensive overview of the `bootstrap_awx_config` role, including its purpose, variables, usage, dependencies, tags, best practices, and backlinks to the source files.