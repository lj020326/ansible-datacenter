---
title: "Run Terraform Role"
role: run_terraform
category: Roles
type: ansible-role
tags: [ansible, role, run_terraform]
---

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `playbook_dir` | Required | The directory where the playbook is located. This is used to reference the Terraform project path. |

## Usage

### Applying Terraform Configuration

To apply a Terraform configuration, include the `apply` task in your playbook:

```yaml
- hosts: localhost
  roles:
    - role: run_terraform
      tasks_from: apply
```

### Configuring Terraform Variables

To configure Terraform variables, include the `config` task in your playbook. Ensure you have a `variables.j2` template file in your role directory:

```yaml
- hosts: localhost
  roles:
    - role: run_terraform
      tasks_from: config
```

### Initializing Terraform

To initialize the Terraform directory, include the `init` task in your playbook:

```yaml
- hosts: localhost
  roles:
    - role: run_terraform
      tasks_from: init
```

### Destroying Terraform Configuration

To destroy the Terraform configuration, include the `destroy` task in your playbook:

```yaml
- hosts: localhost
  roles:
    - role: run_terraform
      tasks_from: destroy
```

## Dependencies

This role requires the `community.general` collection for the `terraform` module. Ensure you have it installed:

```bash
ansible-galaxy collection install community.general
```

## Best Practices

1. **Template Management**: Ensure your `variables.j2` template is correctly configured and located in the appropriate directory.
2. **Terraform State**: Manage Terraform state files carefully, especially in a team environment, to avoid conflicts.
3. **Environment Isolation**: Use separate directories or workspaces for different environments (e.g., development, staging, production) to avoid unintended changes.

## Backlinks

- [tasks/apply.yml](../../roles/run_terraform/tasks/apply.yml) - Tasks for applying Terraform configuration
- [tasks/config.yml](../../roles/run_terraform/tasks/config.yml) - Tasks for configuring Terraform variables
- [tasks/destroy.yml](../../roles/run_terraform/tasks/destroy.yml) - Tasks for destroying Terraform configuration
- [tasks/init.yml](../../roles/run_terraform/tasks/init.yml) - Tasks for initializing Terraform

## Troubleshooting

- If you encounter issues with Terraform initialization, ensure that the Terraform project path is correctly set in the `playbook_dir` variable.
- Check the Ansible logs for any error messages related to the Terraform module.
- Verify that the `community.general` collection is installed and up-to-date.

## Examples

### Example 1: Basic Terraform Apply

```yaml
- hosts: localhost
  roles:
    - role: run_terraform
      tasks_from: apply
```

### Example 2: Terraform with Variables

```yaml
- hosts: localhost
  roles:
    - role: run_terraform
      tasks_from: config
```

### Example 3: Terraform Initialization

```yaml
- hosts: localhost
  roles:
    - role: run_terraform
      tasks_from: init
```

### Example 4: Terraform Destruction

```yaml
- hosts: localhost
  roles:
    - role: run_terraform
      tasks_from: destroy
```