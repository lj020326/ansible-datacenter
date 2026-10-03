---
title: "Bootstrap Docker Stack Role"
role: bootstrap_docker_stack
category: Infrastructure
type: Role
tags: [ansible, role, bootstrap_docker_stack]
---

```yaml
---
title: Bootstrap Docker Stack Role
role: bootstrap_docker_stack
category: Infrastructure
type: Role

summary: |
  The `bootstrap_docker_stack` role is designed to automate the setup, management, and orchestration of Docker-based applications. It provides a comprehensive framework for deploying Docker stacks, managing services, configuring networks, and handling certificates. This role supports both standalone and Swarm mode deployments, and includes features for setting up self-signed or CA-signed certificates, configuring firewalls, and managing systemd services.

variables: |
  | Variable Name                                | Default Value                       | Description                                                                 |
  |----------------------------------------------|-------------------------------------|-----------------------------------------------------------------------------|
  | `__docker_stack__supported_actions`           | `setup, start, restart, stop, up, down` | List of supported actions for the Docker stack.                             |
  | `docker_stack__environment`                   | `DEV`                               | Environment in which the Docker stack is deployed (DEV, PROD, etc.).         |
  | `docker_stack__host_network`                  | `10.1.0.0/16`                       | Host network configuration for the Docker stack.                            |
  | `docker_stack__network_subnet__default`       | `192.168.10.0/24`                   | Default network subnet for the Docker stack.                                |
  | `docker_stack__network_subnet__socket_proxy`  | `192.168.11.0/24`                   | Network subnet for socket proxy services.                                   |
  | `docker_stack__network_subnet__traefik_proxy` | `192.168.12.0/24`                   | Network subnet for Traefik proxy services.                                  |
  | `docker_stack__network_subnet__vpn`           | `192.168.13.0/24`                   | Network subnet for VPN services.                                             |
  | `docker_stack__action`                        | `setup`                             | Action to perform on the Docker stack (setup, start, restart, stop, up, down).|
  | `docker_stack__swarm_mode`                    | `false`                             | Enable or disable Docker Swarm mode.                                         |
  | `__docker_stack__swarm_restricted_keys`       | `[...]`                             | List of restricted keys for Swarm mode.                                     |
  | `__docker_stack__standalone_restricted_keys`  | `[...]`                             | List of restricted keys for standalone mode.                                |
  | `__docker_stack__architecture`                | `{{ ansible_facts.architecture }}` | Architecture of the system (automatically detected).                        |
  | `__docker_stack__systemd_service__name_default` | `docker-compose-{{ docker_stack__dir | replace('/','-') }}` | Default name for the systemd service.                                       |
  | `__docker_stack__systemd_service__name`       | `{{ docker_stack__systemd_service__name | d(__docker_stack__systemd_service__name_default) }}` | Name of the systemd service. |
  | `docker_stack__swarm_leader`                  | `false`                             | Indicates if the node is the Swarm leader.                                  |
  | `docker_stack__swarm_manager`                 | `false`                             | Indicates if the node is a Swarm manager.                                   |
  | `docker_stack__swarm_node_traefik_label`      | `traefik-enabled`                    | Label for Traefik-enabled Swarm nodes.                                      |
  | `docker_stack__debug_mode`                    | `true`                              | Enable or disable debug mode.                                                |
  | `docker_stack__enable_external_route`         | `false`                             | Enable or disable external routes.                                           |
  | `docker_stack__enable_cert_resolver`          | `false`                             | Enable or disable certificate resolver.                                      |
  | `__docker_stack__cacerts__fetch_method_default` | `vault`                             | Default method for fetching CA certificates (vault, http, etc.).             |
  | `__docker_stack__cacerts__fetch_method`       | `{{ docker_stack__cacerts__fetch_method | d(__docker_stack__cacerts__fetch_method_default) }}` | Method for fetching CA certificates. |
  | `__docker_stack__cacerts__vault_url_default`  | `http://127.0.0.1:8200`             | Default URL for the Vault server.                                             |
  | `__docker_stack__cacerts__vault_url`          | `{{ docker_stack__cacerts__vault_url | d(__docker_stack__cacerts__vault_url_default) }}` | URL for the Vault server. |
  | `__docker_stack__cacerts__vault_token`        | `{{ docker_stack__cacerts__vault_token | d('') }}` | Token for the Vault server. |
  | `__docker_stack__ca_root_cn_default`          | `your-root-ca.example.com`           | Default Common Name of the Root CA.                                          |
  | `__docker_stack__ca_root_cn`                  | `{{ docker_stack__ca_root_cn | d(__docker_stack__ca_root_cn_default) }}` | Common Name of the Root CA. |
  | `__docker_stack__cacerts__vault_kv_mount_point_default` | `secret` | Default mount point for Vault KV store. |
  | `__docker_stack__cacerts__vault_kv_mount_point` | `{{ docker_stack__cacerts__vault_kv_mount_point | d(__docker_stack__cacerts__vault_kv_mount_point_default) }}` | Mount point for Vault KV store. |
  | `__docker_stack__cacerts__vault_kv_path_default` | `{{ __docker_stack__cacerts__vault_kv_mount_point }}/{{ __docker_stack__ca_root_cn }}/certs` | Default path for Vault KV store. |
  | `__docker_stack__cacerts__vault_kv_path`      | `{{ docker_stack__cacerts__vault_kv_path | d(__docker_stack__cacerts__vault_kv_path_default) }}` | Path for Vault KV store. |

