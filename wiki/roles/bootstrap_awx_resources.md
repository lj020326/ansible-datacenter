---
title: "Bootstrap AWX Resources Role"
role: bootstrap_awx_resources
category: AWX
type: role
tags: [ansible, role, bootstrap_awx_resources]
---

# Bootstrap AWX Resources Role

The `bootstrap_awx_resources` role is designed to automate the setup and management of AWX resources. This role provides a structured way to create and configure organizations, credentials, inventories, execution environments, projects, job templates, teams, and roles within AWX. It also supports the removal of these resources when needed.

## Variables

| Variable Name                       | Default Value | Description                                                                 |
|-------------------------------------|---------------|-----------------------------------------------------------------------------|
| `bootstrap_awx_resources__state`    | `present`     | The desired state of the AWX resources (`present` or `absent`).              |
| `bootstrap_awx_resources__config`   | `{}`          | A dictionary containing the configuration for AWX resources.                 |

## Usage

To use the `bootstrap_awx_resources` role, include it in your playbook and provide the necessary configuration in the `bootstrap_awx_resources__config` variable. Here is an example:

```yaml
---
- hosts: localhost
  roles:
    - role: bootstrap_awx_resources
      vars:
        bootstrap_awx_resources__config:
          organizations:
            - name: "Example Org"
              description: "An example organization"
          credentials:
            - name: "Example Credential"
              organization: "Example Org"
              credential_type: "Source Control"
              inputs:
                username: "user"
                password: "pass"
          inventories:
            - name: "Example Inventory"
              organization: "Example Org"
          execution_environments:
            - name: "Example EE"
              image: "quay.io/example/ee:latest"
```

## Dependencies

This role depends on the `awx.awx` collection, which provides the necessary modules to interact with AWX. Ensure that the collection is installed in your Ansible environment:

```bash
ansible-galaxy collection install awx.awx
```

## Best Practices

- **Configuration Management**: Keep your AWX configuration in version control to ensure reproducibility and consistency.
- **Modularity**: Use this role to manage different parts of your AWX setup modularly. For example, you can have separate playbooks for managing organizations, credentials, and inventories.
- **State Management**: Use the `bootstrap_awx_resources__state` variable to control whether resources should be created (`present`) or removed (`absent`).
- **Documentation**: Document your AWX configuration and the purpose of each resource to maintain clarity and facilitate onboarding of new team members.
- **Testing**: Test your AWX configuration in a development environment before applying it to production to avoid unintended disruptions.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_awx_resources/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_awx_resources/tasks/main.yml)
- [tasks/create-tower-config.yml](../../roles/bootstrap_awx_resources/tasks/create-tower-config.yml)
- [tasks/remove-tower-config.yml](../../roles/bootstrap_awx_resources/tasks/remove-tower-config.yml)