---
title: "Bootstrap Pip Libraries Role"
role: bootstrap_pip_libs
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_pip_libs]
---

# Bootstrap Pip Libraries Role

This Ansible role installs common Python libraries using `pip` to ensure that essential Python packages are available on the target system. It is particularly useful for setting up development or CI/CD environments where specific Python libraries are required.

## Variables

| Variable Name           | Default Value | Description                                                                 |
|-------------------------|---------------|-----------------------------------------------------------------------------|
| `required_pip_libs`     | `['yum']`     | List of Python libraries to be installed using `pip`.                       |

## Usage

To use this role, include it in your playbook and optionally override the `required_pip_libs` variable to specify the Python libraries you need.

```yaml
- hosts: all
  roles:
    - role: bootstrap_pip_libs
      vars:
        required_pip_libs:
          - pip
          - virtualenv
          - setuptools
```

## Default Behavior

When the `required_pip_libs` variable is not set, the role will install the default list of libraries (`['yum']`).

## Idempotency

This role is designed to be idempotent. It will only install the specified Python libraries if they are not already installed on the target system.

## Error Handling

If `pip` is not installed or accessible on the target system, the role will fail. Ensure that `pip` is installed and accessible before running this role.

## Testing

This role can be tested using Ansible's testing frameworks, such as Molecule. Test scenarios should include:
- Installing the default list of libraries
- Installing a custom list of libraries
- Running the role multiple times to verify idempotency

## Dependencies

This role does not have any external dependencies. It uses the `ansible.builtin.pip` module, which is included in Ansible by default.

## Best Practices

- Ensure that the target system has `pip` installed and accessible.
- Customize the `required_pip_libs` variable to include only the libraries that are necessary for your project to avoid unnecessary installations.
- Use virtual environments to manage Python dependencies in isolation from the system Python installation.

## Related Documentation

- [Ansible pip module documentation](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/pip_module.html)
- [Molecule documentation](https://molecule.readthedocs.io/en/latest/)

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_pip_libs/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_pip_libs/tasks/main.yml)