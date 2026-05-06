---
title: Bootstrap Docker Stack Role Documentation
role: bootstrap_docker_stack
category: Docker Management
type: Ansible Role
tags: docker, ansible, automation, setup, deployment

---

## Summary

The `bootstrap_docker_stack` role is designed to automate the setup, management, and configuration of a Docker stack. It supports various actions such as setup, start, restart, stop, up, and down. The role handles network configurations, certificate management (both self-signed and CA-based), firewall settings, and service deployment using Docker Compose or Docker Swarm.

## Variables

| Variable Name                             | Default Value                                                                 | Description                                                                                                                                                                                                 |
|---------------------------------------------|-------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `docker_stack__environment`               | `DEV`                                                                         | Specifies the environment (e.g., DEV, PROD).                                                                                                                                                              |
| `docker_stack__host_network`              | `{{ gateway_ipv4_network_cidr }}`                                             | The host network CIDR.                                                                                                                                                                                      |
| `docker_stack__network_subnet__default`   | `192.168.10.0/24`                                                             | Default subnet for Docker networks.                                                                                                                                                                         |
| `docker_stack__network_subnet__socket_proxy`| `192.168.11.0/24`                                                             | Subnet for socket proxy network.                                                                                                                                                                            |
| `docker_stack__network_subnet__traefik_proxy`| `192.168.12.0/24`                                                            | Subnet for Traefik proxy network.                                                                                                                                                                           |
| `docker_stack__network_subnet__vpn`       | `192.168.13.0/24`                                                             | Subnet for VPN network.                                                                                                                                                                                     |
| `docker_stack__action`                    | `setup`                                                                       | Action to perform (e.g., setup, start, restart, stop, up, down).                                                                                                                                          |
| `docker_stack__swarm_mode`                | `false`                                                                       | Enable Docker Swarm mode.                                                                                                                                                                                   |
| `docker_stack__swarm_manager`             | `false`                                                                       | Designate the node as a swarm manager.                                                                                                                                                                      |
| `docker_stack__swarm_node_traefik_label`  | `traefik-enabled`                                                             | Label for Traefik-enabled nodes in Swarm mode.                                                                                                                                                              |
| `docker_stack__debug_mode`                | `true`                                                                        | Enable debug mode for verbose logging.                                                                                                                                                                      |
| `docker_stack__enable_external_route`     | `false`                                                                       | Enable external routing configuration.                                                                                                                                                                      |
| `docker_stack__enable_cert_resolver`      | `false`                                                                       | Enable certificate resolver functionality.                                                                                                                                                                    |
| `docker_stack__cacerts__fetch_method_default` | `vault`                                                                      | Default method for fetching CA certificates (e.g., vault, local).                                                                                                                                         |
| `docker_stack__cacerts__vault_url_default`| `http://127.0.0.1:8200`                                                       | Default URL for Vault server.                                                                                                                                                                               |
| `docker_stack__ca_root_cn_default`        | `your-root-ca.example.com`                                                    | Common Name of the Root CA to fetch from Vault.                                                                                                                                                             |
| `docker_stack__cacerts__vault_kv_mount_point_default` | `secret`                                                                   | Default KV mount point in Vault for certificates.                                                                                                                                                           |
| `docker_stack__cacerts__vault_kv_path_default`| `{{ __docker_stack__cacerts__vault_kv_mount_point }}/{{ __docker_stack__ca_root_cn }}/certs` | Default path in Vault for certificates.                                                                                                                                                                     |
| `docker_stack__ca_cert_bundle_default`    | `/etc/pki/tls/certs/ca-bundle.crt`                                            | Path to the CA certificate bundle file.                                                                                                                                                                     |
| `docker_stack__ca_java_keystore_default`  | `/etc/pki/ca-trust/extracted/java/cacerts`                                    | Path to the Java keystore file for CA certificates.                                                                                                                                                         |

## Usage

To use this role, include it in your playbook and specify the desired action:

```yaml
- name: Bootstrap Docker Stack
  hosts: all
  roles:
    - role: bootstrap_docker_stack
      docker_stack__action: setup
```

### Example Playbook

```yaml
---
- name: Setup Docker Stack with Traefik Proxy
  hosts: webservers
  become: yes
  vars:
    docker_stack__environment: PROD
    docker_stack__swarm_mode: true
    docker_stack__swarm_manager: true
    docker_stack__enable_external_route: true
    docker_stack__enable_cert_resolver: true

  roles:
    - role: bootstrap_docker_stack
      docker_stack__action: setup
```

## Dependencies

- `community.docker`
- `dettonville.utils`
- `community.crypto`
- `bootstrap_linux_firewalld` (for firewall configuration)
- `bootstrap_systemd_service` (for systemd service management)

Ensure these roles and collections are installed in your Ansible environment.

## Tags

The role uses the following tags to allow selective execution of tasks:

- `setup`: Tasks related to initial setup.
- `start`: Tasks to start Docker services.
- `restart`: Tasks to restart Docker services.
- `stop`: Tasks to stop Docker services.
- `up`: Tasks to bring up Docker stack.
- `down`: Tasks to shut down Docker stack.
- `firewalld`: Tasks for firewall configuration.
- `certs`: Tasks related to certificate management.
- `services`: Tasks for service configuration and deployment.

## Best Practices

- Always specify the desired action using the `docker_stack__action` variable.
- Use environment-specific variables to customize configurations (e.g., `docker_stack__environment`).
- Ensure proper permissions are set for sensitive files, especially when handling certificates.
- Regularly update the role and its dependencies to benefit from bug fixes and new features.

## Molecule Tests

This role includes Molecule tests to verify its functionality. To run the tests:

```bash
molecule test
```

Ensure you have Molecule installed along with the necessary drivers (e.g., Docker).

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