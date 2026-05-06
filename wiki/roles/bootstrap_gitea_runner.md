---
title: Bootstrap Gitea Runner Role Documentation
role: bootstrap_gitea_runner
category: Ansible Roles
type: Configuration Management
tags: gitea, runner, docker, automation
---

## Summary

The `bootstrap_gitea_runner` role is designed to automate the setup of a Gitea Act Runner on a target system. This includes installing necessary packages, setting up a dedicated user and group for the runner, creating a work directory, and generating a registration token via the Gitea API. The role also supports optional Docker installation if required.

## Variables

| Variable Name                             | Default Value                                      | Description                                                                 |
|-------------------------------------------|----------------------------------------------------|-----------------------------------------------------------------------------|
| `bootstrap_gitea_runner__gitea_url`       | `"http://your_gitea_instance.com:3000"`            | The URL of your Gitea instance. Replace with your actual Gitea server URL.   |
| `bootstrap_gitea_runner__work_dir`        | `"/var/lib/gitea-runner"`                          | Directory where the runner will store its work files.                       |
| `bootstrap_gitea_runner__user`            | `"gitea-runner"`                                   | User under which the act_runner service will run.                           |
| `bootstrap_gitea_runner__group`           | `"gitea-runner"`                                   | Group for the act_runner service.                                           |
| `bootstrap_gitea_runner__version`         | `"0.2.10"`                                         | Version of the act_runner to be installed.                                  |
| `docker_install`                          | `false`                                            | Set to true if Docker needs to be installed; false if already installed.    |
| `bootstrap_gitea_runner__labels`          | `"linux,x64,ubuntu-latest"`                      | Labels for the runner (comma-separated).                                    |
| `bootstrap_gitea_runner__packages`        | `[curl, git, ca-certificates, gnupg]`              | List of packages to be installed on the system.                             |

## Usage

To use this role, include it in your playbook and provide the necessary variables:

```yaml
- hosts: all
  roles:
    - role: bootstrap_gitea_runner
      vars:
        bootstrap_gitea_runner__gitea_url: "http://your-gitea-instance.com:3000"
        docker_install: true
        bootstrap_gitea_runner__gitea_admin_token: "{{ gitea_admin_token }}"
```

Ensure that you have defined the `bootstrap_gitea_runner__gitea_admin_token` variable in your inventory or playbook, which is used to authenticate API requests for generating the registration token.

## Dependencies

- **Docker**: If `docker_install` is set to true, Docker will be installed along with necessary plugins and components.
- **Ansible Modules**: The role relies on standard Ansible modules such as `apt`, `user`, `file`, `uri`, etc.

## Tags

- `bootstrap_gitea_runner`: This tag can be used to target only the tasks related to this role during playbook execution.

## Best Practices

- Always ensure that the Gitea instance URL and admin token are correctly configured.
- If Docker is required, set `docker_install` to true. Otherwise, make sure Docker is already installed on the system.
- Use labels appropriately to categorize runners based on their capabilities or environment.

## Molecule Tests

Molecule tests for this role can be found in the `molecule/` directory within the role folder. To run the tests:

```bash
cd roles/bootstrap_gitea_runner/molecule/default
molecule test
```

Ensure that you have Molecule and its dependencies installed before running the tests.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_gitea_runner/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_gitea_runner/tasks/main.yml)
- [handlers/main.yml](../../roles/bootstrap_gitea_runner/handlers/main.yml)

---

This documentation provides a comprehensive overview of the `bootstrap_gitea_runner` role, including its purpose, configuration options, usage instructions, and best practices.