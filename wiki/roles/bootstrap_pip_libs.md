---
title: Bootstrap Pip Libraries Role Documentation
role: bootstrap_pip_libs
category: Ansible Roles
type: Configuration Management
tags: ansible, role, pip, virtualenv
---

## Summary

The `bootstrap_pip_libs` Ansible role is designed to set up and install essential Python libraries using `pip`. It ensures that the `virtualenv` package is installed for creating isolated Python environments. Additionally, it installs a list of required Python libraries specified by the user in the `required_pip_libs` variable.

## Variables

| Variable Name         | Default Value | Description                                                                 |
|-----------------------|---------------|-----------------------------------------------------------------------------|
| `required_pip_libs`   | `['yum']`     | A list of Python libraries that need to be installed using pip.             |

## Usage

To use the `bootstrap_pip_libs` role, include it in your Ansible playbook and optionally specify the `required_pip_libs` variable with a list of desired Python packages.

### Example Playbook

```yaml
---
- hosts: all
  roles:
    - role: bootstrap_pip_libs
      required_pip_libs:
        - requests
        - flask
```

## Dependencies

This role does not have any external dependencies. However, it relies on the `ansible.builtin.pip` module to manage Python packages.

## Best Practices

- **Specify Required Libraries**: Always specify the `required_pip_libs` variable with a list of libraries that are necessary for your project.
- **Use Virtual Environments**: Although this role installs `virtualenv`, consider using it to create isolated environments for your projects to avoid conflicts between dependencies.

## Molecule Tests

This role does not include Molecule tests at the moment. Consider adding them to ensure the role behaves as expected across different operating systems and configurations.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_pip_libs/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_pip_libs/tasks/main.yml)