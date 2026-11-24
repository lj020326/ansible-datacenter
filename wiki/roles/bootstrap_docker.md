---
title: "Bootstrap Docker Role"
role: roles/bootstrap_docker
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_docker]
---

# Bootstrap Docker Role

## Overview

The `bootstrap_docker` role is designed to automate the installation and configuration of Docker on various Linux distributions. It supports both Docker Community Edition (CE) and Docker Enterprise Edition (EE), and includes features for setting up Docker Swarm, configuring multi-architecture builders, and managing Docker users.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_docker__actions_allowed` | `['install', 'setup-swarm']` | List of allowed actions for the role. |
| `bootstrap_docker__actions` | `['install', 'setup-swarm']` | List of actions to be performed by the role. |
| `bootstrap_docker__config` | `{}` | Configuration dictionary for Docker. |
| `bootstrap_docker__options_prefix` | `{{ role_name }}__options__` | Prefix for Docker options variables. |
| `bootstrap_docker__options_regex` | `^{{ bootstrap_docker__options_prefix }}` | Regular expression for matching Docker options variables. |
| `bootstrap_docker__arch` | `{{ 'arm64' if ansible_facts.machine == 'aarch64' else 'amd64' }}` | Architecture for Docker installation. |
| `__bootstrap_docker__is_dgx` | `false` | Boolean indicating if the system is a DGX system. |
| `__bootstrap_docker__options_merged` | `{}` | Merged Docker options. |
| `bootstrap_docker__edition` | `ce` | Docker edition to install (ce or ee). |
| `bootstrap_docker__repo` | `docker` | Repository source for Docker installation. |
| `bootstrap_docker__channel` | `stable` | Docker update channel. |
| `bootstrap_docker__ee_version` | `24.09` | Docker EE version. |
| `bootstrap_docker__k8s_mode` | `false` | Enable Kubernetes mode. |
| `bootstrap_docker__rhsm_channel` | `Example_Docker_Community_Edition_CE_Docker_CE_Stable_RHEL{{ ansible_facts['distribution_major_version'] }}` | RHSM channel for Docker. |
| `bootstrap_docker__deploy_registry_certs` | `true` | Deploy registry certificates. |
| `bootstrap_docker__service_manage` | `true` | Manage Docker service. |
| `bootstrap_docker__service_state` | `started` | Docker service state. |
| `bootstrap_docker__service_enabled` | `true` | Enable Docker service. |
| `bootstrap_docker__service_started` | `true` | Start Docker service. |
| `bootstrap_docker__service_restarted` | `true` | Restart Docker service. |
| `bootstrap_docker__multiarch_builder_enabled` | `true` | Enable multi-architecture builder. |
| `bootstrap_docker__multiarch_builder_driver` | `service` | Multi-architecture builder driver. |
| `bootstrap_docker__buildkit_version` | `v0.19.0` | BuildKit version. |
| `bootstrap_docker__buildkit_arch` | `linux-amd64` | BuildKit architecture. |
| `bootstrap_docker__buildkit_url` | `https://github.com/moby/buildkit/releases/download/{{ bootstrap_docker__buildkit_version }}/buildkit-{{ bootstrap_docker__buildkit_version }}.{{ bootstrap_docker__buildkit_arch }}.tar.gz` | BuildKit download URL. |
| `bootstrap_docker__buildkit_certs_dir` | `/etc/docker/buildx/certs.d` | BuildKit certificates directory. |
| `bootstrap_docker__daemon_flags` | `[-H unix:///var/run/docker.sock]` | Docker daemon flags. |
| `bootstrap_docker__swarm_leader_host` | `test123` | Docker Swarm leader host. |
| `bootstrap_docker__swarm_manager` | `false` | Enable Swarm manager. |
| `bootstrap_docker__swarm_leader` | `false` | Enable Swarm leader. |
| `bootstrap_docker__swarm_worker` | `false` | Enable Swarm worker. |
| `bootstrap_docker__swarm_node` | `{{ (bootstrap_docker__swarm_manager or bootstrap_docker__swarm_leader or bootstrap_docker__swarm_worker) | bool }}` | Enable Swarm node. |
| `bootstrap_docker__swarm_role` | `{{ 'manager' if (bootstrap_docker__swarm_leader or bootstrap_docker__swarm_manager) else 'worker' }}` | Swarm node role. |
| `bootstrap_docker__swarm_leave` | `false` | Leave Swarm. |
| `bootstrap_docker__swarm_adv_addr` | `{{ ansible_facts['default_ipv4']['address'] }}` | Swarm advertised address. |

