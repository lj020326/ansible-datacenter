---
harvested_date: '2026-08-07T18:07:09.180906+00:00'
original_path: roles/bootstrap_docker/README.md
source_type: legacy_markdown
title: bootstrap_docker Role Documentation
category: Ansible Roles
tags: [Docker, Ansible, CentOS, RedHat, Ubuntu, Kubernetes]
---

# bootstrap_docker Role Documentation

## Table of Contents
- [Role Summary](#role-summary)
- [Important Considerations](#important-considerations)
- [Quick Start](#quick-start)
- [Requirements](#requirements)
- [What's Configured by Default?](#whats-configured-by-default)
- [Example Playbook](#example-playbook)
- [Role Variables](#role-variables)
- [Related Roles](#related-roles)
- [Contributing](#contributing)

## Role Summary

This role provides the following:
- Installation of Docker following Docker-Engine install procedures as documented by Docker.
- Management of kernel versions to ensure the correct kernel for Docker support is installed.

Supports the following Operating Systems:
- CentOS 8
- CentOS 9
- CentOS 10
- RedHat 8
- RedHat 9
- Ubuntu 22.04
- Ubuntu 24.04

---

## Important Considerations

### Role Purpose
This role installs Docker CE, Docker CLI, containerd.io, and optionally Docker Compose. It is designed for general Docker setups but can be adapted for Kubernetes by enabling `bootstrap_docker__k8s_mode: true`.

### Kubernetes Mode
When `bootstrap_docker__k8s_mode` is set to `true`, the role skips installing Docker CE and CLI (only installs containerd.io), skips configuring daemon.json, and skips starting the Docker service. This avoids conflicts with Kubernetes' containerd configuration (handled by a separate role like bootstrap_kubernetes). Override the variable in your playbook or inventory:
  ```yaml
  vars:
    bootstrap_docker__k8s_mode: true
  ```

### Packages
Packages are defined in OS-specific vars files (e.g., vars/ubuntu.yml). Uncomment or customize as needed.

### Daemon Configuration
Custom Docker daemon settings can be defined in `bootstrap_docker__daemon_json` (e.g., for storage drivers or logging).

### Users
Add users to the `docker` group using `bootstrap_docker__users` list. Skipped in Kubernetes mode.

### Troubleshooting
- If containerd configuration conflicts with Kubernetes, ensure `bootstrap_docker__k8s_mode` is set to `true`.
- Verify installation: `docker --version` (for Docker setups) or `containerd --version` (for Kubernetes setups).
- Run with verbose: `ansible-playbook -vvv` to debug.

## Quick Start

To quickly get started with this role:

1. Include the role in your playbook:
   ```yaml
   - hosts: docker
     roles:
       - bootstrap_docker
   ```

2. Customize variables as needed in your playbook or inventory file.

## Requirements

This role requires Ansible 2.4 or higher. Requirements are listed in the metadata file.

If you rely on privilege escalation (e.g., `become: true`) with this role, you will need Ansible 2.2.1 or higher to take advantage of this issue being fixed: [Ansible Issue #17490](https://github.com/ansible/ansible/issues/17490)

## What's Configured by Default?

By default, the role will:
- Install the latest Docker-ce
- Configure Docker disk cleanup to happen once a week
- Send Docker container logs to `journald`

## Example Playbook

```yaml
---

# site.yml

- name: "Bootstrap docker nodes"
  hosts: docker,!host_offline
  tags:
    - bootstrap-docker
  become: True
  roles:
  - role: bootstrap_docker
```

## Role Variables

For more information about the variables, many can be found at [Docker Documentation](https://docs.docker.com/engine/reference/commandline/dockerd/)

| Variable | Required | Default | Comments |
|----------|----------|---------|----------|
| `bootstrap_docker__actions` | No | `['install']` | Actions for role to perform. Allowed/Supported choices are `['install', 'setup-swarm']` |
| `bootstrap_docker__edition` | No | `ce` | Specifies either `ce` or `ee` version of Docker. |
| `bootstrap_docker__ee_url` | No | `Undefined` | Docker EE URL from the Docker Store |
| `bootstrap_docker__repo` | No | `docker` | Defines how Ansible manages the repository. Options are "other" and "docker" |
| `bootstrap_docker__channel` | No | `stable` | What release channel of Docker to install. |
| `bootstrap_docker__ee_version` | No | `24.09` | Docker EE version for EE repository |
| `bootstrap_docker__storage_driver` | No | `Undefined` | Storage driver to use |
| `bootstrap_docker__block_device` | No | `Undefined` | The device name used for the storage driver. |
| `bootstrap_docker__mount_opts` | No | `Undefined` | The mount options when mounting filesystems |
| `bootstrap_docker__storage_opts` | No | `Undefined` | Storage driver options |
| `bootstrap_docker__api_cors_header` | No | `Undefined` | Set CORS headers in the remote API |
| `bootstrap_docker__authorization_plugins` | No | `Undefined` | Authorization plugins to load |
| `bootstrap_docker__bip` | No | `Undefined` | Specify network bridge IP |
| `bootstrap_docker__bridge` | No | `Undefined` | Attach containers to a network bridge |
| `bootstrap_docker__cgroup_parent` | No | `Undefined` | Set parent cgroup for all containers |
| `bootstrap_docker__cluster_store` | No | `Undefined` | Cluster store |

## Related Roles

- bootstrap_kubernetes: Role for setting up Kubernetes, which works in conjunction with this role when in Kubernetes mode.

## Contributing

If you'd like to contribute to this role, please follow these steps:
1. Fork the repository
2. Create a new branch for your feature or bugfix
3. Make your changes and commit them
4. Push to your fork and submit a pull request

Please include tests for any new features or bugfixes.

## License

This role is licensed under the MIT License. See the LICENSE file for details.