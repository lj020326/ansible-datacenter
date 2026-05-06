---
title: "Bootstrap Pyenv Role"
role: roles/bootstrap_pyenv
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_pyenv]
---

# Role Documentation: `bootstrap_pyenv`

## Overview

The `bootstrap_pyenv` Ansible role is designed to automate the installation and configuration of [pyenv](https://github.com/pyenv/pyenv) on both Linux and macOS systems. It supports installing specific versions of Python, setting global Python versions, and configuring shell environments (bash and zsh).

## Role Variables

### Default Variables (`defaults/main.yml`)

| Variable Name                          | Description                                                                 | Default Value                                      |
|----------------------------------------|-----------------------------------------------------------------------------|----------------------------------------------------|
| `pyenv_home`                           | The home directory for pyenv.                                               | `{{ ansible_env.HOME }}`                         |
| `pyenv_root`                           | The root directory where pyenv will be installed.                             | `{{ ansible_env.HOME }}/.pyenv`                  |
| `pyenv_init_shell`                     | Whether to initialize the shell environment for pyenv.                      | `true`                                             |
| `pyenv_version`                        | Version of pyenv to install.                                                | `v2.2.5`                                           |
| `pyenv_virtualenv_version`             | Version of pyenv-virtualenv to install.                                     | `v1.1.5`                                           |
| `pyenv_virtualenvwrapper_version`      | Version of pyenv-virtualenvwrapper to install.                              | `v20140609`                                        |
| `pyenv_python37_version`               | Version of Python 3.7 to install.                                           | `3.7.13`                                           |
| `pyenv_python38_version`               | Version of Python 3.8 to install.                                           | `3.8.13`                                           |
| `pyenv_python39_version`               | Version of Python 3.9 to install.                                           | `3.9.11`                                           |
| `pyenv_python310_version`              | Version of Python 3.10 to install.                                          | `3.10.3`                                           |
| `pyenv_python_versions`                | List of Python versions to install.                                         | `[ "{{ pyenv_python310_version }}" ]`              |
| `pyenv_global`                         | Global Python version(s) to set.                                            | `"{{ pyenv_python310_version }} system"`           |
| `pyenv_virtualenvwrapper`              | Whether to install and configure pyenv-virtualenvwrapper.                   | `false`                                            |
| `pyenv_virtualenvwrapper_home`         | Directory for virtual environments managed by pyenv-virtualenvwrapper.      | `{{ ansible_env.HOME }}/.virtualenvs`            |
| `pyenv_install_from_package_manager`   | Whether to install pyenv using the package manager (Homebrew).              | `true`                                             |
| `pyenv_detect_existing_install`        | Whether to detect an existing pyenv installation.                           | `true`                                             |
| `pyenv_homebrew_on_linux`              | Whether to use Homebrew on Linux for installing pyenv and related packages.| `false`                                            |

## Tasks

### Main Task (`tasks/main.yml`)

The main task file loads the appropriate OS-specific variables, sets up pyenv based on the operating system, initializes the shell environment if required, installs specified Python versions, and sets the global Python version.

- **Load Variables**: Loads OS-specific variables.
- **Setup on Linux**: Executes tasks specific to Linux systems.
- **Setup on macOS**: Executes tasks specific to macOS systems.
- **Run Setup Tasks**: Runs additional setup tasks defined in `setup.yml`.
- **Initialize Shell**: Initializes shell environment for pyenv if `pyenv_init_shell` is set to true.
- **Install Python Versions**: Installs specified Python versions.
- **Set Global Version**: Sets the global Python version.

### OS-Specific Tasks

#### Linux (`tasks/Linux.yml`)

1. **Install Build Requirements**: Installs required packages using the package manager.
2. **Install with Git**: Clones pyenv and related plugins from GitHub if not using Homebrew.
3. **Install with Homebrew**: Uses Homebrew to install pyenv and related plugins if `pyenv_homebrew_on_linux` is set to true.

#### macOS (`tasks/Darwin.yml`)

1. **Install Build Requirements with Homebrew**: Installs required packages using Homebrew.
2. **Detect Existing Install**: Checks for an existing pyenv installation.
3. **Install with Homebrew**: Uses Homebrew to install pyenv and related plugins if `pyenv_install_from_package_manager` is set to true.
4. **Uninstall Homebrew Packages**: Removes Homebrew-installed packages if not using Homebrew.
5. **Install with Git**: Clones pyenv and related plugins from GitHub if not using Homebrew.

### Utility Tasks

#### Detect Existing Install (`tasks/detect_existing_install.yml`)

- Checks if the `~/.pyenv` directory exists.
- Determines if it is a Git repository to decide whether to install from Git or Homebrew.

#### Setup (`tasks/setup.yml`)

- Ensures the `.pyenv` and `WORKON_HOME` directories exist.
- Creates a `.pyenvrc` file in the `.pyenv` directory.

#### Shell Configuration (`tasks/shell.yml`, `tasks/bash.yml`, `tasks/zsh.yml`)

- Configures shell environments (bash, zsh) to load pyenv automatically.
- Ensures that pyenv is properly initialized and available in the PATH.

#### Python Version Installation (`tasks/python_versions.yml`, `tasks/python_versions_with_git.yml`, `tasks/python_versions_with_homebrew.yml`)

- Installs specified Python versions using either Git or Homebrew based on the installation method.
- Sets the global Python version after installation.

## Usage

### Example Playbook

```yaml
---
- hosts: all
  roles:
    - role: bootstrap_pyenv
      vars:
        pyenv_python_versions:
          - "3.8.13"
          - "3.9.11"
        pyenv_global: "3.9.11 system"
```

### Notes

- **Double-underscore variables**: These are internal only and should not be modified.
- **No Related Roles**: This role does not depend on any other roles.
- **Standard GitHub Markdown**: Documentation is formatted using standard GitHub Markdown.

## Contributing

Contributions to this role are welcome. Please ensure that all changes are well-documented and tested across supported operating systems.

## License

This role is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Author Information

- **Author**: Qwen (Created by Alibaba Cloud)
- **Contact**: Support can be reached through the Ansible community or via GitHub issues.
- **Repository**: [bootstrap_pyenv Role Repository](https://github.com/your-repo/bootstrap_pyenv)

---

This comprehensive documentation provides a detailed overview of the `bootstrap_pyenv` role, including its variables, tasks, and usage instructions. It serves as a guide for users looking to deploy pyenv environments using Ansible.