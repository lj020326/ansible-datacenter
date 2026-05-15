---
title: "Docker Stack Bootstrap Role"
role: bootstrap_docker_stack
category: Docker
type: Ansible Role
tags: docker, ansible, automation, devops
---

## Summary

The `bootstrap_docker_stack` role is designed to automate the setup, management, and configuration of a Docker stack. This includes initializing necessary variables, setting up application configurations, managing certificates (both self-signed and CA-based), configuring firewalld rules, and deploying Docker services using Docker Compose or Docker Swarm. The role supports various actions such as `setup`, `start`, `restart`, `stop`, `up`, and `down`.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `docker_stack__environment` | `DEV` | Specifies the environment (e.g., DEV, PROD). |
| `docker_stack__host_network` | `{{ gateway_ipv4_network_cidr }}` | The host network CIDR. |
| `docker_stack__network_subnet__default` | `192.168.10.0/24` | Default subnet for Docker networks. |
| `docker_stack__network_subnet__socket_proxy` | `192.168.11.0/24` | Subnet for socket proxy network. |
| `docker_stack__network_subnet__traefik_proxy` | `192.168.12.0/24` | Subnet for Traefik proxy network. |
| `docker_stack__network_subnet__vpn` | `192.168.13.0/24` | Subnet for VPN network. |
| `docker_stack__action` | `setup` | Action to perform (e.g., setup, start, restart, stop, up, down). |
| `docker_stack__swarm_mode` | `false` | Enable Docker Swarm mode. |
| `docker_stack__swarm_manager` | `false` | Designate the host as a swarm manager. |
| `docker_stack__swarm_node_traefik_label` | `traefik-enabled` | Label for Traefik-enabled nodes. |
| `docker_stack__debug_mode` | `true` | Enable debug mode for verbose logging. |
| `docker_stack__enable_external_route` | `false` | Enable external routing. |
| `docker_stack__enable_cert_resolver` | `false` | Enable certificate resolver. |
| `docker_stack__cacerts__fetch_method_default` | `vault` | Default method to fetch CA certificates (e.g., vault, local). |
| `docker_stack__cacerts__fetch_method` | `{{ docker_stack__cacerts__fetch_method \| d(__docker_stack__cacerts__fetch_method_default) }}` | Method to fetch CA certificates. |
| `docker_stack__cacerts__vault_url_default` | `http://127.0.0.1:8200` | Default URL for Vault server. |
| `docker_stack__cacerts__vault_url` | `{{ docker_stack__cacerts__vault_url \| d(__docker_stack__cacerts__vault_url_default) }}` | URL for Vault server. |
| `docker_stack__cacerts__vault_token` | `{{ docker_stack__cacerts__vault_token \| d('') }}` | Token for accessing Vault. |
| `docker_stack__ca_root_cn_default` | `your-root-ca.example.com` | Default Common Name of the Root CA to fetch. |
| `docker_stack__ca_root_cn` | `{{ docker_stack__ca_root_cn \| d(__docker_stack__ca_root_cn_default) }}` | Common Name of the Root CA to fetch. |
| `docker_stack__cacerts__vault_kv_mount_point_default` | `secret` | Default Vault KV mount point for certificates. |
| `docker_stack__cacerts__vault_kv_mount_point` | `{{ docker_stack__cacerts__vault_kv_mount_point \| d(__docker_stack__cacerts__vault_kv_mount_point_default) }}` | Vault KV mount point for certificates. |
| `docker_stack__cacerts__vault_kv_path_default` | `{{ __docker_stack__cacerts__vault_kv_mount_point }}/{{ __docker_stack__ca_root_cn }}/certs` | Default Vault KV path for certificates. |
| `docker_stack__cacerts__vault_kv_path` | `{{ docker_stack__cacerts__vault_kv_path \| d(__docker_stack__cacerts__vault_kv_path_default) }}` | Vault KV path for certificates. |
| `docker_stack__ca_cert_bundle_default` | `/etc/pki/tls/certs/ca-bundle.crt` | Default CA certificate bundle file path. |
| `docker_stack__ca_cert_bundle` | `{{ docker_stack__ca_cert_bundle \| d(__docker_stack__ca_cert_bundle_default) }}` | CA certificate bundle file path. |
| `docker_stack__ca_java_keystore_default` | `/etc/pki/ca-trust/extracted/java/cacerts` | Default Java keystore file path for CA certificates. |
| `docker_stack__ca_java_keystore` | `{{ docker_stack__ca_java_keystore \| d(__docker_stack__ca_java_keystore_default) }}` | Java keystore file path for CA certificates. |

