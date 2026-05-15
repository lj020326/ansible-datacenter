---
title: "Bootstrap Pyenv Role"
role: bootstrap_pyenv
category: Ansible Roles
type: Configuration Management
tags: pyenv, python, automation, ansible
---

## Summary

The `bootstrap_pyenv` role is designed to automate the installation and configuration of [pyenv](https://github.com/pyenv/pyenv) on both Linux and macOS systems. It handles the installation of pyenv along with its plugins (`pyenv-virtualenv`, `pyenv-virtualenvwrapper`) and sets up the necessary environment variables and shell configurations to enable seamless usage of pyenv.

## Variables

| Variable Name                             | Default Value                                                                 | Description                                                                                                                                                                                                 |
|-------------------------------------------|-------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `pyenv_home`                              | `"{{ ansible_env.HOME }}"`                                                    | The home directory where pyenv will be installed. By default, it uses the user's home directory.                                                                                                          |
| `pyenv_root`                              | `"{{ ansible_env.HOME }}/.pyenv"`                                             | The root directory for pyenv installation.                                                                                                                                                                  |
| `pyenv_init_shell`                        | `true`                                                                        | Whether to initialize the shell with pyenv by adding necessary environment variables and commands to shell configuration files (e.g., `.bash_profile`, `.zprofile`).                                         |
| `pyenv_version`                           | `v2.2.5`                                                                      | The version of pyenv to install.                                                                                                                                                                            |
| `pyenv_virtualenv_version`                | `v1.1.5`                                                                      | The version of the `pyenv-virtualenv` plugin to install.                                                                                                                                                    |
| `pyenv_virtualenvwrapper_version`         | `v20140609`                                                                   | The version of the `pyenv-virtualenvwrapper` plugin to install.                                                                                                                                             |
| `pyenv_python37_version`                  | `3.7.13`                                                                      | The version of Python 3.7 to be installed via pyenv.                                                                                                                                                        |
| `pyenv_python38_version`                  | `3.8.13`                                                                      | The version of Python 3.8 to be installed via pyenv.                                                                                                                                                        |
| `pyenv_python39_version`                  | `3.9.11`                                                                      | The version of Python 3.9 to be installed via pyenv.                                                                                                                                                        |
| `pyenv_python310_version`                 | `3.10.3`                                                                      | The version of Python 3.10 to be installed via pyenv.                                                                                                                                                       |
| `pyenv_python_versions`                   | `[ "{{ pyenv_python310_version }}" ]`                                          | A list of Python versions to install using pyenv. By default, it installs Python 3.10.                                                                                                                   |
| `pyenv_global`                            | `"{{ pyenv_python310_version }} system"`                                      | The global Python version(s) to set after installation. This can include specific Python versions and the system version.                                                                               |
| `pyenv_virtualenvwrapper`                 | `false`                                                                       | Whether to install and configure `pyenv-virtualenvwrapper`.                                                                                                                                             |
| `pyenv_virtualenvwrapper_home`            | `"{{ ansible_env.HOME }}/.virtualenvs"`                                       | The directory where virtual environments will be stored if `pyenv-virtualenvwrapper` is enabled.                                                                                                          |
| `pyenv_install_from_package_manager`      | `true`                                                                        | Whether to install pyenv and its plugins using the package manager (Homebrew on macOS, system packages on Linux).                                                                                         |
| `pyenv_detect_existing_install`           | `true`                                                                        | Whether to detect an existing pyenv installation before proceeding with a new installation.                                                                                                                |
| `pyenv_homebrew_on_linux`                 | `false`                                                                       | Whether to use Homebrew for installing pyenv and its plugins on Linux systems, instead of the system package manager.                                                                                    |

## Usage

To use the `bootstrap_pyenv` role in your Ansible playbook, include it as follows:

```yaml
- name: Bootstrap pyenv installation
  hosts: all
  roles:
    - role: bootstrap_pyenv
      vars:
        pyenv_python_versions:
          - "{{ pyenv_python38_version }}"
          - "{{ pyenv_python39_version }}"
        pyenv_global: "{{ pyenv_python39_version }} system"
```

This example installs Python 3.8 and 3.9, setting the global version to Python 3.9 followed by the system version.

## Dependencies

- `community.general` Ansible collection (for Homebrew module support).

Ensure that the `community.general` collection is installed:

```bash
ansible-galaxy collection install community.general
```

## Best Practices

1. **Version Control**: Always specify exact versions for pyenv and its plugins to avoid unexpected changes.
2. **Environment Isolation**: Use virtual environments (`pyenv-virtualenv`) to manage dependencies for different projects separately.
3. **Shell Configuration**: Ensure that your shell configuration files (e.g., `.bash_profile`, `.zprofile`) are correctly set up to load pyenv.

## Molecule Tests

This role does not include Molecule tests at the moment. Consider adding Molecule scenarios to automate testing of the role in different environments.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_pyenv/defaults/main.yml)
- [tasks/Darwin.yml](../../roles/bootstrap_pyenv/tasks/Darwin.yml)
- [tasks/Linux.yml](../../roles/bootstrap_pyenv/tasks/Linux.yml)
- [tasks/detect_existing_install.yml](../../roles/bootstrap_pyenv/tasks/detect_existing_install.yml)
- [tasks/homebrew_build_requirements.yml](../../roles/bootstrap_pyenv/tasks/homebrew_build_requirements.yml)
- [tasks/install_with_git.yml](../../roles/bootstrap_pyenv/tasks/install_with_git.yml)
- [tasks/install_with_homebrew.yml](../../roles/bootstrap_pyenv/tasks/install_with_homebrew.yml)
- [tasks/remove_homebrew.yml](../../roles/bootstrap_pyenv/tasks/remove_homebrew.yml)
- [tasks/main.yml](../../roles/bootstrap_pyenv/tasks/main.yml)
- [tasks/setup.yml](../../roles/bootstrap_pyenv/tasks/setup.yml)
- [tasks/bash.yml](../../roles/bootstrap_pyenv/tasks/bash.yml)
- [tasks/shell.yml](../../roles/bootstrap_pyenv/tasks/shell.yml)
- [tasks/zsh.yml](../../roles/bootstrap_pyenv/tasks/zsh.yml)
- [tasks/global_version.yml](../../roles/bootstrap_pyenv/tasks/global_version.yml)
- [tasks/python_versions.yml](../../roles/bootstrap_pyenv/tasks/python_versions.yml)
- [tasks/python_versions_with_git.yml](../../roles/bootstrap_pyenv/tasks/python_versions_with_git.yml)
- [tasks/python_versions_with_homebrew.yml](../../roles/bootstrap_pyenv/tasks/python_versions_with_homebrew.yml)