usage: |
  To use the `bootstrap_docker_stack` role, include it in your playbook and configure the necessary variables. Here is an example playbook:

  ```yaml
  ---
  - hosts: docker_hosts
    become: true
    roles:
      - role: bootstrap_docker_stack
        vars:
          docker_stack__action: setup
          docker_stack__environment: PROD
          docker_stack__swarm_mode: true
          docker_stack__swarm_leader: true
          docker_stack__swarm_manager: true
  ```

  For a standalone deployment without Swarm mode:

  ```yaml
  ---
  - hosts: docker_hosts
    become: true
    roles:
      - role: bootstrap_docker_stack
        vars:
          docker_stack__action: setup
          docker_stack__environment: DEV
          docker_stack__swarm_mode: false
  ```

dependencies: |
  - `community.docker` (required for Docker operations)
  - `community.hashi_vault` (required for Vault integration)
  - `dettonville.utils` (utility functions)
  - `bootstrap_systemd_service` (for managing systemd services)
  - `bootstrap_linux_firewalld` (for firewall configuration)

best_practices: |
  - Always ensure that the Docker daemon is running and accessible before executing the role.
  - Use appropriate network configurations based on your deployment environment.
  - Secure your Docker stack by configuring firewalls and using certificates.
  - Regularly update the role and its dependencies to benefit from the latest features and security patches.
  - Test the role in a development environment before deploying to production.
  - Monitor the Docker stack and system resources to ensure optimal performance.

backlinks: |
  - [defaults/main.yml](../../roles/bootstrap_docker_stack/defaults/main.yml) - Default variable values
  - [tasks/pre-start.yml](../../roles/bootstrap_docker_stack/tasks/pre-start.yml) - Pre-start tasks
  - [tasks/pre-setup.yml](../../roles/bootstrap_docker_stack/tasks/pre-setup.yml) - Pre-setup tasks
  - [tasks/init-stepca-certs-signed.yml](../../roles/bootstrap_docker_stack/tasks/init-stepca-certs-signed.yml) - Initialize signed certificates
  - [tasks/init-stepca-certs.yml](../../roles/bootstrap_docker_stack/tasks/init-stepca-certs.yml) - Initialize self-signed certificates
  - [tasks/handle-docker-service-exception.yml](../../roles/bootstrap_docker_stack/tasks/handle-docker-service-exception.yml) - Handle Docker service exceptions
  - [tasks/init-vars.yml](../../roles/bootstrap_docker_stack/tasks/init-vars.yml) - Initialize variables
  - [tasks/main.yml](../../roles/bootstrap_docker_stack/tasks/main.yml) - Main tasks
  - [tasks/restart-docker-daemon.yml](../../roles/bootstrap_docker_stack/tasks/restart-docker-daemon.yml) - Restart Docker daemon
  - [tasks/run-compose-action.yml](../../roles/bootstrap_docker_stack/tasks/run-compose-action.yml) - Run Compose actions
  - [tasks/setup-admin-scripts.yml](../../roles/bootstrap_docker_stack/tasks/setup-admin-scripts.yml) - Setup admin scripts
  - [tasks/setup-app-configs.yml](../../roles/bootstrap_docker_stack/tasks/setup-app-configs.yml) - Setup application configs
  - [tasks/setup-auth-configs.yml](../../roles/bootstrap_docker_stack/tasks/setup-auth-configs.yml) - Setup authentication configs
  - [tasks/setup-cacerts.yml](../../roles/bootstrap_docker_stack/tasks/setup-cacerts.yml) - Setup CA certificates
  - [tasks/setup-container-configs.yml](../../roles/bootstrap_docker_stack/tasks/setup-container-configs.yml) - Setup container configs
  - [tasks/setup-firewalld.yml](../../roles/bootstrap_docker_stack/tasks/setup-firewalld.yml) - Setup firewalld
  - [tasks/setup-proxy-configs.yml](../../roles/bootstrap_docker_stack/tasks/setup-proxy-configs.yml) - Setup proxy configs
  - [tasks/setup-selfsigned-cert.yml](../../roles/bootstrap_docker_stack/tasks/setup-selfsigned-cert.yml) - Setup self-signed certificates
  - [tasks/setup-service-configs.yml](../../roles/bootstrap_docker_stack/tasks/setup-service-configs.yml) - Setup service configs
  - [tasks/setup-systemd-service.yml](../../roles/bootstrap_docker_stack/tasks/setup-systemd-service.yml) - Setup systemd service
  - [tasks/shutdown-docker-stack.yml](../../roles/bootstrap_docker_stack/tasks/shutdown-docker-stack.yml) - Shutdown Docker stack
  - [handlers/main.yml](../../roles/bootstrap_docker_stack/handlers/main.yml) - Handlers for notifications