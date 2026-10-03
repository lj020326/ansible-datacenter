---
title: "Bootstrap Pyenv Role"
role: bootstrap_pyenv
category: Development Tools
type: ansible-role
tags: [ansible, role, bootstrap_pyenv]
---

# Bootstrap Pyenv Role

The `bootstrap_pyenv` Ansible role provides a comprehensive solution for installing and configuring `pyenv`, a Python version management tool. This role supports installation via Homebrew or Git, handles dependencies, and sets up shell initialization for various shells like Bash and Zsh. It also manages Python versions and global settings, making it suitable for both development and production environments.

## Summary

The `bootstrap_pyenv` Ansible role provides a comprehensive solution for installing and configuring `pyenv`, a Python version management tool. This role supports installation via Homebrew or Git, handles dependencies, and sets up shell initialization for various shells like Bash and Zsh. It also manages Python versions and global settings, making it suitable for both development and production environments.

## Variables

| Variable Name                   | Default Value                                      | Description                                                                 |
|---------------------------------|--------------------------------------------------|-----------------------------------------------------------------------------|
| `pyenv_home`                    | `{{ ansible_facts.env.HOME }}`                    | The home directory for the user.                                            |
| `pyenv_root`                    | `{{ ansible_facts.env.HOME }}/.pyenv`             | The root directory where pyenv will be installed.                           |
| `pyenv_init_shell`              | `true`                                             | Whether to initialize the shell with pyenv settings.                        |
| `pyenv_version`                 | `v2.2.5`                                           | The version of pyenv to install.                                            |
| `pyenv_virtualenv_version`      | `v1.1.5`                                           | The version of pyenv-virtualenv to install.                                 |
| `pyenv_virtualenvwrapper_version` | `v20140609`                                      | The version of pyenv-virtualenvwrapper to install.                          |
| `pyenv_python37_version`        | `3.7.13`                                           | The version of Python 3.7 to install.                                       |
| `pyenv_python38_version`        | `3.8.13`                                           | The version of Python 3.8 to install.                                       |
| `pyenv_python39_version`        | `3.9.11`                                           | The version of Python 3.9 to install.                                       |
| `pyenv_python310_version`       | `3.10.3`                                           | The version of Python 3.10 to install.                                      |
| `pyenv_python_versions`         | `[{{ pyenv_python310_version }}]`                 | A list of Python versions to install.                                       |
| `pyenv_global`                  | `{{ pyenv_python310_version }} system`             | The global Python version to set.                                           |
| `pyenv_virtualenvwrapper`       | `false`                                            | Whether to install pyenv-virtualenvwrapper.                                 |
| `pyenv_virtualenvwrapper_home`  | `{{ ansible_facts.env.HOME }}/.virtualenvs`       | The home directory for pyenv-virtualenvwrapper.                             |
| `pyenv_install_from_package_manager` | `true`                                 | Whether to install pyenv from the package manager.                         |
| `pyenv_detect_existing_install` | `true`                                            | Whether to detect an existing pyenv installation.                          |
| `pyenv_homebrew_on_linux`       | `false`                                            | Whether to use Homebrew on Linux.                                           |

## Usage

To use this role, include it in your playbook and set the desired variables. Here's an example:

```yaml
- hosts: all
  roles:
    - role: bootstrap_pyenv
      vars:
        pyenv_version: v2.3.0
        pyenv_python_versions:
          - 3.9.12
          - 3.10.4
```

## Dependencies

- This role requires the `community.general` collection for Homebrew-related tasks.

## Best Practices

- Always test the role in a development environment before deploying it to production.
- Ensure that the necessary dependencies are installed on the target system.
- Regularly update the role to use the latest versions of pyenv and its plugins.

## Related Files

- [roles/bootstrap_pyenv/defaults/main.yml](../../roles/bootstrap_pyenv/defaults/main.yml)
- [roles/bootstrap_pyenv/tasks/Darwin.yml](../../roles/bootstrap_pyenv/tasks/Darwin.yml)
- [roles/bootstrap_pyenv/tasks/Linux.yml](../../roles/bootstrap_pyenv/tasks/Linux.yml)
- [roles/bootstrap_pyenv/tasks/detect_existing_install.yml](../../roles/bootstrap_pyenv/tasks/detect_existing_install.yml)
- [roles/bootstrap_pyenv/tasks/homebrew_build_requirements.yml](../../roles/bootstrap_pyenv/tasks/homebrew_build_requirements.yml)
- [roles/bootstrap_pyenv/tasks/install_with_git.yml](../../roles/bootstrap_pyenv/tasks/install_with_git.yml)
- [roles/bootstrap_pyenv/tasks/install_with_homebrew.yml](../../roles/bootstrap_pyenv/tasks/install_with_homebrew.yml)
- [roles/bootstrap_pyenv/tasks/remove_homebrew.yml](../../roles/bootstrap_pyenv/tasks/remove_homebrew.yml)
- [roles/bootstrap_pyenv/tasks/main.yml](../../roles/bootstrap_pyenv/tasks/main.yml)
- [roles/bootstrap_pyenv/tasks/setup.yml](../../roles/bootstrap_pyenv/tasks/setup.yml)
- [roles/bootstrap_pyenv/tasks/bash.yml](../../roles/bootstrap_pyenv/tasks/bash.yml)
- [roles/bootstrap_pyenv/tasks/shell.yml](../../roles/bootstrap_pyenv/tasks/shell.yml)
- [roles/bootstrap_pyenv/tasks/zsh.yml](../../roles/bootstrap_pyenv/tasks/zsh.yml)
- [roles/bootstrap_pyenv/tasks/global_version.yml](../../roles/bootstrap_pyenv/tasks/global_version.yml)
- [roles/bootstrap_pyenv/tasks/python_versions.yml](../../roles/bootstrap_pyenv/tasks/python_versions.yml)
- [roles/bootstrap_pyenv/tasks/python_versions_with_git.yml](../../roles/bootstrap_pyenv/tasks/python_versions_with_git.yml)
- [roles/bootstrap_pyenv/tasks/python_versions_with_homebrew.yml](../../roles/bootstrap_pyenv/tasks/python_versions_with_homebrew.yml)