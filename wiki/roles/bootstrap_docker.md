---
title: "Ansible Role - bootstrap_docker"
role: bootstrap_docker
category: Docker Management
type: Ansible Role
tags: docker, swarm, ansible, containerization

---

## Summary

The `bootstrap_docker` Ansible role is designed to automate the installation and configuration of Docker on various Linux distributions. It supports both Community Edition (CE) and Enterprise Edition (EE) installations, handles Docker Swarm setup for clustering, manages Docker daemon configurations, and ensures proper user permissions. The role also includes tasks for deploying registry certificates, setting up storage drivers, and configuring proxy settings.

## Variables

| Variable Name                           | Default Value                                                                                       | Description                                                                                                                                                                                                 |
|-----------------------------------------|-----------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_docker__actions_allowed`     | `['install', 'setup-swarm']`                                                                      | List of allowed actions that can be performed by the role.                                                                                                                                               |
| `bootstrap_docker__actions`             | `['install', 'setup-swarm']`                                                                      | List of actions to perform during playbook execution.                                                                                                                                                    |
| `bootstrap_docker__config`              | `{}`                                                                                                | Custom configuration options for Docker.                                                                                                                                                                   |
| `bootstrap_docker__options_prefix`      | `"{{ role_name }}__options__"`                                                                    | Prefix used to identify custom Docker options variables.                                                                                                                                                 |
| `bootstrap_docker__options_regex`       | `"^{{ bootstrap_docker__options_prefix }}"`                                                       | Regular expression to match custom Docker options variables.                                                                                                                                             |
| `bootstrap_docker__arch`                | `{{ 'arm64' if ansible_facts.machine == 'aarch64' else 'amd64' }}`                                 | Architecture of the system (automatically detected).                                                                                                                                                       |
| `bootstrap_docker__edition`             | `ce`                                                                                                | Docker edition to install (`ce` for Community Edition, `ee` for Enterprise Edition).                                                                                                                     |
| `bootstrap_docker__repo`                | `docker`                                                                                            | Repository to use for Docker installation (`docker`, `rhsm`, or `other`).                                                                                                                                |
| `bootstrap_docker__channel`             | `stable`                                                                                            | Channel for Docker installation (e.g., `stable`, `test`, `nightly`).                                                                                                                                     |
| `bootstrap_docker__ee_version`          | `24.09`                                                                                             | Version of Docker EE to install if using the Enterprise Edition.                                                                                                                                         |
| `bootstrap_docker__k8s_mode`            | `false`                                                                                             | Flag to indicate if running in Kubernetes mode (disables some configurations).                                                                                                                             |
| `bootstrap_docker__rhsm_channel`        | `Example_Docker_Community_Edition_CE_Docker_CE_Stable_RHEL{{ ansible_facts['distribution_major_version'] }}` | RedHat Subscription Manager channel for Docker EE.                                                                                                                                                     |
| `bootstrap_docker__deploy_registry_certs`| `true`                                                                                              | Flag to deploy registry certificates.                                                                                                                                                                      |
| `bootstrap_docker__service_manage`      | `true`                                                                                              | Manage the Docker service (start, stop, restart).                                                                                                                                                        |
| `bootstrap_docker__service_state`       | `started`                                                                                           | Desired state of the Docker service (`started`, `stopped`).                                                                                                                                              |
| `bootstrap_docker__service_enabled`     | `true`                                                                                              | Enable Docker service to start on boot.                                                                                                                                                                  |
| `bootstrap_docker__daemon_flags`        | `['-H unix:///var/run/docker.sock']`                                                              | Flags for the Docker daemon.                                                                                                                                                                               |
| `bootstrap_docker__swarm_leader_host`   | `test123`                                                                                           | Hostname of the swarm leader node.                                                                                                                                                                         |
| `bootstrap_docker__swarm_manager`       | `false`                                                                                             | Flag to indicate if the node is a manager in the Docker Swarm.                                                                                                                                           |
| `bootstrap_docker__swarm_leader`        | `false`                                                                                             | Flag to indicate if the node is the leader of the Docker Swarm.                                                                                                                                          |
| `bootstrap_docker__swarm_worker`        | `false`                                                                                             | Flag to indicate if the node is a worker in the Docker Swarm.                                                                                                                                            |
| `bootstrap_docker__swarm_node_labels`   | `{}`                                                                                                | Labels for the Docker Swarm node.                                                                                                                                                                          |

## Usage

To use the `bootstrap_docker` role, include it in your playbook and specify any required variables as needed. Below is an example of how to include this role in a playbook:

```yaml
---
- name: Bootstrap Docker on target hosts
  hosts: all
  become: yes
  roles:
    - role: bootstrap_docker
      vars:
        bootstrap_docker__actions: ['install', 'setup-swarm']
        bootstrap_docker__swarm_leader_host: "leader.example.com"
        bootstrap_docker__swarm_managers:
          - manager1.example.com
          - manager2.example.com
