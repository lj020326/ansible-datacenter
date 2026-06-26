---
title: Bootstrap Pip Role Documentation
role: bootstrap_pip
category: Ansible Roles
type: Configuration Management
---

## Summary

The `bootstrap_pip` role is designed to ensure that the Python package manager, pip, is installed and up-to-date on target systems. It handles various aspects of pip installation, including downloading and installing pip using get-pip.py, managing virtual environments, and ensuring specific packages are installed in those environments. The role also includes functionality to fix broken `sitecustomize.py` files that can interfere with Ansible's operation.

## Variables

| Variable Name                                      | Default Value                                                                                          | Description                                                                                                                                                                                                 |
|----------------------------------------------------|--------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_pip__python_executable`                 | `"{{ ansible_python_interpreter }}"`                                                                   | The Python interpreter to use for pip operations. Defaults to the system's default Python interpreter as detected by Ansible.                                                                               |
| `bootstrap_pip__pip_executable`                    | `pip3`                                                                                                 | The pip executable to use. Defaults to `pip3`.                                                                                                                                                              |
| `bootstrap_pip__pip_version`                       | `latest`                                                                                               | The version of pip to install. Can be set to a specific version or `latest`.                                                                                                                              |
| `bootstrap_pip__env_force_rebuild`                 | `false`                                                                                                | If true, forces the rebuild of virtual environments.                                                                                                                                                        |
| `bootstrap_pip__fix_broken_sitecustomize`          | `false`                                                                                                | If true, attempts to fix broken `sitecustomize.py` files that can interfere with Ansible's operation.                                                                                                      |
| `bootstrap_pip__env_list`                          | `[]`                                                                                                   | A list of environments to manage. Each environment can specify its own pip version and packages.                                                                                                          |
| `bootstrap_pip__packages`                          | `[]`                                                                                                   | A list of system-level Python packages to install using the package manager.                                                                                                                                |
| `bootstrap_pip__venv_environment_vars`             | `{ SETUPTOOLS_USE_DISTUTILS: "{{ 'stdlib' if (ansible_facts['python_version'] | default('3.10')) is version('3.12', '<') else 'local' }}", LANG: en_US.UTF-8, LC_ALL: en_US.UTF-8 }` | Environment variables to set when creating virtual environments.                                                                                                                                            |
| `bootstrap_pip__environment_ignore_root_user_action` | `{ PIP_ROOT_USER_ACTION: ignore, LANG: en_US.UTF-8, LC_ALL: en_US.UTF-8 }`                             | Environment variables to ensure pip does not prompt for root user actions.                                                                                                                                  |
| `bootstrap_pip__lib_state`                         | `latest`                                                                                               | The state of the libraries to install (e.g., `present`, `latest`).                                                                                                                                        |
| `bootstrap_pip__libs`                              | `[setuptools, pyyaml, jinja2, cryptography, pyopenssl, requests, netaddr, passlib, jsondiff]`           | A list of Python libraries to install. Each library can specify a priority and state.                                                                                                                       |
| `bootstrap_pip__tmp`                               | `/tmp`                                                                                                 | The temporary directory used for downloading get-pip.py.                                                                                                                                                  |
| `bootstrap_pip__get_pip_url`                       | `https://bootstrap.pypa.io/get-pip.py`                                                                   | The URL from which to download the get-pip.py script.                                                                                                                                                     |
| `bootstrap_pip__virtualenv_command`                | `"{{ __bootstrap_pip__python_interpreter }} -m venv"`                                                    | The command used to create virtual environments.                                                                                                                                                            |
| `bootstrap_pip__system_pip_upgrade_enabled`        | `true`                                                                                                 | If true, allows the system pip to be upgraded using the package manager.                                                                                                                                    |
| `bootstrap_pip__system_pip_install_libs_allowed`   | `false`                                                                                                | If true, allows installation of Python libraries at the system level using pip. This is generally not recommended due to potential conflicts with system packages.                                               |

## Usage

To use the `bootstrap_pip` role, include it in your playbook and configure any necessary variables as needed. Here is an example playbook that demonstrates how to use this role:

```yaml
---
- name: Bootstrap Pip on target hosts
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
            packages:
              - requests
              - flask
```

In this example, the role is applied to all hosts in the inventory. The system-wide pip version is set to `21.3.1`, and a virtual environment named `myenv` is created with the latest pip version, containing the `requests` and `flask` packages.

## Dependencies

This role does not have any external dependencies beyond what is typically available in standard Ansible distributions. However, it relies on the availability of Python and the package manager on the target systems.

## Best Practices

- **Environment Management**: Use virtual environments to manage Python dependencies for different projects separately.
- **Version Control**: Specify exact versions of pip and libraries when possible to avoid unexpected changes due to updates.
- **Security**: Ensure that the `get-pip.py` script is downloaded from a trusted source and validate its integrity if necessary.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_pip/defaults/main.yml)
- [tasks/fix-broken-sitecustomize.yml](../../roles/bootstrap_pip/tasks/fix-broken-sitecustomize.yml)
- [tasks/get-pip-version.yml](../../roles/bootstrap_pip/tasks/get-pip-version.yml)
- [tasks/init-vars.yml](../../roles/bootstrap_pip/tasks/init-vars.yml)
- [tasks/install-pip-libs.yml](../../roles/bootstrap_pip/tasks/install-pip-libs.yml)
- [tasks/main.yml](../../roles/bootstrap_pip/tasks/main.yml)
- [tasks/run-get-pip.yml](../../roles/bootstrap_pip/tasks/run-get-pip.yml)