## Usage

To use the `bootstrap_docker` role, include it in your playbook and configure the variables as needed:

```yaml
- hosts: all
  roles:
    - role: bootstrap_docker
      vars:
        bootstrap_docker__edition: "ee"
        bootstrap_docker__ee_url: "https://example.com/docker-ee"
        bootstrap_docker__swarm_manager: true
        bootstrap_docker__swarm_leader: true
        bootstrap_docker__multiarch_builder_enabled: true
        bootstrap_docker__buildkit_version: "v0.20.0"
```

### Configuring Docker Swarm

To configure Docker Swarm, set the appropriate variables:

```yaml
bootstrap_docker__swarm_manager: true
bootstrap_docker__swarm_leader: true
bootstrap_docker__swarm_adv_addr: "{{ ansible_facts['default_ipv4']['address'] }}"
```

### Configuring Multi-Architecture Builder

To enable and configure the multi-architecture builder:

```yaml
bootstrap_docker__multiarch_builder_enabled: true
bootstrap_docker__buildkit_version: "v0.20.0"
```

### Managing Docker Users

To add users to the Docker group:

```yaml
bootstrap_docker__docker_users:
  - username: "user1"
  - username: "user2"
```

## Dependencies

This role depends on the following Ansible modules:

- `community.docker.docker_container`
- `community.docker.docker_network`
- `community.docker.docker_node`
- `community.docker.docker_swarm`
- `community.docker.docker_swarm_info`
- `community.general.rhsm_repository`
- `community.general.ini_file`
- `ansible.builtin.apt`
- `ansible.builtin.package`
- `ansible.builtin.systemd`
- `ansible.builtin.file`
- `ansible.builtin.copy`
- `ansible.builtin.template`
- `ansible.builtin.command`
- `ansible.builtin.shell`
- `ansible.builtin.uri`
- `ansible.builtin.get_url`
- `ansible.builtin.pip`
- `ansible.builtin.user`
- `ansible.builtin.group`
- `ansible.builtin.service`
- `ansible.builtin.mount`
- `ansible.builtin.find`
- `ansible.builtin.debug`
- `ansible.builtin.set_fact`
- `ansible.builtin.assert`
- `ansible.builtin.include_tasks`
- `ansible.builtin.include_vars`
- `ansible.builtin.meta`
- `ansible.builtin.expect`

## Best Practices

