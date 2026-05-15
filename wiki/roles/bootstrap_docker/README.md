```markdown
---
title: Bootstrap Docker Role Documentation
original_path: roles/bootstrap_docker/README.md
category: Ansible Roles
tags: [docker, ansible, kubernetes, containerd]
---

# bootstrap_docker

## Role Summary

This role provides the following:
- Installation of Docker following Docker-Engine install procedures as documented by Docker.
- Management of kernel versions to ensure compatibility with Docker.

### Supported Operating Systems
- CentOS 8
- CentOS 9
- CentOS 10
- RedHat 8
- RedHat 9
- Ubuntu 22.04
- Ubuntu 24.04
- Ubuntu 26.04

## Important Considerations

### Role Purpose
This role installs Docker CE, Docker CLI, containerd.io, and optionally Docker Compose. It is designed for general Docker setups but can be adapted for Kubernetes by enabling `bootstrap_docker__k8s_mode: true`.

### Kubernetes Mode
When `bootstrap_docker__k8s_mode` is set to `true`, the role skips installing Docker CE and CLI (only installs containerd.io), skips configuring `daemon.json`, and skips starting the Docker service. This avoids conflicts with Kubernetes' containerd configuration, which should be handled by a separate role like `bootstrap_kubernetes`. Override this variable in your playbook or inventory:
```yaml
vars:
  bootstrap_docker__k8s_mode: true
```

### Packages
Packages are defined in OS-specific vars files (e.g., `vars/ubuntu.yml`). Uncomment or customize as needed.

### Daemon Configuration
Custom Docker daemon settings can be defined in `bootstrap_docker__daemon_json` (e.g., for storage drivers or logging).

### Users
Add users to the `docker` group using the `bootstrap_docker__users` list. This is skipped in Kubernetes mode.

### Troubleshooting
- If containerd configuration conflicts with Kubernetes, ensure `bootstrap_docker__k8s_mode` is set to `true`.
- Verify installation: `docker --version` (for Docker setups) or `containerd --version` (for K8s setups).
- Run with verbose mode for debugging: `ansible-playbook -vvv`.

## Quick Start

The philosophy behind this role is to make it easy to get started while providing flexibility and reusability through customizable variables.

## Requirements

This role requires Ansible 2.4 or higher. Requirements are listed in the metadata file.

If you rely on privilege escalation (e.g., `become: true`) with this role, you will need Ansible 2.2.1 or higher to take advantage of the fix for [Ansible issue #17490](https://github.com/ansible/ansible/issues/17490).

### Default Configuration
- The latest Docker CE version is installed.
- Docker disk cleanup occurs once a week.
- Docker container logs are sent to `journald`.

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

For more information about the variables, refer to the [Docker documentation](https://docs.docker.com/engine/reference/commandline/dockerd/).

| Variable | Required | Default | Comments                                                                                                                     |
|----------|----------|---------|------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_docker__actions` | No       | `['install']` | Actions for role to perform. Allowed choices are `['install', 'setup-swarm']`.                     |
| `bootstrap_docker__edition` | No       | `ce`        | Specifies either `ce` or `ee` version of Docker.                                                   |
| `bootstrap_docker__ee_url`  | No       | `Undefined` | Docker EE URL from the Docker Store.                                                               |
| `bootstrap_docker__repo`    | No       | `docker`    | Defines how Ansible manages the repository. Options are `"other"` and `"docker"`.                  |
| `bootstrap_docker__channel` | No       | `stable`    | What release channel of Docker to install.                                                         |
| `bootstrap_docker__ee_version` | No     | `24.09`     | Docker EE version for EE repository.                                                               |
| `bootstrap_docker__storage_driver` | No | `Undefined` | Storage driver to use.                                                                           |
| `bootstrap_docker__block_device` | No   | `Undefined` | The device name used for the storage driver.                                                       |
| `bootstrap_docker__mount_opts` | No     | `Undefined` | The mount options when mounting filesystems.                                                     |
| `bootstrap_docker__storage_opts` | No   | `Undefined` | Storage driver options.                                                                          |
| `bootstrap_docker__api_cors_header` | No | `Undefined` | Set CORS headers in the remote API.                                                              |
| `bootstrap_docker__authorization_plugins` | No | `Undefined` | Authorization plugins to load.                                                               |
| `bootstrap_docker__bip` | No         | `Undefined` | Specify network bridge IP.                                                                         |
| `bootstrap_docker__bridge` | No       | `Undefined` | Attach containers to a network bridge.                                                             |
| `bootstrap_docker__cgroup_parent` | No  | `Undefined` | Set parent cgroup for all containers.                                                            |
| `bootstrap_docker__cluster_store` | No  | `Undefined` | Key-value store endpoint URL.                                                                    |

## Backlinks

- [Ansible Roles](/ansible-roles)
- [Docker Installation Guide](https://docs.docker.com/engine/install/)
```

This improved documentation is now clean, professional, and adheres to Markdown standards for GitHub rendering.