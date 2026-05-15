```markdown
---
title: Ansible Role for Bootstrapping Pip (for Python)
original_path: roles/bootstrap_pip/README.md
category: Ansible Roles
tags: ansible, pip, python, virtualenv
---

# Ansible Role: Bootstrap Pip (for Python)

This Ansible role installs [Pip](https://pip.pypa.io) on Linux systems.

## Requirements

On RedHat/CentOS, you may need to have EPEL installed before running this role. You can use the `geerlingguy.repo-epel` role if you need a simple way to ensure it's installed.

## Role Variables

| Variable                              | Required | Default                               | Comments                                                                                                                                                                                                                                                                                                                                                                            |
|---------------------------------------|----------|---------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_pip__virtualenv_command`   | No       | `python3 -m venv`                     | Command used to install pip virtualenv.                                                                                                                                                                                                                                                                                                                                             |
| `bootstrap_pip__python_executable`    | No       | `python3.10`                          | Python executable to use, which also determines the python executable in the virtualenv.                                                                                                                                                                                                                                                                                         |
| `bootstrap_pip__env_force_rebuild`    | No       | `False`                               | Force the rebuild of any specified virtual environments.                                                                                                                                                                                                                                                                                                                            |
| `bootstrap_pip__env_list__*`          | No       | `[]`                                  | Variables with the prefix `bootstrap_pip__env_list__` are dereferenced and merged into a single list of pip environments to install. Each list should contain a list of dictionaries, where each dictionary defines a pip environment. Dictionary options include: `pip_executable`, `version`, `virtualenv`, `virtualenv_command`, `extra_args`, `libraries`. The `libraries` option is a list of Python libraries to set up in the respective pip environment. |
| `bootstrap_pip__config_dir`           | No       | `{{ ansible_env.HOME }}/.config/pip`  | Directory for Pip configuration.                                                                                                                                                                                                                                                                                                                                                  |
| `bootstrap_pip__pip_version`          | No       | `latest`                              | Version of Pip to install.                                                                                                                                                                                                                                                                                                                                                          |
| `bootstrap_pip__lib_state`            | No       | `present`                             | State of Pip library installation (`present`, `absent`).                                                                                                                                                                                                                                                                                                                            |
| `bootstrap_pip__lib_priority_default` | No       | `100`                                 | Priority for Pip library installation. An integer value to determine the order of library installations. One or more packages are installed at each priority level.                                                                                                                                                                                                                      |
| `bootstrap_pip__libs`                 | No       | See `defaults/main.yml` for defaults. | List of Pip libraries to install. Each item can be a string specifying the library name or a dictionary specifying the library `name` and optionally the installation `priority`.                                                                                                                                                                                                        |
| `bootstrap_pip__environment_vars`     | No       | None                                  | Dictionary containing environment variables to use during pip installation.                                                                                                                                                                                                                                                                                                         |

## Example Playbook

```yaml
- hosts: all
  vars:
    bootstrap_pip__libs:
      - name: docker
      - name: awscli
  roles:
    - bootstrap_pip
```

## Example Playbook Defining Virtualenv

```yaml
- hosts: all
  vars:
    bootstrap_pip__env_list__docker:
      - virtualenv: "{{ bootstrap_docker__pip_virtualenv }}"
        libraries:
          - jsondiff
          - docker
          - docker-compose
  roles:
    - bootstrap_pip
```

## Backlinks

- [Ansible Roles](/ansible-roles)
```

This improved version maintains all the original information while adhering to clean, professional Markdown formatting suitable for GitHub rendering.