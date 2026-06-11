---
title: Bootstrap Pip Role Documentation
role: bootstrap_pip
category: Ansible Roles
type: Configuration Management
tags: ansible, pip, python, virtualenv

---

## Summary

The `bootstrap_pip` role is designed to ensure that Python's package manager, `pip`, and a set of essential libraries are installed on target systems. It supports the installation of system-wide or virtual environment-specific packages, handles version management for `pip`, and provides mechanisms to fix broken configurations such as `sitecustomize.py`. This role is particularly useful in environments where consistent Python package installations are critical.

## Variables

| Variable Name                              | Default Value                                                                                           | Description                                                                                                                                                                                                 |
|--------------------------------------------|---------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_pip__python_executable`         | `"{{ ansible_python_interpreter }}"`                                                                    | The path to the Python interpreter. Defaults to the system's default Python interpreter as detected by Ansible.                                                                                              |
| `bootstrap_pip__pip_executable`            | `pip3`                                                                                                | The name of the pip executable. Defaults to `pip3`.                                                                                                                                                           |
| `bootstrap_pip__pip_version`               | `latest`                                                                                              | The version of pip to install. Defaults to the latest version available.                                                                                                                                    |
| `bootstrap_pip__env_force_rebuild`         | `false`                                                                                               | Forces the rebuild of virtual environments if set to true.                                                                                                                                                  |
| `bootstrap_pip__fix_broken_sitecustomize`  | `false`                                                                                               | Fixes broken `sitecustomize.py` files by backing them up and replacing their contents with a minimal script that prevents interference with Ansible.                                                            |
| `bootstrap_pip__env_list`                  | `[]`                                                                                                  | A list of virtual environments to manage. Each environment can have specific configurations such as the Python interpreter, pip version, and packages to install.                                               |
| `bootstrap_pip__packages`                  | `[]`                                                                                                  | A list of system-wide Python packages to install using the package manager.                                                                                                                               |
| `bootstrap_pip__venv_environment_vars`     | `{ SETUPTOOLS_USE_DISTUTILS: "{{ 'stdlib' if (ansible_facts['python_version'] | default('3.10')) is version('3.12', '<') else 'local' }}", LANG: en_US.UTF-8, LC_ALL: en_US.UTF-8 }` | Environment variables to set when creating virtual environments.                                                                                                                                            |
| `bootstrap_pip__environment_ignore_root_user_action` | `{ PIP_ROOT_USER_ACTION: ignore, LANG: en_US.UTF-8, LC_ALL: en_US.UTF-8 }`                      | Environment variables to ensure that pip does not prompt for user action when run as root.                                                                                                                 |
| `bootstrap_pip__lib_state`                 | `present`                                                                                             | The state of the libraries specified in `bootstrap_pip__libs`. Can be set to `absent` to uninstall them.                                                                                                    |
| `bootstrap_pip__lib_priority_default`      | `100`                                                                                                 | The default priority for libraries if not explicitly specified. Libraries with lower priority numbers are installed first.                                                                                  |
| `bootstrap_pip__libs`                      | `[setuptools, pyyaml, jinja2, cryptography, pyopenssl, requests, netaddr, passlib, jsondiff]`           | A list of Python libraries to install. Each library can have a name, priority, and state specified as a dictionary or just the name as a string.                                                             |
| `bootstrap_pip__tmp`                       | `/tmp`                                                                                                | The temporary directory used for downloading scripts like `get-pip.py`.                                                                                                                                     |
| `bootstrap_pip__get_pip_url`               | `https://bootstrap.pypa.io/get-pip.py`                                                                  | The URL from which to download the `get-pip.py` script.                                                                                                                                                     |
| `bootstrap_pip__virtualenv_command`        | `"{{ bootstrap_pip__python_executable }} -m venv"`                                                       | The command used to create virtual environments. Defaults to using the `-m venv` module of the specified Python interpreter.                                                                               |
| `bootstrap_pip__system_pip_upgrade_enabled`| `true`                                                                                                | Enables upgrading system pip if set to true.                                                                                                                                                                |
| `bootstrap_pip__system_pip_install_libs_allowed` | `false`                                                                                             | Allows installation of libraries using system pip if set to true. This is generally not recommended due to potential conflicts with package managers.                                                        |

## Usage

To use the `bootstrap_pip` role, include it in your playbook and configure the variables as needed. Here is an example playbook that installs a virtual environment with specific packages:

```yaml
---
- name: Bootstrap pip and install libraries
  hosts: all
  become: yes
  roles:
    - role: bootstrap_pip
      vars:
        bootstrap_pip__env_list:
          - name: myenv
            virtualenv: /opt/myenv
            pip_version: latest
            packages:
              - requests
              - flask
```

## Dependencies

This role does not have any external dependencies. However, it relies on the availability of Python and the package manager (`apt`, `yum`, etc.) on the target system.

## Best Practices

- **Virtual Environments**: Use virtual environments to manage project-specific dependencies, avoiding conflicts with system-wide packages.
- **Version Control**: Specify exact versions for critical libraries to ensure consistency across deployments.
- **Environment Variables**: Customize environment variables as needed to control pip behavior, especially when running as root or in specific locales.

## Molecule Tests

This role includes Molecule tests to verify its functionality. To run the tests, navigate to the role directory and execute:

```bash
molecule test
```

Ensure that you have Molecule installed along with any necessary drivers (e.g., Docker) before running the tests.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_pip/defaults/main.yml)
- [tasks/fix-broken-sitecustomize.yml](../../roles/bootstrap_pip/tasks/fix-broken-sitecustomize.yml)
- [tasks/get-pip-version.yml](../../roles/bootstrap_pip/tasks/get-pip-version.yml)
- [tasks/init-vars.yml](../../roles/bootstrap_pip/tasks/init-vars.yml)
- [tasks/install-pip-libs.yml](../../roles/bootstrap_pip/tasks/install-pip-libs.yml)
- [tasks/main.yml](../../roles/bootstrap_pip/tasks/main.yml)
- [tasks/run-get-pip.yml](../../roles/bootstrap_pip/tasks/run-get-pip.yml)

---

This documentation provides a comprehensive overview of the `bootstrap_pip` role, including its purpose, configuration options, usage examples, and best practices. For more detailed information, refer to the linked source files.