```

## Dependencies

- `community.docker` Ansible collection for Docker management tasks.
- `community.general` Ansible collection for various utility modules.

Ensure these collections are installed in your environment:

```bash
ansible-galaxy collection install community.docker community.general
```

## Best Practices

1. **Use Specific Versions**: Always specify the version of Docker to avoid unexpected changes during installation.
2. **Secure Configurations**: Ensure that Docker daemon flags and configurations are secure, especially when deploying in production environments.
3. **Swarm Management**: Clearly define swarm roles (leader, manager, worker) and ensure proper network communication between nodes.

## Molecule Tests

This role includes Molecule tests to verify its functionality across different Linux distributions. To run the tests:

```bash
molecule test -s <scenario_name>
```

Replace `<scenario_name>` with the appropriate scenario defined in the `molecule` directory of the role.

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
- [tasks/init-vars.yml](../../roles/bootstrap_docker/tasks/init-vars.yml)
- [tasks/install.yml](../../roles/bootstrap_docker/tasks/install.yml)
- [tasks/lvm_cleanup.yml](../../roles/bootstrap_docker/tasks/lvm_cleanup.yml)
- [tasks/lvm_setup.yml](../../roles/bootstrap_docker/tasks/lvm_setup.yml)
- [tasks/main.yml](../../roles/bootstrap_docker/tasks/main.yml)
- [tasks/other_repo.yml](../../roles/bootstrap_docker/tasks/other_repo.yml)
- [tasks/proxy.yml](../../roles/bootstrap_docker/tasks/proxy.yml)
- [tasks/aufs.yml](../../roles/bootstrap_docker/tasks/storage_drivers/aufs.yml)
- [tasks/btrfs.yml](../../roles/bootstrap_docker/tasks/storage_drivers/btrfs.yml)
- [tasks/devicemapper.yml](../../roles/bootstrap_docker/tasks/storage_drivers/devicemapper.yml)
- [tasks/overlay.yml](../../roles/bootstrap_docker/tasks/storage_drivers/overlay.yml)
- [tasks/overlay2.yml](../../roles/bootstrap_docker/tasks/storage_drivers/overlay2.yml)
- [tasks/zfs.yml](../../roles/bootstrap_docker/tasks/storage_drivers/zfs.yml)
- [tasks/swarm_ingress_network.yml](../../roles/bootstrap_docker/tasks/swarm/swarm_ingress_network.yml)
- [tasks/swarm_leader.yml](../../roles/bootstrap_docker/tasks/swarm/swarm_leader.yml)
- [tasks/swarm_leave.yml](../../roles/bootstrap_docker/tasks/swarm/swarm_leave.yml)
- [tasks/swarm_manager.yml](../../roles/bootstrap_docker/tasks/swarm/swarm_manager.yml)
- [tasks/swarm_node.yml](../../roles/bootstrap_docker/tasks/swarm/swarm_node.yml)
- [tasks/swarm_node_rejoin.yml](../../roles/bootstrap_docker/tasks/swarm/swarm_node_rejoin.yml)
- [tasks/swarm_setup.yml](../../roles/bootstrap_docker/tasks/swarm/swarm_setup.yml)
- [tasks/swarm_worker.yml](../../roles/bootstrap_docker/tasks/swarm/swarm_worker.yml)
- [handlers/main.yml](../../roles/bootstrap_docker/handlers/main.yml)