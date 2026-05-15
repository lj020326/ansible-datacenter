---
title: Bootstrap Gitea Runner Role Documentation
role: bootstrap_gitea_runner
category: Ansible Roles
type: Configuration Management
tags: gitea, runner, docker, automation
---

## Summary

The `bootstrap_gitea_runner` role is designed to automate the setup and configuration of a Gitea Act Runner on a target system. This includes installing necessary packages, setting up a dedicated user and group for the runner, creating a work directory, and optionally installing Docker if required. The role also handles the registration of the runner with a specified Gitea instance using an API token.

## Variables

| Variable Name                           | Default Value                                                                 | Description                                                                                                                                                                                                 |
|-----------------------------------------|-------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_gitea_runner__gitea_url`     | `"http://your_gitea_instance.com:3000"`                                       | The URL of your Gitea instance. Replace with the actual URL of your Gitea server.                                                                                                                         |
| `bootstrap_gitea_runner__work_dir`      | `"/var/lib/gitea-runner"`                                                   | Directory where the runner will perform its work.                                                                                                                                                           |
| `bootstrap_gitea_runner__user`          | `"gitea-runner"`                                                            | The user under which the act_runner service will run.                                                                                                                                                       |
| `bootstrap_gitea_runner__group`         | `"gitea-runner"`                                                            | The group for the act_runner service.                                                                                                                                                                       |
| `bootstrap_gitea_runner__version`       | `"0.2.10"`                                                                  | Specifies the desired version of the act_runner to be installed.                                                                                                                                            |
| `bootstrap_gitea_runner__docker_install`| `false`                                                                     | Set to `true` if Docker needs to be installed as part of this role; set to `false` if Docker is already installed on the system.                                                                              |
| `bootstrap_gitea_runner__labels`        | `"linux,x64,ubuntu-latest"`                                                 | Labels for the runner, used by Gitea to assign jobs to specific runners based on their labels (comma-separated).                                                                                             |
| `bootstrap_gitea_runner__arch`          | `{{ 'arm64' if ansible_facts.machine == 'aarch64' else 'amd64' }}`            | Architecture of the system, automatically detected based on `ansible_facts.machine`.                                                                                                                        |
| `bootstrap_gitea_runner__packages`      | `[curl, git, ca-certificates, gnupg]`                                         | List of packages to be installed for Docker and basic utilities.                                                                                                                                            |

## Usage

To use this role, include it in your playbook and provide the necessary variables as per your environment:

```yaml
- hosts: gitea_runners
  roles:
    - role: bootstrap_gitea_runner
      vars:
        bootstrap_gitea_runner__gitea_url: "http://your-gitea-instance.com:3000"
        bootstrap_gitea_runner__docker_install: true
        bootstrap_gitea_runner__labels: "linux,x64,ubuntu-latest"
```

Ensure that the `bootstrap_gitea_runner__gitea_admin_token` or both `bootstrap_gitea_runner__gitea_admin_user` and `bootstrap_gitea_runner__gitea_admin_passw` are provided for API authentication.

## Dependencies

- **Docker**: If `bootstrap_gitea_runner__docker_install` is set to `true`, Docker will be installed as part of this role.
- **Ansible Modules**: The role requires the following Ansible modules: `apt`, `apt_key`, `apt_repository`, `user`, `file`, `set_fact`, and `debug`.

## Best Practices

- Always ensure that the Gitea instance URL is correctly specified.
- Use a secure method to pass sensitive information such as API tokens or admin credentials.
- Regularly update the `bootstrap_gitea_runner__version` variable to use the latest version of act_runner.

## Molecule Tests

This role does not currently include Molecule tests. Consider adding them for automated testing and validation of the role's functionality.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_gitea_runner/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_gitea_runner/tasks/main.yml)
- [handlers/main.yml](../../roles/bootstrap_gitea_runner/handlers/main.yml)