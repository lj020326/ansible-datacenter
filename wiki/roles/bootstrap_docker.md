---
title: "Ansible Role - bootstrap_docker"
role: "bootstrap_docker"
category: "Infrastructure Automation"
type: "Role Documentation"

## Summary

The `bootstrap_docker` Ansible role is designed to automate the installation and configuration of Docker on various Linux distributions, including support for Docker Swarm setup. It handles package management, repository configuration, daemon settings, user management, and swarm node configurations. This role supports both Community Edition (CE) and Enterprise Edition (EE) installations.

## Variables

The following table lists the configurable variables along with their default values and descriptions:

| Variable Name                             | Default Value                                                                                           | Description                                                                                                                                                                                                 |
|-------------------------------------------|---------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_docker__actions_allowed`       | `['install', 'setup-swarm']`                                                                          | List of allowed actions that can be performed by the role.                                                                                                                                                  |
| `bootstrap_docker__actions`               | `['install', 'setup-swarm']`                                                                          | List of actions to perform during the playbook run.                                                                                                                                                           |
| `bootstrap_docker__config`                | `{}`                                                                                                    | Custom configuration options for Docker daemon.                                                                                                                                                               |
| `bootstrap_docker__options_prefix`        | `"{{ role_name }}__options__"`                                                                        | Prefix used to identify custom Docker options variables.                                                                                                                                                    |
| `bootstrap_docker__options_regex`         | `"^{{ bootstrap_docker__options_prefix }}"`                                                              | Regular expression for matching custom Docker options variables.                                                                                                                                            |
| `bootstrap_docker__arch`                  | `"{{ 'arm64' if ansible_facts.machine == 'aarch64' else 'amd64' }}"`                                      | Architecture of the system (automatically detected).                                                                                                                                                        |
| `bootstrap_docker__edition`               | `ce`                                                                                                    | Docker edition to install (`ce` for Community Edition, `ee` for Enterprise Edition).                                                                                                                        |
| `bootstrap_docker__repo`                  | `docker`                                                                                                | Repository source for Docker installation (`docker`, `rhsm`, or `other`).                                                                                                                                   |
| `bootstrap_docker__channel`               | `stable`                                                                                                | Channel to use for Docker installation (e.g., `stable`, `test`, `nightly`).                                                                                                                               |
| `bootstrap_docker__ee_version`            | `24.09`                                                                                                 | Version of Docker EE to install if using the Enterprise Edition.                                                                                                                                            |
| `bootstrap_docker__k8s_mode`              | `false`                                                                                                 | Enable Kubernetes integration mode (not fully implemented).                                                                                                                                                 |
| `bootstrap_docker__rhsm_channel`          | `"Example_Docker_Community_Edition_CE_Docker_CE_Stable_RHEL{{ ansible_facts['distribution_major_version'] }}"` | Red Hat Subscription Manager channel for Docker EE.                                                                                                                                                       |
| `bootstrap_docker__deploy_registry_certs` | `true`                                                                                                  | Deploy registry certificates to secure Docker communication with private registries.                                                                                                                        |
| `bootstrap_docker__service_manage`        | `true`                                                                                                  | Manage the Docker service (start, stop, restart).                                                                                                                                                           |
| `bootstrap_docker__service_state`         | `started`                                                                                               | Desired state of the Docker service (`started`, `stopped`).                                                                                                                                                 |
| `bootstrap_docker__service_enabled`       | `true`                                                                                                  | Enable the Docker service to start on boot.                                                                                                                                                                 |
| `bootstrap_docker__daemon_flags`          | `['-H unix:///var/run/docker.sock']`                                                                    | Flags to pass to the Docker daemon at startup.                                                                                                                                                              |
| `bootstrap_docker__swarm_leader_host`     | `test123`                                                                                               | Hostname or IP address of the swarm leader node.                                                                                                                                                            |
| `bootstrap_docker__swarm_manager`         | `false`                                                                                                 | Designate this node as a Docker Swarm manager.                                                                                                                                                              |
| `bootstrap_docker__swarm_leader`          | `false`                                                                                                 | Designate this node as the Docker Swarm leader.                                                                                                                                                             |
| `bootstrap_docker__swarm_worker`          | `false`                                                                                                 | Designate this node as a Docker Swarm worker.                                                                                                                                                               |
| `bootstrap_docker__swarm_node`            | `"{{ (bootstrap_docker__swarm_manager or bootstrap_docker__swarm_leader or bootstrap_docker__swarm_worker) \| bool }}"` | Determine if the node is part of a Docker Swarm.                                                                                                                                                            |
| `bootstrap_docker__swarm_role`            | `"{{ 'manager' if (bootstrap_docker__swarm_leader or bootstrap_docker__swarm_manager) else 'worker' }}"`   | Role of the node in the Docker Swarm (`manager`, `worker`).                                                                                                                                                 |
| `bootstrap_docker__swarm_leave`           | `false`                                                                                                 | Remove this node from the Docker Swarm.                                                                                                                                                                     |
| `bootstrap_docker__swarm_adv_addr`        | `"{{ ansible_facts['default_ipv4']['address'] }}"`                                                       | Advertise address for the Docker Swarm manager.                                                                                                                                                             |
| `bootstrap_docker__swarm_managers`        | `[]`                                                                                                    | List of swarm manager nodes.                                                                                                                                                                                |
| `bootstrap_docker__swarm_state`           | `present`                                                                                               | Desired state of the Docker Swarm (`present`, `absent`).                                                                                                                                                    |

## Usage

To use this role, include it in your playbook and specify any variables you wish to override:

```yaml
- hosts: all
  roles:
    - role: bootstrap_docker
      vars:
        bootstrap_docker__edition: ee
        bootstrap_docker__ee_version: 24.09
        bootstrap_docker__swarm_manager: true
        bootstrap_docker__swarm_leader_host: manager1.example.com