- Ensure that the system meets the minimum requirements for Docker installation.
- Use the latest stable version of Docker.
- Regularly update Docker and its dependencies.
- Monitor Docker performance and resource usage.
- Implement security best practices for Docker, such as using least privilege principles and securing the Docker daemon.
- Configure appropriate storage drivers based on your workload and system capabilities.
- Properly manage Docker Swarm nodes and networks for high availability and scalability.
- Use multi-architecture builders to support different CPU architectures in your CI/CD pipelines.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_docker/defaults/main.yml) - Default variable values for the role.
- [tasks/deploy_registry_cert.yml](../../roles/bootstrap_docker/tasks/deploy_registry_cert.yml) - Tasks for deploying registry certificates.
- [tasks/docker_compose.yml](../../roles/bootstrap_docker/tasks/docker_compose.yml) - Tasks for configuring Docker Compose.
- [tasks/apt.yml](../../roles/bootstrap_docker/tasks/apt.yml) - Tasks for managing packages on Debian-based systems.
- [tasks/dnf-rhsm.yml](../../roles/bootstrap_docker/tasks/dnf-rhsm.yml) - Tasks for managing RHSM repositories on DNF-based systems.
- [tasks/dnf.yml](../../roles/bootstrap_docker/tasks/dnf.yml) - Tasks for managing packages on DNF-based systems.
- [tasks/debian-9.yml](../../roles/bootstrap_docker/tasks/debian-9.yml) - Tasks specific to Debian 9.
- [tasks/debian.yml](../../roles/bootstrap_docker/tasks/debian.yml) - Tasks for Debian-based systems.
- [tasks/yum-rhsm.yml](../../roles/bootstrap_docker/tasks/yum-rhsm.yml) - Tasks for managing RHSM repositories on YUM-based systems.
- [tasks/yum.yml](../../roles/bootstrap_docker/tasks/yum.yml) - Tasks for managing packages on YUM-based systems.
- [tasks/deploy_config.yml](../../roles/bootstrap_docker/tasks/deploy_config.yml) - Tasks for deploying Docker configuration.
- [tasks/docker_users.yml](../../roles/bootstrap_docker/tasks/docker_users.yml) - Tasks for managing Docker users.
- [tasks/centos.yml](../../roles/bootstrap_docker/tasks/centos.yml) - Tasks specific to CentOS.
- [tasks/fedora.yml](../../roles/bootstrap_docker/tasks/fedora.yml) - Tasks specific to Fedora.
- [tasks/oraclelinux.yml](../../roles/bootstrap_docker/tasks/oraclelinux.yml) - Tasks specific to Oracle Linux.
- [tasks/redhat.yml](../../roles/bootstrap_docker/tasks/redhat.yml) - Tasks specific to Red Hat.
- [tasks/ubuntu.yml](../../roles/bootstrap_docker/tasks/ubuntu.yml) - Tasks specific to Ubuntu.
- [tasks/ensure_multiarch_builder.yml](../../roles/bootstrap_docker/tasks/ensure_multiarch_builder.yml) - Tasks for ensuring multi-architecture builder is set up.
- [tasks/init-vars.yml](../../roles/bootstrap_docker/tasks/init-vars.yml) - Tasks for initializing variables.
- [tasks/install.yml](../../roles/bootstrap_docker/tasks/install.yml) - Tasks for installing Docker.
- [tasks/lvm_cleanup.yml](../../roles/bootstrap_docker/tasks/lvm_cleanup.yml) - Tasks for cleaning up LVM configurations.
- [tasks/lvm_setup.yml](../../roles/bootstrap_docker/tasks/lvm_setup.yml) - Tasks for setting up LVM.
- [tasks/main.yml](../../roles/bootstrap_docker/tasks/main.yml) - Main tasks for the role.
- [tasks/other_repo.yml](../../roles/bootstrap_docker/tasks/other_repo.yml) - Tasks for managing other repositories.
- [tasks/proxy.yml](../../roles/bootstrap_docker/tasks/proxy.yml) - Tasks for configuring proxy settings.
- [tasks/aufs.yml](../../roles/bootstrap_docker/tasks/aufs.yml) - Tasks for configuring AUFS storage driver.
- [tasks/btrfs.yml](../../roles/bootstrap_docker/tasks/btrfs.yml) - Tasks for configuring Btrfs storage driver.
- [tasks/devicemapper.yml](../../roles/bootstrap_docker/tasks/devicemapper.yml) - Tasks for configuring DeviceMapper storage driver.
- [tasks/overlay.yml](../../roles/bootstrap_docker/tasks/overlay.yml) - Tasks for configuring Overlay storage driver.
- [tasks/overlay2.yml](../../roles/bootstrap_docker/tasks/overlay2.yml) - Tasks for configuring Overlay2 storage driver.
- [tasks/zfs.yml](../../roles/bootstrap_docker/tasks/zfs.yml) - Tasks for configuring ZFS storage driver.
- [tasks/swarm_ingress_network.yml](../../roles/bootstrap_docker/tasks/swarm_ingress_network.yml) - Tasks for configuring Swarm ingress network.
- [tasks/swarm_leader.yml](../../roles/bootstrap_docker/tasks/swarm_leader.yml) - Tasks for configuring Swarm leader.
- [tasks/swarm_leave.yml](../../roles/bootstrap_docker/tasks/swarm_leave.yml) - Tasks for leaving Swarm.
- [tasks/swarm_manager.yml](../../roles/bootstrap_docker/tasks/swarm_manager.yml) - Tasks for configuring Swarm manager.
- [tasks/swarm_node.yml](../../roles/bootstrap_docker/tasks/swarm_node.yml) - Tasks for configuring Swarm node.
- [tasks/swarm_node_rejoin.yml](../../roles/bootstrap_docker/tasks/swarm_node_rejoin.yml) - Tasks for re-joining Swarm node.
- [tasks/swarm_setup.yml](../../roles/bootstrap_docker/tasks/swarm_setup.yml) - Tasks for setting up Swarm.
- [tasks/swarm_worker.yml](../../roles/bootstrap_docker/tasks/swarm_worker.yml) - Tasks for configuring Swarm worker.
- [handlers/main.yml](../../roles/bootstrap_docker/handlers/main.yml) - Handlers for the role.