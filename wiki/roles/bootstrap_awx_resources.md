---
title: Bootstrap AWX Resources Role Documentation
role: bootstrap_awx_resources
category: Ansible Roles
type: Configuration Management
tags: awx, tower, automation, ansible
---

## Summary

The `bootstrap_awx_resources` role is designed to automate the creation and management of various resources within an AWX (Ansible Tower) instance. This includes organizations, execution environments, credentials, inventories, projects, job templates, teams, roles, and SAML team-organization mappings. The role can be configured to either create (`present`) or remove (`absent`) these resources based on the provided configuration.

## Variables

| Variable Name                           | Default Value           | Description                                                                 |
|-----------------------------------------|-------------------------|-----------------------------------------------------------------------------|
| `bootstrap_awx_resources__state`        | `present`               | Determines whether to create (`present`) or remove (`absent`) AWX resources.  |
| `bootstrap_awx_resources__config`       | `{}`                    | A dictionary containing the configuration details for various AWX resources.    |

## Usage

To use this role, you need to define the `bootstrap_awx_resources__config` variable with the necessary configurations for the resources you want to manage. Here is an example playbook that demonstrates how to use this role:

```yaml
---
- name: Bootstrap AWX Resources
  hosts: localhost
  gather_facts: no
  roles:
    - role: bootstrap_awx_resources
      vars:
        bootstrap_awx_resources__state: present
        bootstrap_awx_resources__config:
          organizations:
            - name: DevOps
              description: Development and Operations Team
              credentials:
                - name: AWS_Creds
                  kind: aws
                  inputs:
                    username: my-aws-user
                    password: my-aws-password
              inventories:
                - name: dev-inventory
          execution_environments:
            - name: ee-dev
              image: quay.io/ansible/awx-operator:latest
```

## Dependencies

This role depends on the `awx.awx` collection, which provides modules for interacting with AWX/Tower. Ensure that this collection is installed before running the role:

```bash
ansible-galaxy collection install awx.awx
```

## Tags

- `create-tower-config`: Used to create or update resources.
- `remove-tower-config`: Used to remove resources.

To run tasks with specific tags, use the `--tags` option with `ansible-playbook`:

```bash
ansible-playbook -i inventory playbook.yml --tags=create-tower-config
```

## Best Practices

1. **Configuration Management**: Ensure that all configurations are version-controlled and stored in a secure location.
2. **State Management**: Use the `bootstrap_awx_resources__state` variable to manage the lifecycle of resources effectively.
3. **Security**: Avoid hardcoding sensitive information like passwords or tokens directly in playbooks. Use Ansible Vault or environment variables instead.

## Molecule Tests

This role includes Molecule tests to verify its functionality. To run the tests, navigate to the role directory and execute:

```bash
molecule test
```

Ensure that you have Molecule installed along with any required dependencies for testing.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_awx_resources/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_awx_resources/tasks/main.yml)
- [tasks/create-tower-config.yml](../../roles/bootstrap_awx_resources/tasks/create-tower-config.yml)
- [tasks/remove-tower-config.yml](../../roles/bootstrap_awx_resources/tasks/remove-tower-config.yml)

---

This documentation provides a comprehensive overview of the `bootstrap_awx_resources` role, including its purpose, configuration options, usage instructions, and best practices. For more detailed information, refer to the linked source files.