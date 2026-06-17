---
title: "Ansible Role - bootstrap_pyenv"
role: "bootstrap_pyenv"
category: "Roles"
type: "Documentation"
tags: ["ansible", "pyenv", "python", "virtualenv"]
---

# Ansible Role: `bootstrap_pyenv`

The `bootstrap_pyenv` role is designed to automate the installation and configuration of pyenv, a tool for managing multiple Python versions on a single system. This role supports both macOS and Linux systems, providing flexibility in how pyenv is installed (via package manager or Git) and configured to manage different Python versions efficiently.

## Variables

| Variable Name                           | Default Value                                                                 | Description                                                                                                                                                                                                 |
|-----------------------------------------|-------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `pyenv_home`                            | `"{{ ansible_facts.env.HOME }}"`                                            | The home directory where pyenv will be installed. By default, it uses the user's home directory.                                                                                                           |
| `pyenv_root`                            | `"{{ ansible_facts.env.HOME }}/.pyenv"`                                     | The root directory for pyenv installation.                                                                                                                                                                  |
| `pyenv_init_shell`                      | `true`                                                                        | Whether to initialize the shell environment to use pyenv.                                                                                                                                                   |
| `pyenv_version`                         | `v2.2.5`                                                                      | The version of pyenv to install.                                                                                                                                                                            |
| `pyenv_virtualenv_version`              | `v1.1.5`                                                                      | The version of pyenv-virtualenv to install.                                                                                                                                                                 |
| `pyenv_virtualenvwrapper_version`       | `v20140609`                                                                   | The version of pyenv-virtualenvwrapper to install.                                                                                                                                                          |
| `pyenv_python37_version`                | `3.7.13`                                                                      | The version of Python 3.7 to be installed via pyenv.                                                                                                                                                        |
| `pyenv_python38_version`                | `3.8.13`                                                                      | The version of Python 3.8 to be installed via pyenv.                                                                                                                                                        |
| `pyenv_python39_version`                | `3.9.11`                                                                      | The version of Python 3.9 to be installed via pyenv.                                                                                                                                                        |
| `pyenv_python310_version`               | `3.10.3`                                                                      | The version of Python 3.10 to be installed via pyenv.                                                                                                                                                       |
| `pyenv_python_versions`                 | `[ "{{ pyenv_python310_version }}" ]`                                         | A list of Python versions to install using pyenv. By default, it includes Python 3.10.                                                                                                                   |
| `pyenv_global`                          | `"{{ pyenv_python310_version }} system"`                                      | The global Python version(s) to set with pyenv.                                                                                                                                                             |
| `pyenv_virtualenvwrapper`               | `false`                                                                       | Whether to install and configure pyenv-virtualenvwrapper.                                                                                                                                                    |
| `pyenv_virtualenvwrapper_home`          | `"{{ ansible_facts.env.HOME }}/.virtualenvs"`                               | The home directory for virtual environments managed by pyenv-virtualenvwrapper.                                                                                                                           |
| `pyenv_install_from_package_manager`    | `true`                                                                        | Whether to install pyenv using the system's package manager (Homebrew on macOS/Linux).                                                                                                                      |
| `pyenv_detect_existing_install`         | `true`                                                                        | Whether to detect an existing pyenv installation and determine if it should be reinstalled.                                                                                                                |
| `pyenv_homebrew_on_linux`               | `false`                                                                       | Whether to use Homebrew for installing pyenv on Linux systems instead of the system's package manager.                                                                                                      |

## Usage

To utilize this role, include it in your playbook as follows:

```yaml
- hosts: all
  roles:
    - role: bootstrap_pyenv
      vars:
        pyenv_python_versions:
          - "3.7.13"
          - "3.8.13"
          - "3.9.11"
        pyenv_global: "3.9.11 system"
```

### Example Playbook

```yaml
---
- name: Install and configure pyenv on all hosts
  hosts: all
  become: yes
  roles:
    - role: bootstrap_pyenv
      vars:
        pyenv_python_versions:
          - "3.7.13"
          - "3.8.13"
          - "3.9.11"
        pyenv_global: "3.9.11 system"
```

## Dependencies

This role depends on the following Ansible collections:

- `ansible.builtin`
- `community.general`

Ensure these collections are installed in your environment before running this role.

## Best Practices

- **Version Control**: Always specify the version of pyenv and its plugins to ensure consistency across environments.
- **Environment Isolation**: Use virtual environments (via pyenv-virtualenv) to isolate dependencies for different projects.
- **Testing**: Utilize Molecule tests to verify the role's functionality in various scenarios.

## Molecule Tests

This role includes Molecule tests to validate its behavior. To run the tests, execute:

```bash
molecule test
```

Ensure you have Molecule and the necessary drivers installed on your system.

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