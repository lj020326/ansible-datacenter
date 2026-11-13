---
title: "Bootstrap Gitea Runner Role"
role: bootstrap_gitea_runner
category: CI/CD
type: role
tags: [ansible, role, bootstrap_gitea_runner]
---

# Bootstrap Gitea Runner Role

The `bootstrap_gitea_runner` role is designed to automate the setup and configuration of a Gitea runner on a target system. This role handles the installation of required packages, creation of necessary user accounts, and configuration of the Gitea runner service. It also supports optional Docker installation and configuration, making it versatile for different environments.

## Variables

| Variable Name                                | Default Value                                                                 | Description                                                                 |
|----------------------------------------------|-------------------------------------------------------------------------------|-----------------------------------------------------------------------------|
| `bootstrap_gitea_runner__gitea_url`          | `http://your_gitea_instance.com:3000`                                         | URL of the Gitea instance to register the runner with.                       |
| `bootstrap_gitea_runner__work_dir`           | `/var/lib/gitea-runner`                                                       | Directory where the runner will store its work files.                        |
| `bootstrap_gitea_runner__user`               | `gitea-runner`                                                               | User account under which the runner service will run.                        |
| `bootstrap_gitea_runner__group`              | `gitea-runner`                                                               | Group for the runner service.                                                |
| `bootstrap_gitea_runner__version`            | `0.2.10`                                                                      | Version of the Gitea runner to install.                                      |
| `bootstrap_gitea_runner__docker_install`     | `false`                                                                       | Whether to install Docker. Set to `true` if Docker is not already installed. |
| `bootstrap_gitea_runner__labels`             | `linux,x64,ubuntu-latest`                                                     | Comma-separated labels for the runner.                                       |
| `bootstrap_gitea_runner__arch`               | `{{ 'arm64' if ansible_facts.machine == 'aarch64' else 'amd64' }}`           | Architecture for Docker installation.                                        |
| `bootstrap_gitea_runner__packages`           | `curl, git, ca-certificates, gnupg`                                           | List of packages to install for Docker and basic utilities.                 |

## Usage

To use this role, include it in your playbook and set the necessary variables. Here is an example playbook:

```yaml
---
- hosts: gitea_runners
  roles:
    - role: bootstrap_gitea_runner
      vars:
        bootstrap_gitea_runner__gitea_url: "http://your_gitea_instance.com:3000"
        bootstrap_gitea_runner__gitea_admin_token: "your_gitea_admin_token"
        bootstrap_gitea_runner__docker_install: true
```

## Dependencies

This role does not have any external dependencies, but it assumes that the target system is a Debian-based distribution (e.g., Ubuntu). If you are using a different distribution, you may need to adjust the package installation tasks accordingly.

## Best Practices

- Ensure that the Gitea admin token has the necessary permissions to register runners.
- If Docker is already installed on the target system, set `bootstrap_gitea_runner__docker_install` to `false` to avoid conflicts.
- Regularly update the runner version to benefit from the latest features and security improvements.
- Test the role in a development environment before deploying it to production.
- Monitor the runner service logs for any potential issues.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_gitea_runner/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_gitea_runner/tasks/main.yml)
- [handlers/main.yml](../../roles/bootstrap_gitea_runner/handlers/main.yml)

## License

This role is licensed under the MIT License. See the [LICENSE](https://opensource.org/licenses/MIT) file for details.

## Author Information

This role was created by [Your Name](https://github.com/yourusername).

## Testing

To test this role, you can use Molecule with Docker. The role includes test scenarios that can be run using the following commands:

```bash
# Install Molecule and its dependencies
pip install molecule[docker]

# Create a test environment and converge the role
molecule test
```

## Troubleshooting

If you encounter issues with the role, check the following:

- Ensure that the Gitea instance is accessible from the target system.
- Verify that the Gitea admin token has the necessary permissions.
- Check the runner service logs for any error messages.
- If Docker is being installed, ensure that the target system meets the [Docker system requirements](https://docs.docker.com/engine/install/#prerequisites).