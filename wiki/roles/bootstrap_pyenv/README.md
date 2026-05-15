```markdown
---
title: bootstrap_pyenv Ansible Role Documentation
original_path: roles/bootstrap_pyenv/README.md
category: Ansible Roles
tags: [ansible, pyenv, python, virtualenv, macOS, Ubuntu]
---

# bootstrap_pyenv

An Ansible role to install [pyenv] and [pyenv-virtualenv] on Ubuntu or macOS development machines.

**Note:** Do not use this role on production servers as it supports installing pyenv only under the user home directory.

[pyenv]: https://github.com/pyenv/pyenv
[pyenv-virtualenv]: https://github.com/pyenv/pyenv-virtualenv

Optionally, [pyenv-virtualenvwrapper] can be installed and used for managing environments.

[pyenv-virtualenvwrapper]: https://github.com/pyenv/pyenv-virtualenvwrapper

## Installation Methods

### Install from Homebrew on macOS

The default method to install pyenv and plugins on macOS is to use Homebrew. The role will detect any existing installation and continue using the previous method. To migrate, back up and delete your existing `~/.pyenv` directory before running this role.

### Install from Homebrew on Linux

The role includes experimental support for installing pyenv and plugins with Homebrew on Linux. It expects Homebrew to be installed in the default `/home/linuxbrew/.linuxbrew` location. Installing Python versions with pyenv on Linux when a Homebrew installation exists has some known issues:

- **readline extension was not compiled, installed pyenv by Linuxbrew on Ubuntu 16** [#1479][pyenv-1479]

[pyenv-1479]: https://github.com/pyenv/pyenv/issues/1479

## Installed Python Versions

This role installs [Python] versions defined in the `pyenv_python_versions` variable. Set the global version using the `pyenv_global` variable.

Example:
```yaml
pyenv_global: "{{ pyenv_python37_version }} system"
```

This configuration uses the latest Python 2 and Python 3 versions, with the system version as default.

[Python]: https://www.python.org

## Changes to Shell Configuration Files

The role creates a config file in `~/.pyenv/.pyenvrc` that is loaded into `.bashrc` and `.zshrc` files. Code completion is enabled by default.

If you manage your shell scripts (`.dotfiles`) or use a framework, set `pyenv_init_shell` to `false` and update these files manually.

**Reference `.bashrc` configuration:**
```bash
if [ -e "$HOME/.pyenv/.pyenvrc" ]; then
  source $HOME/.pyenv/.pyenvrc
  if [ -e "$HOME/.pyenv/completions/pyenv.bash" ]; then
    source $HOME/.pyenv/completions/pyenv.bash
  elif [ -e "/usr/local/opt/pyenv/completions/pyenv.bash" ]; then
    source /usr/local/opt/pyenv/completions/pyenv.bash
  fi
fi
```

**Reference `.zshrc` configuration:**
```zsh
if [ -e "$HOME/.pyenv/.pyenvrc" ]; then
  source $HOME/.pyenv/.pyenvrc
  if [ -e "$HOME/.pyenv/completions/pyenv.zsh" ]; then
    source $HOME/.pyenv/completions/pyenv.zsh
  elif [ -e "/usr/local/opt/pyenv/completions/pyenv.zsh" ]; then
    source /usr/local/opt/pyenv/completions/pyenv.zsh
  fi
fi
```

## Role Variables

- **Path to `~/.pyenv`:**
  ```yaml
  pyenv_home: "{{ ansible_env.HOME }}"
  pyenv_root: "{{ ansible_env.HOME }}/.pyenv"
  ```

- **Update `.bashrc` and `.zshrc` files in user home directory:**
  ```yaml
  pyenv_init_shell: true
  ```

- **Versions to install:**
  ```yaml
  pyenv_version: "v1.2.13"
  pyenv_virtualenv_version: "v1.1.5"
  pyenv_virtualenvwrapper_version: "v20140609"
  ```

- **Latest Python 3.7 and Python 3.8 versions:**
  ```yaml
  pyenv_python37_version: "3.7.6"
  pyenv_python38_version: "3.8.1"
  ```

- **Python 2 and Python 3 versions installed by default:**
  ```yaml
  pyenv_python_versions:
    - "{{ pyenv_python37_version }}"
    - "{{ pyenv_python38_version }}"
  ```

- **Set global version to Python 3.7 with `system` fallback:**
  ```yaml
  pyenv_global: "{{ pyenv_python37_version }} system"
  ```

- **Install virtualenvwrapper plugin:**
  ```yaml
  pyenv_virtualenvwrapper: false
  pyenv_virtualenvwrapper_home: "{{ ansible_env.HOME }}/.virtualenvs"
  ```

- **Install using Homebrew package manager on macOS:**
  ```yaml
  pyenv_install_from_package_manager: true
  ```

- **Detect existing installation method and use that:**
  ```yaml
  pyenv_detect_existing_install: true
  ```

- **Install using Homebrew on Linux:**
  ```yaml
  pyenv_homebrew_on_linux: true
  ```

## Example Playbook

```yaml
- hosts: localhost
  connection: local
  become: false
  roles:
    - role: bootstrap_pyenv
```

## Updating Versions

Run the following scripts to get latest releases from GitHub and update them in role defaults.

- **Update [pyenv] release:**
  ```bash
  ./update-release pyenv
  ```

- **Update [pyenv-virtualenv] release:**
  ```bash
  ./update-release pyenv-virtualenv
  ```

- **Update default [Python] 3.7 version:**
  ```bash
  ./update-python python37
  ```

- **Update default [Python] 3.8 version:**
  ```bash
  ./update-python python38
  ```

- **Update all versions:**
  ```bash
  make update
  ```

## Coding Style

Install pre-commit hooks and validate coding style:
```bash
make lint
```

## Run Tests

Run tests in Ubuntu and Debian using Docker:
```bash
make test
```

## Acknowledgements

Use of `.pyenvrc` file and parts used for installing Python versions taken from [avanov.pyenv](https://github.com/avanov/ansible-galaxy-pyenv) role.

## Development

- **Install development dependencies in a local virtualenv:**
  ```bash
  make setup
  ```

- **Install [pre-commit] hooks:**
  ```bash
  make install-git-hooks
  ```

[pre-commit]: https://pre-commit.com/

## Reference

- [markosamuli/ansible-pyenv](https://github.com/markosamuli/ansible-pyenv)

## Backlinks

- [Ansible Roles Documentation](../README.md)
```

This improved version maintains all the original information while adhering to clean, professional Markdown formatting suitable for GitHub rendering.