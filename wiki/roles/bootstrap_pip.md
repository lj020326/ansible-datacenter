---
title: Bootstrap Pip Role Documentation
role: bootstrap_pip
category: Ansible Roles
type: Configuration Management
tags: ansible, pip, virtualenv, python

## Summary

The `bootstrap_pip` role is designed to ensure that the Python package manager `pip` and its dependencies are installed and configured correctly on a target system. It supports both system-wide installations and virtual environments, allowing for flexible management of Python packages across different environments.

## Variables

| Variable Name                                    | Default Value                                                                                           | Description                                                                                                                                                                                                 |
|--------------------------------------------------|---------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_pip__python_executable`               | `{{ ansible_python_interpreter }}`                                                                      | The path to the Python interpreter to use. Defaults to the one detected by Ansible.                                                                                                                       |
| `bootstrap_pip__pip_executable`                  | `pip3`                                                                                                | The pip executable to use. Defaults to `pip3`.                                                                                                                                                              |
| `bootstrap_pip__pip_version`                     | `latest`                                                                                              | The version of pip to install. Can be set to a specific version or `latest`.                                                                                                                              |
| `bootstrap_pip__env_force_rebuild`               | `false`                                                                                               | Whether to force the rebuild of virtual environments.                                                                                                                                                       |
| `bootstrap_pip__fix_broken_sitecustomize`        | `false`                                                                                               | Whether to fix broken `sitecustomize.py` files that can interfere with Ansible operations.                                                                                                                  |
| `bootstrap_pip__env_list`                        | `[]`                                                                                                  | A list of virtual environments to manage. Each environment is a dictionary with keys like `name`, `virtualenv`, and `pip_version`.                                                                         |
| `bootstrap_pip__packages`                      | `[]`                                                                                                  | A list of system packages required for pip installation (e.g., `python3-dev`).                                                                                                                            |
| `bootstrap_pip__venv_environment_vars`           | `{ SETUPTOOLS_USE_DISTUTILS: 'stdlib' if python_version < 3.12 else 'local', LANG: en_US.UTF-8, LC_ALL: en_US.UTF-8 }` | Environment variables to set when creating virtual environments.                                                                                                                                          |
| `bootstrap_pip__environment_ignore_root_user_action` | `{ PIP_ROOT_USER_ACTION: ignore, LANG: en_US.UTF-8, LC_ALL: en_US.UTF-8 }`                         | Environment variables to prevent pip from running as root.                                                                                                                                                |
| `bootstrap_pip__lib_state`                     | `present`                                                                                             | The state of the libraries (`present`, `absent`).                                                                                                                                                           |
| `bootstrap_pip__libs`                          | `[setuptools, pyyaml, jinja2, cryptography, pyopenssl, requests, netaddr, passlib, jsondiff]`            | A list of Python libraries to install. Each library can be specified as a string or a dictionary with additional options like `priority`.                                                                     |
| `bootstrap_pip__tmp`                           | `/tmp`                                                                                                | Temporary directory for downloading and running the get-pip script.                                                                                                                                         |
| `bootstrap_pip__get_pip_url`                   | `https://bootstrap.pypa.io/get-pip.py`                                                                  | URL to download the get-pip script from.                                                                                                                                                                    |
| `bootstrap_pip__virtualenv_command`            | `{{ __bootstrap_pip__python_interpreter }} -m venv`                                                     | Command used to create virtual environments.                                                                                                                                                                |
| `bootstrap_pip__system_pip_upgrade_enabled`      | `true`                                                                                                | Whether to upgrade the system pip if it is already installed.                                                                                                                                             |
| `bootstrap_pip__system_pip_install_libs_allowed` | `false`                                                                                               | Whether to allow installation of libraries using the system pip.                                                                                                                                          |

## Usage

To use the `bootstrap_pip` role, include it in your playbook and configure the necessary variables as needed.

### Example Playbook

```yaml
- name: Bootstrap pip on target hosts
  hosts: all
  become: yes
  roles:
    - role: bootstrap_pip
      vars:
        bootstrap_pip__pip_version: "21.3.1"
        bootstrap_pip__env_list:
          - name: myenv
            virtualenv: /opt/myenv
            pip_version: latest
```

## Dependencies

- No external dependencies are required for this role.

## Best Practices

- Always specify a specific version of `pip` to avoid breaking changes introduced in newer versions.
- Use virtual environments (`virtualenv`) to isolate Python packages and avoid conflicts between projects.
- Regularly update the system pip if necessary, but be cautious about potential compatibility issues with existing packages.

## Molecule Tests

This role does not include Molecule tests at this time. Consider adding them for automated testing of the role's functionality.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_pip/defaults/main.yml)
- [tasks/fix-broken-sitecustomize.yml](../../roles/bootstrap_pip/tasks/fix-broken-sitecustomize.yml)
- [tasks/get-pip-version.yml](../../roles/bootstrap_pip/tasks/get-pip-version.yml)
- [tasks/init-vars.yml](../../roles/bootstrap_pip/tasks/init-vars.yml)
- [tasks/install-pip-libs.yml](../../roles/bootstrap_pip/tasks/install-pip-libs.yml)
- [tasks/main.yml](../../roles/bootstrap_pip/tasks/main.yml)
- [tasks/run-get-pip.yml](../../roles/bootstrap_pip/tasks/run-get-pip.yml)