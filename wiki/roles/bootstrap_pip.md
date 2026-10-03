---
title: "Bootstrap Pip Role"
role: roles/bootstrap_pip
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_pip]
---

# Bootstrap Pip Role Documentation

## Overview

The `bootstrap_pip` Ansible role is designed to bootstrap the Python package manager `pip` on a target system. It provides a flexible and robust way to install and configure `pip`, including handling virtual environments, managing Python packages, and ensuring compatibility across different operating systems and Python versions.

## Variables

The following table lists the key variables used in this role, along with their default values and descriptions:

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `__bootstrap_pip__python_executable_default` | `{{ ansible_python_interpreter }}` | Default Python executable path |
| `__bootstrap_pip__pip_executable_default` | `pip3` | Default pip executable name |
| `__bootstrap_pip__pip_version_default` | `latest` | Default pip version to install |
| `bootstrap_pip__pip_version` | (not set) | Specific pip version to install (overrides default) |
| `bootstrap_pip__env_force_rebuild` | `false` | Force rebuild of virtual environments |
| `bootstrap_pip__fix_broken_sitecustomize` | `false` | Fix broken `sitecustomize.py` files |
| `__bootstrap_pip__packages` | `[]` | List of system packages to install |
| `bootstrap_pip__venv_environment_vars` | `{}` | Environment variables for virtual environments |
| `bootstrap_pip__lib_state` | `latest` | Default state for Python libraries |
| `bootstrap_pip__lib_priority_default` | `100` | Default priority for Python libraries |
| `__bootstrap_pip__libs_default` | `[setuptools, pyyaml, jinja2, cryptography, pyopenssl, requests, netaddr, passlib, jsondiff]` | Default list of Python libraries to install |
| `__bootstrap_pip__tmp` | `/tmp` | Temporary directory for downloads |
| `__bootstrap_pip__get_pip_url` | `https://bootstrap.pypa.io/get-pip.py` | URL to download `get-pip.py` script |

## Usage

To use the `bootstrap_pip` role, include it in your playbook and configure the desired variables:

```yaml
- hosts: all
  roles:
    - role: bootstrap_pip
      vars:
        bootstrap_pip__pip_version: "21.0.1"
        bootstrap_pip__libs:
          - name: setuptools
            priority: 1
          - pyyaml
          - jinja2
```

You can also specify a custom Python executable and virtual environment settings:

```yaml
- hosts: all
  roles:
    - role: bootstrap_pip
      vars:
        bootstrap_pip__python_executable: "/usr/bin/python3.8"
        bootstrap_pip__venv_path: "/opt/myproject/venv"
        bootstrap_pip__venv_environment_vars:
          VIRTUAL_ENV: "/opt/myproject/venv"
```

## Dependencies

This role does not have any external dependencies. It uses standard Ansible modules and should work out-of-the-box with any system that has Ansible installed. However, it's recommended to use Ansible 2.9 or later for optimal compatibility.

## Best Practices

1. **Virtual Environments**: Always use virtual environments to isolate dependencies for different projects. This prevents conflicts between packages required by different projects.
2. **Package Management**: Keep system packages up-to-date to avoid compatibility issues. Regularly update your package lists and upgrade packages.
3. **Security**: Regularly update `pip` and Python libraries to their latest versions to benefit from security patches. Use the `latest` state for libraries to ensure they're kept up-to-date.
4. **Configuration**: Customize the role variables to match your project's requirements. For example, specify a custom Python executable if you need a specific Python version.
5. **Testing**: Always test the role in a staging environment before deploying to production to ensure it works as expected with your specific configuration.

## Requirements

- Python 3.x must be installed on the target system
- Ansible 2.9 or later is recommended

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_pip/defaults/main.yml)
- [tasks/fix-broken-sitecustomize.yml](../../roles/bootstrap_pip/tasks/fix-broken-sitecustomize.yml)
- [tasks/get-pip-version.yml](../../roles/bootstrap_pip/tasks/get-pip-version.yml)
- [tasks/init-vars.yml](../../roles/bootstrap_pip/tasks/init-vars.yml)
- [tasks/install-pip-libs.yml](../../roles/bootstrap_pip/tasks/install-pip-libs.yml)
- [tasks/main.yml](../../roles/bootstrap_pip/tasks/main.yml)
- [tasks/run-get-pip.yml](../../roles/bootstrap_pip/tasks/run-get-pip.yml)

This documentation provides a comprehensive overview of the `bootstrap_pip` role, its variables, usage, dependencies, and best practices. By following these guidelines, you can effectively use this role to manage `pip` and Python packages on your target systems.