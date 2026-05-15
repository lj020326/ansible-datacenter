---
title: Bootstrap Docker Role Documentation
role: bootstrap_docker
category: Ansible Roles
type: Infrastructure as Code
tags: docker, ansible, swarm, containerization

---

## Summary

The `bootstrap_docker` role is designed to automate the installation and configuration of Docker on various Linux distributions. It supports both Community Edition (CE) and Enterprise Edition (EE) installations, handles Docker Swarm setup, manages Docker daemon configurations, and ensures proper user permissions for Docker operations. This role also includes tasks for deploying registry certificates, setting up storage drivers, configuring proxy settings, and managing Docker Compose.

## Variables

Below is a table of all configurable variables in the `bootstrap_docker` role:

| Variable Name                             | Default Value                                                                                         | Description                                                                                                                                                                                                 |
|-------------------------------------------|-------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_docker__actions_allowed`       | `['install', 'setup-swarm']`                                                                        | List of allowed actions that can be performed by the role.                                                                                                                                              |
| `bootstrap_docker__actions`               | `['install', 'setup-swarm']`                                                                        | List of actions to perform during the playbook run.                                                                                                                                                    |
| `bootstrap_docker__config`                | `{}`                                                                                                  | Custom configuration options for Docker.                                                                                                                                                                    |
| `bootstrap_docker__options_prefix`        | `"{{ role_name }}__options__"`                                                                      | Prefix used for custom Docker options variables.                                                                                                                                                          |
| `bootstrap_docker__options_regex`         | `"^{{ bootstrap_docker__options_prefix }}"`                                                          | Regular expression to match custom Docker options variables.                                                                                                                                                |
| `bootstrap_docker__arch`                  | `"{{ 'arm64' if ansible_facts.machine == 'aarch64' else 'amd64' }}"`                                   | Architecture of the system (automatically detected).                                                                                                                                                      |
| `bootstrap_docker__edition`               | `ce`                                                                                                  | Docker edition to install (`ce` for Community Edition, `ee` for Enterprise Edition).                                                                                                                    |
| `bootstrap_docker__repo`                  | `docker`                                                                                                | Repository source for Docker installation (`docker`, `rhsm`, or `other`).                                                                                                                                |
| `bootstrap_docker__channel`               | `stable`                                                                                              | Channel to use for Docker installation (e.g., `stable`, `test`, `nightly`).                                                                                                                             |
| `bootstrap_docker__ee_version`            | `24.09`                                                                                               | Version of Docker EE to install.                                                                                                                                                                          |
| `bootstrap_docker__k8s_mode`              | `false`                                                                                               | Flag indicating whether the role is running in Kubernetes mode.                                                                                                                                         |
| `bootstrap_docker__rhsm_channel`          | `Example_Docker_Community_Edition_CE_Docker_CE_Stable_RHEL{{ ansible_facts['distribution_major_version'] }}` | RedHat Subscription Manager channel for Docker EE installation.                                                                                                                                       |
| `bootstrap_docker__deploy_registry_certs` | `true`                                                                                                | Flag to deploy registry certificates.                                                                                                                                                                     |
| `bootstrap_docker__service_manage`        | `true`                                                                                                | Flag to manage the Docker service (start, stop, restart).                                                                                                                                                |
| `bootstrap_docker__service_state`         | `started`                                                                                             | Desired state of the Docker service (`started`, `stopped`).                                                                                                                                             |
| `bootstrap_docker__service_enabled`       | `true`                                                                                                | Whether the Docker service should be enabled on boot.                                                                                                                                                   |
| `bootstrap_docker__daemon_flags`          | `['-H unix:///var/run/docker.sock']`                                                                | Flags to pass to the Docker daemon.                                                                                                                                                                       |
| `bootstrap_docker__swarm_leader_host`     | `test123`                                                                                             | Hostname of the swarm leader node.                                                                                                                                                                        |
| `bootstrap_docker__swarm_manager`         | `false`                                                                                               | Flag indicating whether this node is a swarm manager.                                                                                                                                                   |
| `bootstrap_docker__swarm_leader`          | `false`                                                                                               | Flag indicating whether this node is the swarm leader.                                                                                                                                                  |
| `bootstrap_docker__swarm_worker`          | `false`                                                                                               | Flag indicating whether this node is a swarm worker.                                                                                                                                                    |
| `bootstrap_docker__swarm_node`            | `"{{ (bootstrap_docker__swarm_manager or bootstrap_docker__swarm_leader or bootstrap_docker__swarm_worker) \| bool }}"` | Flag indicating whether this node is part of the swarm.                                                                                                                                                |
| `bootstrap_docker__swarm_role`            | `"{{ 'manager' if (bootstrap_docker__swarm_leader or bootstrap_docker__swarm_manager) else 'worker' }}"` | Role of the node in the swarm (`manager`, `worker`).                                                                                                                                                    |
| `bootstrap_docker__swarm_leave`           | `false`                                                                                               | Flag indicating whether this node should leave the swarm.                                                                                                                                               |
| `bootstrap_docker__swarm_adv_addr`        | `"{{ ansible_facts['default_ipv4']['address'] }}"`                                                    | Advertised address for the swarm node.                                                                                                                                                                    |
| `bootstrap_docker__swarm_managers`        | `[]`                                                                                                  | List of manager nodes in the swarm.                                                                                                                                                                       |
| `bootstrap_docker__swarm_state`           | `present`                                                                                             | Desired state of the Docker Swarm (`present`, `absent`).                                                                                                                                                |
| `bootstrap_docker__swarm_node_labels`     | `{}`                                                                                                  | Labels to apply to the node in the swarm.                                                                                                                                                                 |

## Usage

To use the `bootstrap_docker` role, include it in your playbook and specify any required variables:

```yaml
- name: Bootstrap Docker on target hosts
  hosts: all
  roles:
    - role: bootstrap_docker
      vars:
        bootstrap_docker__edition: ce
        bootstrap_docker__actions: ['install', 'setup-swarm']
        bootstrap_docker__swarm_leader_host: my_swarm_leader.example.com
        bootstrap_docker__swarm_managers:
          - manager1.example.com
          - manager2.example.com
```

## Dependencies

The `bootstrap_docker` role depends on the following Ansible collections:

- `community.docker`
- `community.general`

Ensure these collections are installed in your environment before running the role:

```bash
ansible-galaxy collection install community.docker community.general
```

## Best Practices

1. **Use Specific Versions**: Always specify a specific version of Docker to avoid unexpected changes.
2. **Secure Configurations**: Ensure secure configurations by setting appropriate permissions and using encrypted communication channels.
3. **Backup Certificates**: Regularly back up registry certificates and other critical configuration files.
4. **Monitor Swarm Health**: Continuously monitor the health and performance of your Docker Swarm cluster.

## Molecule Tests

This role includes Molecule tests to verify its functionality. To run the tests, navigate to the role directory and execute:

```bash
molecule test
```

Ensure you have Molecule installed in your environment before running the tests.

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

This documentation provides a comprehensive overview of the `bootstrap_docker` role, including its purpose, configuration options, usage instructions, and best practices. For more detailed information, refer to the linked files in the Backlinks section.