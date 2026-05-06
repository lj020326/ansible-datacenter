---
title: Bootstrap Pip Role Documentation
role: bootstrap_pip
category: Ansible Roles
type: Configuration Management
tags: ansible, pip, virtualenv, python
---

## Summary

The `bootstrap_pip` role is designed to ensure that the Python package manager `pip` and its associated libraries are installed and configured correctly on a target system. This role handles the installation of `pip`, upgrading it if necessary, and setting up virtual environments with specified packages. It also manages configuration files like `/etc/pip.conf` and ensures that the correct version of Python is used.

## Variables

| Variable Name                           | Default Value                                                                 | Description                                                                                                                                                                                                 |
|-----------------------------------------|-------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_pip__python_executable`      | `{{ ansible_python_interpreter }}`                                          | The path to the Python interpreter to be used. Defaults to the system's default Python interpreter.                                                                                                           |
| `bootstrap_pip__pip_executable`         | `pip3`                                                                        | The pip executable to use. Defaults to `pip3`.                                                                                                                                                              |
| `bootstrap_pip__pip_version`            | `latest`                                                                      | The version of pip to install. Can be set to a specific version or `latest`.                                                                                                                              |
| `bootstrap_pip__env_force_rebuild`      | `false`                                                                       | If true, forces the rebuild of virtual environments.                                                                                                                                                        |
| `bootstrap_pip__env_list`               | `[]`                                                                          | A list of virtual environments to be created and managed. Each environment can have its own set of packages and configurations.                                                                              |
| `bootstrap_pip__packages`               | `[]`                                                                          | A list of system packages required for pip installation, such as `python3-pip`.                                                                                                                             |
| `bootstrap_pip__venv_environment_vars`  | `{ SETUPTOOLS_USE_DISTUTILS: 'stdlib' if python_version < 3.12 else 'local', LANG: en_US.UTF-8, LC_ALL: en_US.UTF-8 }` | Environment variables to be set when creating virtual environments.                                                                                                                                         |
| `bootstrap_pip__environment_ignore_root_user_action` | `{ PIP_ROOT_USER_ACTION: ignore, LANG: en_US.UTF-8, LC_ALL: en_US.UTF-8 }` | Environment variables to prevent pip from running as root and to ensure consistent locale settings.                                                                                                           |
| `bootstrap_pip__lib_state`              | `present`                                                                     | The state of the libraries to be installed (e.g., present).                                                                                                                                                 |
| `bootstrap_pip__libs`                   | `[setuptools, pyyaml, jinja2, cryptography, pyopenssl, requests, netaddr, passlib, jsondiff]` | A list of Python libraries to install. Each library can have a priority and state specified.                                                                                                                |
| `bootstrap_pip__tmp`                    | `/tmp`                                                                        | The temporary directory used for downloading the get-pip script.                                                                                                                                            |
| `bootstrap_pip__get_pip_url`            | `https://bootstrap.pypa.io/get-pip.py`                                        | The URL from which to download the get-pip script.                                                                                                                                                          |
| `bootstrap_pip__virtualenv_command`     | `{{ __bootstrap_pip__python_interpreter }} -m venv`                           | The command used to create virtual environments. Defaults to using Python's built-in `venv` module.                                                                                                        |
| `bootstrap_pip__system_pip_upgrade_enabled` | `true`                                                                      | If true, allows the system pip to be upgraded via package manager.                                                                                                                                          |
| `bootstrap_pip__system_pip_install_libs_allowed` | `false`                                                                   | If true, allows installation of libraries using the system's package manager.                                                                                                                               |

## Usage

To use the `bootstrap_pip` role, include it in your playbook and optionally override any variables as needed.

### Example Playbook

```yaml
- name: Bootstrap pip on target hosts
  hosts: all
  roles:
    - role: bootstrap_pip
      vars:
        bootstrap_pip__pip_version: "21.3.1"
        bootstrap_pip__env_list:
          - name: myenv
            virtualenv: /opt/myenv
            packages:
              - flask
              - requests
```

## Dependencies

This role does not have any external dependencies beyond the standard Ansible modules and Python interpreter.

## Best Practices

- Ensure that the `bootstrap_pip__python_executable` points to a valid Python interpreter.
- Specify the desired version of pip in `bootstrap_pip__pip_version` if you need a specific version for compatibility reasons.
- Use virtual environments (`virtualenv`) to manage dependencies and avoid conflicts between projects.

## Molecule Tests

This role includes Molecule tests to verify its functionality. To run the tests, navigate to the role directory and execute:

```bash
molecule test
```

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_pip/defaults/main.yml)
- [tasks/get-pip-version.yml](../../roles/bootstrap_pip/tasks/get-pip-version.yml)
- [tasks/init-vars.yml](../../roles/bootstrap_pip/tasks/init-vars.yml)
- [tasks/install-pip-libs.yml](../../roles/bootstrap_pip/tasks/install-pip-libs.yml)
- [tasks/main.yml](../../roles/bootstrap_pip/tasks/main.yml)
- [tasks/run-get-pip.yml](../../roles/bootstrap_pip/tasks/run-get-pip.yml)

---

This documentation provides a comprehensive overview of the `bootstrap_pip` role, including its purpose, configuration options, usage examples, and best practices.