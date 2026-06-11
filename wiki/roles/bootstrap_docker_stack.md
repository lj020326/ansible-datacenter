---
title: Docker Stack Bootstrap Role Documentation
role: bootstrap_docker_stack
category: Ansible Roles
type: Infrastructure Setup
tags: docker, ansible, stack, setup, swarm, traefik, openldap

---

## Summary

The `bootstrap_docker_stack` role is designed to automate the setup and management of a Docker-based application stack. This includes initializing necessary configurations, setting up Docker Swarm mode (if required), configuring networking, deploying services, managing certificates, and ensuring that all components are properly integrated and operational.

## Variables

| Variable Name                             | Default Value                                                                                         | Description                                                                                                                                                                                                                                                                                                                                 |
|---------------------------------------------|-------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `docker_stack__environment`               | `DEV`                                                                                                 | Specifies the environment (e.g., DEV, STAGE, PROD) for the Docker stack.                                                                                                                                                                                                      |
| `docker_stack__host_network`              | `{{ gateway_ipv4_network_cidr }}`                                                                     | The network CIDR to be used for the host network.                                                                                                                                                                                                                               |
| `docker_stack__network_subnet__default`   | `192.168.10.0/24`                                                                                     | Default subnet for Docker networking.                                                                                                                                                                                                                                             |
| `docker_stack__network_subnet__socket_proxy`| `192.168.11.0/24`                                                                                     | Subnet used by the socket proxy service.                                                                                                                                                                                                                                          |
| `docker_stack__network_subnet__traefik_proxy`| `192.168.12.0/24`                                                                                    | Subnet used by the Traefik proxy service.                                                                                                                                                                                                                                         |
| `docker_stack__network_subnet__vpn`         | `192.168.13.0/24`                                                                                     | Subnet used for VPN services.                                                                                                                                                                                                                                                     |
| `docker_stack__action`                    | `setup`                                                                                               | Action to perform on the Docker stack (`setup`, `start`, `restart`, `stop`, `up`, `down`).                                                                                                                                                                                    |
| `docker_stack__swarm_mode`                | `false`                                                                                               | Enable or disable Docker Swarm mode.                                                                                                                                                                                                                                              |
| `docker_stack__swarm_manager`             | `false`                                                                                               | Designate the node as a swarm manager if Swarm mode is enabled.                                                                                                                                                                                                               |
| `docker_stack__swarm_node_traefik_label`  | `traefik-enabled`                                                                                     | Label to identify nodes that should run Traefik services in Swarm mode.                                                                                                                                                                                                       |
| `docker_stack__debug_mode`                | `true`                                                                                                | Enable or disable debug mode for detailed logging and output.                                                                                                                                                                                                                 |
| `docker_stack__enable_external_route`     | `false`                                                                                               | Enable external routing if required by the stack configuration.                                                                                                                                                                                                               |
| `docker_stack__enable_cert_resolver`      | `false`                                                                                               | Enable certificate resolver for Traefik to automatically manage SSL certificates.                                                                                                                                                                                             |
| `docker_stack__cacerts__fetch_method`     | `vault`                                                                                               | Method to fetch CA certificates (`local`, `vault`).                                                                                                                                                                                                                             |
| `docker_stack__cacerts__vault_url`        | `http://127.0.0.1:8200`                                                                               | URL of the Vault server for fetching certificates if `fetch_method` is set to `vault`.                                                                                                                                                                                      |
| `docker_stack__cacerts__vault_token`      | (empty)                                                                                               | Token for authenticating with the Vault server.                                                                                                                                                                                                                                   |
| `docker_stack__ca_root_cn`                | `your-root-ca.example.com`                                                                            | Common Name of the Root CA to fetch from Vault.                                                                                                                                                                                                                                 |
| `docker_stack__cacerts__vault_kv_mount_point` | `secret`                                                                                            | KV mount point in Vault where certificates are stored.                                                                                                                                                                                                                        |
| `docker_stack__cacerts__vault_kv_path`    | `{{ __docker_stack__cacerts__vault_kv_mount_point }}/{{ __docker_stack__ca_root_cn }}/certs`        | Full path in Vault to the certificate data.                                                                                                                                                                                                                                     |
| `docker_stack__ca_cert_bundle`            | `/etc/pki/tls/certs/ca-bundle.crt`                                                                    | Path to the CA certificate bundle file on the host system.                                                                                                                                                                                                                    |
| `docker_stack__ca_java_keystore`          | `/etc/pki/ca-trust/extracted/java/cacerts`                                                            | Path to the Java keystore for CA certificates.                                                                                                                                                                                                                                |

## Usage

To use the `bootstrap_docker_stack` role, include it in your playbook and define the necessary variables as per your environment requirements.

```yaml
- hosts: all
  roles:
    - role: bootstrap_docker_stack
      vars:
        docker_stack__environment: PROD
        docker_stack__swarm_mode: true
        docker_stack__swarm_manager: true
```

## Dependencies

The `bootstrap_docker_stack` role depends on the following Ansible collections and modules:

- `community.docker`
- `ansible.builtin`
- `dettonville.utils`
- `community.hashi_vault`
- `community.crypto`

Ensure these are installed in your Ansible environment before running the playbook.

## Best Practices

1. **Environment Configuration**: Always specify the correct environment (`docker_stack__environment`) to ensure that configurations are tailored to the specific deployment context.
2. **Security**: Use secure methods for fetching and managing certificates, such as Vault integration (`docker_stack__cacerts__fetch_method`).
3. **Swarm Mode**: Enable Docker Swarm mode (`docker_stack__swarm_mode`) if you need to manage a cluster of Docker nodes.
4. **Logging and Debugging**: Enable debug mode (`docker_stack__debug_mode`) during initial setup or troubleshooting for detailed logs.

## Molecule Tests

Molecule tests are not provided in the current role documentation. However, it is recommended to write and run Molecule tests to ensure the role behaves as expected across different environments.

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