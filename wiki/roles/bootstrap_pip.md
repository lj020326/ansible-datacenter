---
title: Bootstrap Pip Role Documentation
role: bootstrap_pip
category: Ansible Roles
type: Configuration Management
tags: ansible, pip, virtualenv, python

## Summary
The `bootstrap_pip` role is designed to ensure that Python's package manager, `pip`, and its associated libraries are installed and configured correctly on a target system. It supports the installation of specific versions of `pip`, setting up virtual environments, and managing environment variables for consistent behavior across different systems.

## Variables

| Variable Name                                    | Default Value                                                                                         | Description                                                                                                                                                                                                 |
|--------------------------------------------------|-------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_pip__python_executable`               | `"{{ ansible_python_interpreter }}"`                                                                  | The Python interpreter to use. Defaults to the one detected by Ansible.                                                                                                                                     |
| `bootstrap_pip__pip_executable`                  | `pip3`                                                                                                | The pip executable to use. Defaults to `pip3`.                                                                                                                                                              |
| `bootstrap_pip__pip_version`                     | `latest`                                                                                              | The version of pip to install. Can be set to a specific version or `latest`.                                                                                                                              |
| `bootstrap_pip__env_force_rebuild`               | `false`                                                                                               | Whether to force the rebuild of virtual environments.                                                                                                                                                       |
| `bootstrap_pip__env_list__default`               | `[]`                                                                                                  | A default list of environments to manage. Can be overridden by user-defined lists.                                                                                                                          |
| `bootstrap_pip__packages`                        | `[]`                                                                                                  | A list of system packages required for pip and its dependencies.                                                                                                                                            |
| `bootstrap_pip__venv_environment_vars`           | `{ SETUPTOOLS_USE_DISTUTILS: "{{ 'stdlib' if (ansible_facts['python_version'] | default('3.10')) is version('3.12', '<') else 'local' }}", LANG: en_US.UTF-8, LC_ALL: en_US.UTF-8 }` | Environment variables to set for virtual environments.                                                                                                                                                    |
| `bootstrap_pip__environment_ignore_root_user_action` | `{ PIP_ROOT_USER_ACTION: ignore, LANG: en_US.UTF-8, LC_ALL: en_US.UTF-8 }`                          | Environment variables to ensure pip does not prompt when run as root.                                                                                                                                       |
| `bootstrap_pip__lib_state`                       | `present`                                                                                             | The state of the libraries (e.g., present).                                                                                                                                                                 |
| `bootstrap_pip__lib_priority_default`            | `100`                                                                                                 | Default priority for libraries if not specified.                                                                                                                                                            |
| `bootstrap_pip__libs_default`                    | `[setuptools, pyyaml, jinja2, cryptography, pyopenssl, requests, netaddr, passlib, jsondiff]`           | A default list of Python libraries to install. Can be overridden by user-defined lists.                                                                                                                     |
| `bootstrap_pip__tmp`                             | `/tmp`                                                                                                | Temporary directory for downloading and running the get-pip script.                                                                                                                                         |
| `bootstrap_pip__get_pip_url`                     | `https://bootstrap.pypa.io/get-pip.py`                                                                | URL to download the get-pip script from.                                                                                                                                                                    |
| `bootstrap_pip__virtualenv_command`              | `"{{ __bootstrap_pip__python_interpreter }} -m venv"`                                                   | Command to create a virtual environment. Defaults to using the detected Python interpreter with the `-m venv` module.                                                                                       |
| `bootstrap_pip__system_pip_upgrade_enabled`      | `true`                                                                                                | Whether to upgrade system pip if it is already installed.                                                                                                                                                   |
| `bootstrap_pip__system_pip_install_libs_allowed` | `false`                                                                                               | Whether to allow the installation of libraries via the system package manager (e.g., apt, yum).                                                                                                               |

## Usage

To use this role in your Ansible playbook, include it and define any necessary variables. Here is an example:

```yaml
- hosts: all
  roles:
    - role: bootstrap_pip
      vars:
        bootstrap_pip__pip_version: "21.3.1"
        bootstrap_pip__packages:
          - python3-pip
          - build-essential
        bootstrap_pip__libs:
          - name: requests
            priority: 50
          - cryptography
```

## Dependencies

This role does not have any external dependencies beyond the standard Ansible modules and Python interpreter.

## Best Practices

1. **Specify Versions**: Always specify a version for `pip` to avoid unexpected behavior due to breaking changes in newer versions.
2. **Use Virtual Environments**: Leverage virtual environments to manage dependencies specific to your projects, avoiding conflicts with system-wide packages.
3. **Environment Variables**: Set necessary environment variables to ensure consistent behavior across different systems and users.

## Molecule Tests

This role does not include Molecule tests at this time.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_pip/defaults/main.yml)
- [tasks/get-pip-version.yml](../../roles/bootstrap_pip/tasks/get-pip-version.yml)
- [tasks/init-vars.yml](../../roles/bootstrap_pip/tasks/init-vars.yml)
- [tasks/install-pip-libs.yml](../../roles/bootstrap_pip/tasks/install-pip-libs.yml)
- [tasks/main.yml](../../roles/bootstrap_pip/tasks/main.yml)
- [tasks/run-get-pip.yml](../../roles/bootstrap_pip/tasks/run-get-pip.yml)