```

## Dependencies

This role depends on the following Ansible collections:

- `community.docker`
- `community.general`

Ensure these collections are installed in your environment before running this role:

```bash
ansible-galaxy collection install community.docker community.general
```

## Best Practices

- **Variable Naming**: Use variables to customize the role behavior rather than hardcoding values.
- **Security**: Ensure that sensitive information, such as passwords or tokens, is managed securely using Ansible Vault.
- **Testing**: Test the role in a development environment before deploying it to production.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_docker/defaults/main.yml)
- [tasks/deploy_registry_cert.yml](../../roles/bootstrap_docker/tasks/deploy_registry_cert.yml)
- [tasks/docker_compose.yml](../../roles/bootstrap_docker/tasks/docker_compose.yml)
- [tasks/apt.yml](../../roles/bootstrap_docker/tasks/apt.yml)
- [tasks/dnf-rhsm.yml](../../roles/bootstrap_docker/tasks/dnf-rhsm.yml)
- [tasks/dnf.yml](../../roles/bootstrap_docker/tasks/dnf.yml)
- [tasks/debian-9.yml](../../roles/bootstrap_docker/tasks/debian-9.yml)
- [tasks/debian.yml](../../roles/bootstrap_docker/tasks/debian.yml)
- [tasks/yum-rhsm.yml](../../roles/bootstrap_docker/tasks/yum-rhsm.yml)
- [tasks/yum.yml](../../roles/bootstrap_docker/tasks/yum.yml)
- [tasks/deploy_config.yml](../../roles/bootstrap_docker/tasks/deploy_config.yml)
- [tasks/docker_users.yml](../../roles/bootstrap_docker/tasks/docker_users.yml)
- [tasks/centos.yml](../../roles/bootstrap_docker/tasks/centos.yml)
- [tasks/fedora.yml](../../roles/bootstrap_docker/tasks/fedora.yml)
- [tasks/oraclelinux.yml](../../roles/bootstrap_docker/tasks/oraclelinux.yml)
- [tasks/redhat.yml](../../roles/bootstrap_docker/tasks/redhat.yml)
- [tasks/ubuntu.yml](../../roles/bootstrap_docker/tasks/ubuntu.yml)
- [tasks/ensure_multiarch_builder.yml](../../roles/bootstrap_docker/tasks/ensure_multiarch_builder.yml)
- [tasks/init-vars.yml](../../roles/bootstrap_docker/tasks/init-vars.yml)
- [tasks/install.yml](../../roles/bootstrap_docker/tasks/install.yml)
- [tasks/lvm_cleanup.yml](../../roles/bootstrap_docker/tasks/lvm_cleanup.yml)
- [tasks/lvm_setup.yml](../../roles/bootstrap_docker/tasks/lvm_setup.yml)
- [tasks/main.yml](../../roles/bootstrap_docker/tasks/main.yml)
- [tasks/other_repo.yml](../../roles/bootstrap_docker/tasks/other_repo.yml)
- [tasks/proxy.yml](../../roles/bootstrap_docker/tasks/proxy.yml)
- [tasks/aufs.yml](../../roles/bootstrap_docker/tasks/aufs.yml)
- [tasks/btrfs.yml](../../roles/bootstrap_docker/tasks/btrfs.yml)
- [tasks/devicemapper.yml](../../roles/bootstrap_docker/tasks/devicemapper.yml)
- [tasks/overlay.yml](../../roles/bootstrap_docker/tasks/overlay.yml)
- [tasks/overlay2.yml](../../roles/bootstrap_docker/tasks/overlay2.yml)
- [tasks/zfs.yml](../../roles/bootstrap_docker/tasks/zfs.yml)
- [tasks/swarm_ingress_network.yml](../../roles/bootstrap_docker/tasks/swarm_ingress_network.yml)
- [tasks/swarm_leader.yml](../../roles/bootstrap_docker/tasks/swarm_leader.yml)
- [tasks/swarm_leave.yml](../../roles/bootstrap_docker/tasks/swarm_leave.yml)
- [tasks/swarm_manager.yml](../../roles/bootstrap_docker/tasks/swarm_manager.yml)
- [tasks/swarm_node.yml](../../roles/bootstrap_docker/tasks/swarm_node.yml)
- [tasks/swarm_node_rejoin.yml](../../roles/bootstrap_docker/tasks/swarm_node_rejoin.yml)
- [tasks/swarm_setup.yml](../../roles/bootstrap_docker/tasks/swarm_setup.yml)
- [tasks/swarm_worker.yml](../../roles/bootstrap_docker/tasks/swarm_worker.yml)
- [handlers/main.yml](../../roles/bootstrap_docker/handlers/main.yml)