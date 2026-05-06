---
title: Bootstrap Docker Role Documentation
role: bootstrap_docker
category: Ansible Roles
type: Infrastructure Automation
tags: docker, ansible, swarm, containerization

---

## Summary

The `bootstrap_docker` role is designed to automate the installation and configuration of Docker on various Linux distributions. It supports both Community Edition (CE) and Enterprise Edition (EE) installations, as well as setting up Docker Swarm for cluster management. The role handles package management, repository setup, daemon configuration, user management, and Docker Compose installation.

## Variables

The following variables are available to configure the `bootstrap_docker` role:

| Variable Name                             | Default Value                                                                                           | Description                                                                                                                                                                                                 |
|-------------------------------------------|---------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_docker__actions_allowed`       | `['install', 'setup-swarm']`                                                                          | List of allowed actions for this role.                                                                                                                                                                      |
| `bootstrap_docker__actions`               | `['install', 'setup-swarm']`                                                                          | Actions to be performed by the role, must be a subset of `bootstrap_docker__actions_allowed`.                                                                                                           |
| `bootstrap_docker__config`                | `{}`                                                                                                    | Custom configuration options for Docker.                                                                                                                                                                      |
| `bootstrap_docker__options_prefix`        | `"{{ role_name }}__options__"`                                                                        | Prefix used to identify custom options variables.                                                                                                                                                           |
| `bootstrap_docker__options_regex`         | `"^{{ bootstrap_docker__options_prefix }}"`                                                            | Regular expression for matching custom options variables.                                                                                                                                                   |
| `bootstrap_docker__edition`               | `ce`                                                                                                    | Docker edition to install (`ce` or `ee`).                                                                                                                                                                   |
| `bootstrap_docker__repo`                  | `docker`                                                                                                | Repository source for Docker packages (`docker`, `rhsm`, or `other`).                                                                                                                                        |
| `bootstrap_docker__channel`               | `stable`                                                                                                | Channel for Docker installation (e.g., `stable`, `test`, `nightly`).                                                                                                                                      |
| `bootstrap_docker__ee_version`            | `24.09`                                                                                                 | Version of Docker EE to install, if applicable.                                                                                                                                                             |
| `bootstrap_docker__k8s_mode`              | `false`                                                                                                 | Flag indicating whether the role is running in Kubernetes mode.                                                                                                                                             |
| `bootstrap_docker__rhsm_channel`          | `"Example_Docker_Community_Edition_CE_Docker_CE_Stable_RHEL{{ ansible_facts['distribution_major_version'] }}"` | Red Hat Subscription Manager channel for Docker EE installations.                                                                                                                                         |
| `bootstrap_docker__deploy_registry_certs` | `true`                                                                                                  | Flag indicating whether to deploy registry certificates.                                                                                                                                                      |
| `bootstrap_docker__service_manage`        | `true`                                                                                                  | Flag indicating whether the role should manage the Docker service.                                                                                                                                          |
| `bootstrap_docker__service_state`         | `started`                                                                                               | Desired state of the Docker service (`started`, `stopped`).                                                                                                                                                 |
| `bootstrap_docker__service_enabled`       | `true`                                                                                                  | Whether the Docker service should be enabled to start on boot.                                                                                                                                                |
| `bootstrap_docker__restart_handler_state` | `restarted`                                                                                             | State for restarting the Docker service (`restarted`, `reloaded`).                                                                                                                                            |
| `bootstrap_docker__service_started`       | `true`                                                                                                  | Flag indicating whether the Docker service should be started.                                                                                                                                               |
| `bootstrap_docker__daemon_flags`          | `['-H unix:///var/run/docker.sock']`                                                                    | Flags to pass to the Docker daemon at startup.                                                                                                                                                              |
| `bootstrap_docker__swarm_leader_host`     | `test123`                                                                                               | Hostname of the swarm leader node.                                                                                                                                                                          |
| `bootstrap_docker__swarm_manager`         | `false`                                                                                                 | Flag indicating whether this node should be a Docker Swarm manager.                                                                                                                                         |
| `bootstrap_docker__swarm_leader`          | `false`                                                                                                 | Flag indicating whether this node is the Docker Swarm leader.                                                                                                                                               |
| `bootstrap_docker__swarm_worker`          | `false`                                                                                                 | Flag indicating whether this node should be a Docker Swarm worker.                                                                                                                                          |
| `bootstrap_docker__swarm_node`            | `"{{ (bootstrap_docker__swarm_manager or bootstrap_docker__swarm_leader or bootstrap_docker__swarm_worker) \| bool }}"` | Calculated flag indicating whether this node is part of the Docker Swarm.                                                                                                                               |
| `bootstrap_docker__swarm_role`            | `"{{ 'manager' if (bootstrap_docker__swarm_leader or bootstrap_docker__swarm_manager) else 'worker' }}"` | Role of the node in the Docker Swarm (`manager`, `worker`).                                                                                                                                                 |
| `bootstrap_docker__swarm_leave`           | `false`                                                                                                 | Flag indicating whether this node should leave the Docker Swarm.                                                                                                                                            |
| `bootstrap_docker__swarm_adv_addr`        | `"{{ ansible_facts['default_ipv4']['address'] }}"`                                                      | Advertised address for the Docker Swarm node.                                                                                                                                                               |
| `bootstrap_docker__swarm_managers`        | `[]`                                                                                                    | List of manager nodes in the Docker Swarm.                                                                                                                                                                  |
| `bootstrap_docker__swarm_state`           | `present`                                                                                               | Desired state of the Docker Swarm (`present`, `absent`).                                                                                                                                                    |
| `bootstrap_docker__swarm_node_labels`     | `{}`                                                                                                    | Labels to assign to the Docker Swarm node.                                                                                                                                                                  |
| `bootstrap_docker__swarm_secrets`         | `[]`                                                                                                    | Secrets to manage in the Docker Swarm.                                                                                                                                                                      |
| `bootstrap_docker__features`              | `{'buildkit': true}`                                                                                    | Features to enable in Docker (e.g., BuildKit).                                                                                                                                                              |
| `bootstrap_docker__base_options`          | Various options like `api-cors-header`, `authorization-plugins`, etc.                               | Base configuration options for the Docker daemon.                                                                                                                                                           |

## Usage

To use this role, include it in your playbook and specify any necessary variables. Here is an example:

```yaml
- name: Bootstrap Docker on hosts
  hosts: all
  roles:
    - role: bootstrap_docker
      vars:
        bootstrap_docker__edition: ce
        bootstrap_docker__swarm_manager: true
        bootstrap_docker__swarm_leader_host: manager1.example.com
