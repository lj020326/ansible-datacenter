---
title: "Bootstrap Docker Stack Role"
description: "An Ansible role to automate the setup, configuration, and management of a Docker stack"
role: roles/bootstrap_docker_stack
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_docker_stack]
---

# Bootstrap Docker Stack Role Documentation

## Overview

The `bootstrap_docker_stack` Ansible role is designed to automate the setup, configuration, and management of a Docker stack. This role provides a comprehensive set of tasks to handle various aspects of Docker stack deployment, including service configuration, network setup, certificate management, and more. It is particularly useful for environments requiring consistent and repeatable Docker deployments.

## Variables

The role uses a variety of variables to control its behavior. Below is a table of the most important variables:

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `__docker_stack__supported_actions` | `['setup', 'start', 'restart', 'stop', 'up', 'down']` | List of supported actions for the Docker stack. |
| `docker_stack__environment` | `DEV` | Environment in which the Docker stack is being deployed. |
| `docker_stack__host_network` | `10.1.0.0/16` | Host network configuration for the Docker stack. |
| `docker_stack__network_subnet__default` | `192.168.10.0/24` | Default network subnet for the Docker stack. |
| `docker_stack__network_subnet__socket_proxy` | `192.168.11.0/24` | Network subnet for the socket proxy. |
| `docker_stack__network_subnet__traefik_proxy` | `192.168.12.0/24` | Network subnet for the Traefik proxy. |
| `docker_stack__network_subnet__vpn` | `192.168.13.0/24` | Network subnet for the VPN. |
| `docker_stack__action` | `setup` | Action to perform on the Docker stack. |
| `docker_stack__swarm_mode` | `false` | Whether to use Docker Swarm mode. |
| `__docker_stack__swarm_restricted_keys` | `['container_name', 'devices', 'group_add', 'labels', 'links', 'network_mode', 'privileged', 'profiles', 'restart', 'security_opt', 'sysctls', 'tmpfs', 'ulimits']` | List of keys restricted in Docker Swarm mode. |
| `__docker_stack__standalone_restricted_keys` | `['configs', 'init', 'logging', 'secrets', 'stop_grace_period']` | List of keys restricted in standalone mode. |
| `__docker_stack__architecture` | `{{ ansible_facts.architecture }}` | Architecture of the system. |
| `__docker_stack__systemd_service__name_default` | `docker-compose-{{ docker_stack__dir | replace('/','-') }}` | Default name for the systemd service. |
| `__docker_stack__systemd_service__name` | `{{ docker_stack__systemd_service__name | d(__docker_stack__systemd_service__name_default) }}` | Name for the systemd service. |
| `docker_stack__swarm_leader` | `false` | Whether this node is the Swarm leader. |
| `docker_stack__swarm_manager` | `false` | Whether this node is a Swarm manager. |
| `docker_stack__swarm_node_traefik_label` | `traefik-enabled` | Label for Traefik-enabled Swarm nodes. |
| `docker_stack__debug_mode` | `true` | Whether to enable debug mode. |
| `docker_stack__enable_external_route` | `false` | Whether to enable external routes. |
| `docker_stack__enable_cert_resolver` | `false` | Whether to enable certificate resolution. |
| `__docker_stack__cacerts__fetch_method_default` | `vault` | Default method for fetching CA certificates. |
| `__docker_stack__cacerts__fetch_method` | `{{ docker_stack__cacerts__fetch_method | d(__docker_stack__cacerts__fetch_method_default) }}` | Method for fetching CA certificates. |
| `__docker_stack__cacerts__vault_url_default` | `http://127.0.0.1:8200` | Default URL for the Vault server. |
| `__docker_stack__cacerts__vault_url` | `{{ docker_stack__cacerts__vault_url | d(__docker_stack__cacerts__vault_url_default) }}` | URL for the Vault server. |
| `__docker_stack__cacerts__vault_token` | `{{ docker_stack__cacerts__vault_token | d('') }}` | Token for the Vault server. |
| `__docker_stack__ca_root_cn_default` | `your-root-ca.example.com` | Default common name for the root CA. |
| `__docker_stack__ca_root_cn` | `{{ docker_stack__ca_root_cn | d(__docker_stack__ca_root_cn_default) }}` | Common name for the root CA. |
| `__docker_stack__cacerts__vault_kv_mount_point_default` | `secret` | Default mount point for the Vault KV store. |
| `__docker_stack__cacerts__vault_kv_mount_point` | `{{ docker_stack__cacerts__vault_kv_mount_point | d(__docker_stack__cacerts__vault_kv_mount_point_default) }}` | Mount point for the Vault KV store. |
| `__docker_stack__cacerts__vault_kv_path_default` | `{{ __docker_stack__cacerts__vault_kv_mount_point }}/{{ __docker_stack__ca_root_cn }}/certs` | Default path for the Vault KV store. |
| `__docker_stack__cacerts__vault_kv_path` | `{{ docker_stack__cacerts__vault_kv_path | d(__docker_stack__cacerts__vault_kv_path_default) }}` | Path for the Vault KV store. |

## Usage

To use this role, include it in your playbook as follows:

### Basic Usage
```yaml
- hosts: all
  roles:
    - role: bootstrap_docker_stack
      vars:
        docker_stack__action: setup
        docker_stack__environment: PROD
        docker_stack__swarm_mode: true
```

