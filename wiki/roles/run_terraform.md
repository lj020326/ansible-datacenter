---
title: "Run Terraform Role"
role: run_terraform
category: Infrastructure as Code
type: Ansible Role
tags: terraform, ansible, iac
---

## Summary

The `run_terraform` role is designed to manage the lifecycle of Terraform projects within an Ansible playbook. It includes tasks for initializing a Terraform directory, configuring variables, applying changes, and destroying resources. This role ensures that Terraform operations are performed in a controlled and repeatable manner.

## Variables

| Variable Name                     | Default Value | Description                                                                 |
|-----------------------------------|---------------|-----------------------------------------------------------------------------|
| `role_run_terraform__playbook_dir`  | `{{ playbook_dir }}` | The directory where the Ansible playbook is located. This is used to locate the Terraform project path. |

## Usage

To use the `run_terraform` role, include it in your Ansible playbook and ensure that the necessary variables are set. Below is an example of how to integrate this role into a playbook:

```yaml
---
- name: Manage Terraform Infrastructure
  hosts: localhost
  gather_facts: no
  roles:
    - role: run_terraform
      vars:
        role_run_terraform__playbook_dir: /path/to/your/playbook
```

### Tasks Overview

1. **Initialization (`init.yml`)**: Initializes the Terraform directory to prepare it for further operations.
2. **Configuration (`config.yml`)**: Deletes any existing `variables.tf` file and generates a new one using a Jinja2 template.
3. **Apply (`apply.yml`)**: Applies the Terraform configuration, creating or updating resources as specified.
4. **Destroy (`destroy.yml`)**: Destroys all resources managed by the Terraform project.

## Dependencies

- `community.general.terraform`: This Ansible collection must be installed to use the `community.general.terraform` module. Install it using:
  ```bash
  ansible-galaxy collection install community.general
  ```

## Best Practices

- **Variable Management**: Always specify the `role_run_terraform__playbook_dir` variable to ensure that Terraform operates in the correct directory.
- **Idempotency**: The role is designed to be idempotent, meaning it can be run multiple times without causing unintended changes after the desired state has been achieved.
- **Security**: Ensure that sensitive information (e.g., API keys) is managed securely and not hard-coded into your Terraform configurations.

## Molecule Tests

This role does not currently include Molecule tests. Consider adding Molecule scenarios to validate the functionality of this role in different environments.

## Backlinks

- [tasks/apply.yml](../../roles/run_terraform/tasks/apply.yml)
- [tasks/config.yml](../../roles/run_terraform/tasks/config.yml)
- [tasks/destroy.yml](../../roles/run_terraform/tasks/destroy.yml)
- [tasks/init.yml](../../roles/run_terraform/tasks/init.yml)

---

This documentation provides a comprehensive overview of the `run_terraform` role, including its purpose, usage, dependencies, best practices, and backlinks to the source files.