```

## Dependencies

- `community.docker` collection for Docker management tasks.
- `community.general` collection for various utility modules.

Ensure these collections are installed:

```bash
ansible-galaxy collection install community.docker community.general
```

## Tags

The role uses the following tags to allow selective task execution:

- `docker-install`: Tasks related to Docker installation.
- `swarm-setup`: Tasks related to Docker Swarm setup and management.
- `registry-certs`: Tasks related to deploying registry certificates.

Example usage of tags:

```bash
ansible-playbook playbook.yml -t docker-install,swarm-setup
```

## Best Practices

- Always specify the desired actions in `bootstrap_docker__actions` to control what the role does.
- Use `bootstrap_docker__config` for custom Docker daemon configurations.
- Ensure that the correct repository and edition are specified based on your environment.

## Molecule Tests

This role includes Molecule tests to verify its functionality. To run the tests, ensure you have Molecule installed:

```bash
pip install molecule ansible-lint yamllint
```

Run the tests using:

```bash
molecule test
```

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_docker/defaults/main.yml)
- [tasks/deploy_registry_cert.yml](../../roles/bootstrap_docker/tasks/deploy_registry_cert.yml)
- [tasks/apt.yml](../../roles/bootstrap_docker/tasks/apt.yml)
- [tasks/dnf-rhsm.yml](../../roles/bootstrap_docker/tasks/dnf-rhsm.yml)
- [tasks/dnf.yml](../../roles/bootstrap_docker/tasks/dnf.yml)
- [tasks/debian-9.yml](../../roles/bootstrap_docker/tasks/debian-9.yml)
- [tasks/ubuntu.yml](../../roles/bootstrap_docker/tasks/ubuntu.yml)
- [tasks/yum-rhsm.yml](../../roles/bootstrap_docker/tasks/yum-rhsm.yml)
- [tasks/yum.yml](../../roles/bootstrap_docker/tasks/yum.yml)
- [tasks/deploy_config.yml](../../roles/bootstrap_docker/tasks/deploy_config.yml)
- [tasks/docker_users.yml](../../roles/bootstrap_docker/tasks/docker_users.yml)
- [tasks/oraclelinux.yml](../../roles/bootstrap_docker/tasks/oraclelinux.yml)
- [tasks/init-vars.yml](../../roles/bootstrap_docker/tasks/init-vars.yml)
- [tasks/install.yml](../../roles/bootstrap_docker/tasks/install.yml)
- [tasks/proxy.yml](../../roles/bootstrap_docker/tasks/proxy.yml)
- [tasks/storage_drivers/aufs.yml](../../roles/bootstrap_docker/tasks/storage_drivers/aufs.yml)
- [tasks/storage_drivers/btrfs.yml](../../roles/bootstrap_docker/tasks/storage_drivers/btrfs.yml)
- [tasks/storage_drivers/devicemapper.yml](../../roles/bootstrap_docker/tasks/storage_drivers/devicemapper.yml)
- [tasks/storage_drivers/overlay.yml](../../roles/bootstrap_docker/tasks/storage_drivers/overlay.yml)
- [tasks/storage_drivers/overlay2.yml](../../roles/bootstrap_docker/tasks/storage_drivers/overlay2.yml)
- [tasks/swarm_setup.yml](../../roles/bootstrap_docker/tasks/swarm_setup.yml)
- [handlers/main.yml](../../roles/bootstrap_docker/handlers/main.yml)

---

This documentation provides a comprehensive overview of the `bootstrap_docker` role, including its purpose, configuration options, usage instructions, and best practices.