---
title: Bootstrap Gitea Runner Role Documentation
role: bootstrap_gitea_runner
category: Ansible Roles
type: Configuration Management
tags: gitea, runner, automation, ci/cd
---

## Summary

The `bootstrap_gitea_runner` role is designed to automate the setup of a Gitea Act Runner on a target host. This includes installing necessary packages, setting up a dedicated user and group for the runner, configuring Docker if required, creating the work directory, and registering the runner with a specified Gitea instance using an API token.

## Variables

| Variable Name                           | Default Value                                                                                          | Description                                                                                                                                                                                                 |
|-----------------------------------------|--------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_gitea_runner__gitea_url`     | `"http://your_gitea_instance.com:3000"`                                                                | The URL of your Gitea instance. Replace with the actual URL of your Gitea server.                                                                                                                          |
| `bootstrap_gitea_runner__work_dir`      | `"/var/lib/gitea-runner"`                                                                              | Directory where the runner will perform its work.                                                                                                                                                             |
| `bootstrap_gitea_runner__user`          | `"gitea-runner"`                                                                                       | The user under which the act_runner service will run.                                                                                                                                                         |
| `bootstrap_gitea_runner__group`         | `"gitea-runner"`                                                                                       | The group for the act_runner service.                                                                                                                                                                         |
| `bootstrap_gitea_runner__version`       | `"0.2.10"`                                                                                             | Specifies the desired version of the act_runner to be installed.                                                                                                                                            |
| `bootstrap_gitea_runner__docker_install`| `false`                                                                                                | Set to `true` if Docker needs to be installed; set to `false` if it is already installed on the target host.                                                                                                 |
| `bootstrap_gitea_runner__labels`        | `"linux,x64,ubuntu-latest"`                                                                            | Labels for the runner, used by Gitea to assign jobs to this runner. Comma-separated values are accepted.                                                                                                      |
| `bootstrap_gitea_runner__arch`          | `"{{ 'arm64' if ansible_facts.machine == 'aarch64' else 'amd64' }}"`                                     | Architecture of the target host, automatically detected based on `ansible_facts`.                                                                                                                             |
| `bootstrap_gitea_runner__packages`      | `[curl, git, ca-certificates, gnupg]`                                                                  | List of packages to be installed for Docker and basic utilities.                                                                                                                                            |

## Usage

To use this role, include it in your playbook and provide the necessary variables as shown below:

```yaml
- name: Bootstrap Gitea Runner
  hosts: gitea_runners
  become: yes
  roles:
    - role: bootstrap_gitea_runner
      vars:
        bootstrap_gitea_runner__gitea_url: "http://your-gitea-instance.com:3000"
        bootstrap_gitea_runner__docker_install: true
        bootstrap_gitea_runner__gitea_admin_token: "{{ gitea_admin_token }}"
```

Ensure that the `bootstrap_gitea_runner__gitea_admin_token` variable is securely provided, either through an Ansible Vault or another secure method.

## Dependencies

- **Docker**: If `bootstrap_gitea_runner__docker_install` is set to `true`, Docker will be installed as part of the role. This includes Docker Engine, containerd, and Docker Compose.
- **Packages**: The role installs a list of packages specified in `bootstrap_gitea_runner__packages`.

## Best Practices

- Always use a secure method for providing sensitive information such as API tokens.
- Ensure that the target host has internet access to download necessary packages and Docker images.
- Regularly update the `bootstrap_gitea_runner__version` variable to the latest stable version of act_runner.

## Molecule Tests

This role does not include any Molecule tests at this time. Consider adding Molecule scenarios for testing different configurations and edge cases.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_gitea_runner/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_gitea_runner/tasks/main.yml)
- [handlers/main.yml](../../roles/bootstrap_gitea_runner/handlers/main.yml)

---

This documentation provides a comprehensive overview of the `bootstrap_gitea_runner` role, including its purpose, configuration variables, usage instructions, and best practices.