## Usage

To use the `bootstrap_docker_stack` role, include it in your playbook and define the necessary variables as per your requirements. Here is an example of how to include this role in a playbook:

```yaml
- name: Bootstrap Docker Stack
  hosts: all
  roles:
    - role: bootstrap_docker_stack
      vars:
        docker_stack__environment: PROD
        docker_stack__action: setup
        docker_stack__swarm_mode: true
        docker_stack__swarm_manager: true
```

## Dependencies

- `community.docker` Ansible collection for Docker management.
- `dettonville.utils` Ansible collection for utility modules.
- `bootstrap_linux_firewalld` role for configuring firewalld rules.
- `bootstrap_systemd_service` role for setting up systemd services.

Ensure these dependencies are installed before running the playbook:

```bash
ansible-galaxy collection install community.docker dettonville.utils
ansible-galaxy role install bootstrap_linux_firewalld bootstrap_systemd_service
```

## Best Practices

1. **Environment Variables**: Use environment variables to manage sensitive information such as passwords and tokens.
2. **Role Configuration**: Configure the role using variables in your playbook or inventory files to maintain flexibility.
3. **Testing**: Test the role thoroughly in a development environment before deploying it to production.

## Molecule Tests

This role includes Molecule tests to verify its functionality. To run the tests, ensure you have Molecule installed and execute:

```bash
molecule test
```

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_docker_stack/defaults/main.yml)
- [tasks/pre-start.yml](../../roles/bootstrap_docker_stack/tasks/pre-start.yml)
- [tasks/pre-setup.yml](../../roles/bootstrap_docker_stack/tasks/pre-setup.yml)
- [tasks/init-stepca-certs-signed.yml](../../roles/bootstrap_docker_stack/tasks/init-stepca-certs-signed.yml)
- [tasks/init-stepca-certs.yml](../../roles/bootstrap_docker_stack/tasks/init-stepca-certs.yml)
- [tasks/handle-docker-service-exception.yml](../../roles/bootstrap_docker_stack/tasks/handle-docker-service-exception.yml)
- [tasks/init-vars.yml](../../roles/bootstrap_docker_stack/tasks/init-vars.yml)
- [tasks/main.yml](../../roles/bootstrap_docker_stack/tasks/main.yml)
- [tasks/restart-docker-daemon.yml](../../roles/bootstrap_docker_stack/tasks/restart-docker-daemon.yml)
- [tasks/run-compose-action.yml](../../roles/bootstrap_docker_stack/tasks/run-compose-action.yml)
- [tasks/setup-admin-scripts.yml](../../roles/bootstrap_docker_stack/tasks/setup-admin-scripts.yml)
- [tasks/setup-app-configs.yml](../../roles/bootstrap_docker_stack/tasks/setup-app-configs.yml)
- [tasks/setup-cacerts.yml](../../roles/bootstrap_docker_stack/tasks/setup-cacerts.yml)
- [tasks/setup-container-configs.yml](../../roles/bootstrap_docker_stack/tasks/setup-container-configs.yml)
- [tasks/setup-firewalld.yml](../../roles/bootstrap_docker_stack/tasks/setup-firewalld.yml)
- [tasks/setup-selfsigned-cert.yml](../../roles/bootstrap_docker_stack/tasks/setup-selfsigned-cert.yml)
- [tasks/setup-service-configs.yml](../../roles/bootstrap_docker_stack/tasks/setup-service-configs.yml)
- [tasks/setup-systemd-service.yml](../../roles/bootstrap_docker_stack/tasks/setup-systemd-service.yml)
- [tasks/shutdown-docker-stack.yml](../../roles/bootstrap_docker_stack/tasks/shutdown-docker-stack.yml)
- [handlers/main.yml](../../roles/bootstrap_docker_stack/handlers/main.yml)