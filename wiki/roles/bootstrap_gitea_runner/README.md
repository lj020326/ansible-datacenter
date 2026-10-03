---
harvested_date: '2026-08-07T18:07:09.217606+00:00'
original_path: roles/bootstrap_gitea_runner/README.md
source_type: legacy_markdown
title: Bootstrap Gitea Runner Role Documentation
category: Ansible Roles
tags:
  - Gitea
  - CI/CD
  - Docker
  - Automation
---

# Bootstrap Gitea Runner Role Documentation

## Summary

The `bootstrap_gitea_runner` role is designed to automate the setup and configuration of a Gitea Act Runner on a target host. This includes installing necessary packages, setting up a dedicated user and group for the runner, configuring Docker if required, creating the work directory, and generating a registration token via the Gitea API.

## Variables

Below are the configurable variables for this role:

| Variable Name                             | Default Value                                                                                   | Description                                                                                                                                 |
|-------------------------------------------|-------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_gitea_runner__gitea_url`       | `"http://your_gitea_instance.com:3000"`                                                         | The URL of your Gitea instance. Replace with the actual URL of your Gitea server.                                                           |
| `bootstrap_gitea_runner__work_dir`        | `"/var/lib/gitea-runner"`                                                                       | Directory where the runner will store its work files.                                                                                          |
| `bootstrap_gitea_runner__user`            | `"gitea-runner"`                                                                                | The user under which the act_runner service will run.                                                                                        |
| `bootstrap_gitea_runner__group`           | `"gitea-runner"`                                                                                | The group associated with the act_runner service.                                                                                            |
| `bootstrap_gitea_runner__version`         | `"0.2.10"`                                                                                      | Specifies the desired version of the act_runner to be installed.                                                                             |
| `bootstrap_gitea_runner__docker_install`  | `false`                                                                                         | Set to `true` if Docker needs to be installed on the target host; otherwise, set to `false`.                                                   |
| `bootstrap_gitea_runner__labels`          | `"linux,x64,ubuntu-latest"`                                                                     | Labels for the runner, used by Gitea to assign jobs. Comma-separated values are accepted.                                                      |
| `bootstrap_gitea_runner__arch`            | `{{ 'arm64' if ansible_facts.machine == 'aarch64' else 'amd64' }}`                                 | Architecture of the target host, automatically detected based on `ansible_facts`.                                                            |
| `bootstrap_gitea_runner__packages`        | `[curl, git, ca-certificates, gnupg]`                                                           | List of packages required for Docker installation and basic utilities.                                                                         |

## Usage

To use this role in your Ansible playbook, include it as follows:

```yaml
- name: Bootstrap Gitea Runner
  hosts: gitea_runners
  roles:
    - role: bootstrap_gitea_runner
      vars:
        bootstrap_gitea_runner__gitea_url: "http://your-gitea-instance.com:3000"
        bootstrap_gitea_runner__docker_install: true
```

Ensure that the necessary variables are set according to your environment. If Docker is already installed on the target hosts, you can set `bootstrap_gitea_runner__docker_install` to `false`.

## Dependencies

- **Docker**: Required if `bootstrap_gitea_runner__docker_install` is set to `true`. The role will install Docker and related packages.
- **Gitea API Token**: Ensure that a Gitea admin token or username/password credentials are provided for generating the runner registration token. You can obtain a Gitea API token by logging into your Gitea instance as an admin, navigating to your profile settings, and generating a new token with the necessary permissions.

## Best Practices

1. **Security**: Always use secure methods to handle sensitive information such as tokens and passwords. Consider using Ansible Vault to encrypt sensitive data. For example:
   ```yaml
   bootstrap_gitea_runner__gitea_token: "{{ vault_gitea_token }}"
   ```
2. **Version Control**: Specify the version of `act_runner` to avoid unexpected changes due to updates.
3. **Testing**: Use Molecule for testing your role in different environments to ensure it behaves as expected. Molecule is a testing framework for Ansible roles that allows you to test your role in isolated environments.

## Molecule Tests

This role includes Molecule tests to verify its functionality across various scenarios. To run the tests, navigate to the role directory and execute:

```bash
molecule test
```

Ensure that all dependencies are installed before running the tests. Molecule is a tool that helps you test and validate your Ansible roles in isolated environments.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_gitea_runner/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_gitea_runner/tasks/main.yml)
- [handlers/main.yml](../../roles/bootstrap_gitea_runner/handlers/main.yml)

---

This documentation provides a comprehensive overview of the `bootstrap_gitea_runner` role, including its purpose, configuration options, usage instructions, and best practices.