### Using Different Actions
The role supports several actions that control what the role does when executed:

- `setup`: Initializes the Docker stack
- `start`: Starts the Docker stack services
- `restart`: Restarts the Docker stack services
- `stop`: Stops the Docker stack services
- `up`: Brings the entire stack up
- `down`: Takes the entire stack down

Example of using the `up` action:
```yaml
- hosts: all
  roles:
    - role: bootstrap_docker_stack
      vars:
        docker_stack__action: up
```

## Dependencies

This role depends on the following Ansible roles and modules:

- `community.docker.docker_compose_v2`
- `community.docker.docker_login`
- `community.docker.docker_secret`
- `community.docker.docker_network`
- `community.docker.docker_container`
- `community.hashi_vault.vault_kv2_get`
- `bootstrap_systemd_service`
- `bootstrap_linux_firewalld`

## Best Practices

- Ensure that Docker is installed and running on the target hosts.
- Use the `setup` action to initialize the Docker stack.
- Use the `start`, `restart`, and `stop` actions to manage individual services within the stack.
- Use the `up` and `down` actions to manage the entire stack as a single unit.
- Configure the necessary variables to match your environment and requirements.
- For production environments, set `docker_stack__debug_mode` to `false` to minimize log output.
- For environments with external access, set `docker_stack__enable_external_route` to `true` and configure appropriate security measures.

## Related Resources

### Backlinks
- [Defaults Configuration](../../roles/bootstrap_docker_stack/defaults/main.yml)
- [Application Tasks]
  - [Jenkins Agent](../../roles/bootstrap_docker_stack/tasks/apps/archive/jenkins_agent/pre-start.yml)
  - [OpenBao](../../roles/bootstrap_docker_stack/tasks/apps/archive/openbao/pre-start.yml)
  - [AWX](../../roles/bootstrap_docker_stack/tasks/apps/awx/pre-start.yml)
  - [Cobbler](../../roles/bootstrap_docker_stack/tasks/apps/cobbler/pre-start.yml)
  - [James](../../roles/bootstrap_docker_stack/tasks/apps/james/pre-start.yml)
  - [Jenkins JCAC](../../roles/bootstrap_docker_stack/tasks/apps/jenkins_jcac/pre-start.yml)
  - [OpenLDAP](../../roles/bootstrap_docker_stack/tasks/apps/openldap/pre-setup.yml, ../../roles/bootstrap_docker_stack/tasks/apps/openldap/pre-start.yml)
  - [Plane API](../../roles/bootstrap_docker_stack/tasks/apps/plane_api/pre-start.yml)
  - [Registry](../../roles/bootstrap_docker_stack/tasks/apps/registry/pre-start.yml)
  - [Step CA](../../roles/bootstrap_docker_stack/tasks/apps/step_ca/init-stepca-certs-signed.yml, ../../roles/bootstrap_docker_stack/tasks/apps/step_ca/init-stepca-certs.yml, ../../roles/bootstrap_docker_stack/tasks/apps/step_ca/pre-start.yml)
- [Core Tasks]
  - [Handle Docker Service Exception](../../roles/bootstrap_docker_stack/tasks/handle-docker-service-exception.yml)
  - [Initialize Variables](../../roles/bootstrap_docker_stack/tasks/init-vars.yml)
  - [Main Tasks](../../roles/bootstrap_docker_stack/tasks/main.yml)
  - [Restart Docker Daemon](../../roles/bootstrap_docker_stack/tasks/restart-docker-daemon.yml)
  - [Run Compose Action](../../roles/bootstrap_docker_stack/tasks/run-compose-action.yml)
  - [Setup Scripts](../../roles/bootstrap_docker_stack/tasks/setup-admin-scripts.yml)
  - [Setup Application Configs](../../roles/bootstrap_docker_stack/tasks/setup-app-configs.yml)
  - [Setup Authentication Configs](../../roles/bootstrap_docker_stack/tasks/setup-auth-configs.yml)
  - [Setup CA Certificates](../../roles/bootstrap_docker_stack/tasks/setup-cacerts.yml)
  - [Setup Container Configs](../../roles/bootstrap_docker_stack/tasks/setup-container-configs.yml)
  - [Setup Firewalld](../../roles/bootstrap_docker_stack/tasks/setup-firewalld.yml)
  - [Setup Proxy Configs](../../roles/bootstrap_docker_stack/tasks/setup-proxy-configs.yml)
  - [Setup Self-Signed Cert](../../roles/bootstrap_docker_stack/tasks/setup-selfsigned-cert.yml)
  - [Setup Service Configs](../../roles/bootstrap_docker_stack/tasks/setup-service-configs.yml)
  - [Setup Systemd Service](../../roles/bootstrap_docker_stack/tasks/setup-systemd-service.yml)
  - [Shutdown Docker Stack](../../roles/bootstrap_docker_stack/tasks/shutdown-docker-stack.yml)
- [Handlers](../../roles/bootstrap_docker_stack/handlers/main.yml)

### Related Roles
- [`bootstrap_systemd_service`](../../roles/bootstrap_systemd_service/)
- [`bootstrap_linux_firewalld`](../../roles/bootstrap_linux_firewalld/)

This documentation provides a comprehensive overview of the `bootstrap_docker_stack` role, including its variables, usage, dependencies, and best practices. For more detailed information, refer to the specific task files and handlers listed in the Backlinks section.