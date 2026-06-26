```markdown
---
title: Ansible Role for Bootstrapping Pip
original_path: roles/bootstrap_pip/README.md
category: Ansible Roles
tags: [ansible, pip, python, virtualenv]
---

# Ansible Role: bootstrap_pip (for Python)

This Ansible role installs [Pip](https://pip.pypa.io) on Linux systems.

## Requirements

On RedHat/CentOS systems, you may need to have EPEL installed before running this role. You can use the `geerlingguy.repo-epel` role if you need a simple way to ensure it's installed.

## Role Variables

| Variable                              | Required | Default                               | Comments                                                                                                                                                                                                                                            |
|---------------------------------------|----------|---------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_pip__virtualenv_command`   | No       | `python3 -m venv`                     | Command to install pip virtualenv.                                                                                                                                                                                                                  |
| `bootstrap_pip__python_executable`    | No       | `python3.10`                          | Python executable to use, also determines the python executable to setup in the virtualenv.                                                                                                                                                    |
| `bootstrap_pip__env_force_rebuild`    | No       | `False`                               | Force the rebuild of any specified virtual envs.                                                                                                                                                                                                      |
| `bootstrap_pip__env_list__*`          | No       | `[]`                                  | Variables with prefix `bootstrap_pip__env_list__` are dereferenced and merged to a single list of pip environments to install. Each list should contain a list of `dicts`. Each `dict` defines the pip environment to setup. Options include: `pip_executable`, `version`, `virtualenv`, `virtualenv_command`, `extra_args`, `libraries`. Where `libraries` is a list of python libraries to setup in the respective pip env. |
| `bootstrap_pip__config_dir`           | No       | `{{ ansible_env.HOME }}/.config/pip`  | Pip configuration directory.                                                                                                                                                                                                                        |
| `bootstrap_pip__pip_version`          | No       | `latest`                              | Pip version to install.                                                                                                                                                                                                                               |
| `bootstrap_pip__lib_state`            | No       | `latest`                              | Pip library install state (`present`, `absent`).                                                                                                                                                                                                      |
| `bootstrap_pip__lib_priority_default` | No       | `100`                                 | Pip library install priority. An integer value to determine the order of the library install. One or more packages are installed at each priority order level.                                                                                           |
| `bootstrap_pip__libs`                 | No       | See `defaults/main.yml` for defaults. | Pip libraries to install. Each item may either be a string specifying the library name or dict specifying library `name` and optionally the install `priority` order.                                                                                    |
| `bootstrap_pip__environment_vars`     | No       | None                                  | Dict containing environment vars to use for pip install.                                                                                                                                                                                              |

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

- [Ansible Roles](../ansible_roles.md)
```

This improved version maintains the original content while adhering to clean, professional Markdown formatting suitable for GitHub rendering. It includes a YAML frontmatter with additional metadata and ensures clear structure with proper headings.