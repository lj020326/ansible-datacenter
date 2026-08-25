---
title: "Docker Stack Bootstrap Role"
role: bootstrap_docker_stack
category: Docker Management
type: Ansible Role
---

## Summary

The `bootstrap_docker_stack` role is designed to automate the setup, management, and lifecycle of a Docker stack. It supports actions such as setting up, starting, restarting, stopping, and managing Docker stacks using Docker Compose or Docker Swarm. The role handles various configurations including network setups, certificate management, firewall rules, and systemd service creation.

## Variables

| Variable Name                                 | Default Value                                                                                   | Description                                                                                                                                                                                                 |
|-----------------------------------------------|-------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `docker_stack__environment`                 | `DEV`                                                                                           | Specifies the environment (e.g., DEV, PROD) for the Docker stack.                                                                                                                                         |
| `docker_stack__host_network`                | `10.1.0.0/16`                                                                                   | The host network range used by the Docker stack.                                                                                                                                                            |
| `docker_stack__network_subnet__default`     | `192.168.10.0/24`                                                                               | Default subnet for Docker networks.                                                                                                                                                                         |
| `docker_stack__network_subnet__socket_proxy`  | `192.168.11.0/24`                                                                               | Subnet for the socket proxy network.                                                                                                                                                                        |
| `docker_stack__network_subnet__traefik_proxy` | `192.168.12.0/24`                                                                               | Subnet for the Traefik proxy network.                                                                                                                                                                       |
| `docker_stack__network_subnet__vpn`         | `192.168.13.0/24`                                                                               | Subnet for the VPN network.                                                                                                                                                                                 |
| `docker_stack__action`                      | `setup`                                                                                         | Action to perform on the Docker stack (e.g., setup, start, restart, stop, up, down).                                                                                                                       |
| `docker_stack__swarm_mode`                  | `false`                                                                                         | Whether to use Docker Swarm mode.                                                                                                                                                                           |
| `docker_stack__swarm_leader`                | `false`                                                                                         | Indicates if the node is a swarm leader.                                                                                                                                                                    |
| `docker_stack__swarm_manager`               | `false`                                                                                         | Indicates if the node is a swarm manager.                                                                                                                                                                   |
| `docker_stack__swarm_node_traefik_label`    | `traefik-enabled`                                                                               | Label for Traefik-enabled nodes in Swarm mode.                                                                                                                                                              |
| `docker_stack__debug_mode`                  | `true`                                                                                          | Enables debug mode for detailed logging.                                                                                                                                                                    |
| `docker_stack__enable_external_route`       | `false`                                                                                         | Enables external routing for the Docker stack.                                                                                                                                                              |
| `docker_stack__enable_cert_resolver`        | `false`                                                                                         | Enables certificate resolution using a resolver service.                                                                                                                                                    |
| `docker_stack__cacerts__fetch_method`       | `vault`                                                                                         | Method to fetch CA certificates (e.g., vault, local).                                                                                                                                                     |
| `docker_stack__cacerts__vault_url`          | `http://127.0.0.1:8200`                                                                         | URL of the Vault server for fetching CA certificates.                                                                                                                                                       |
| `docker_stack__ca_root_cn`                  | `your-root-ca.example.com`                                                                      | Common Name (CN) of the root CA to fetch from Vault.                                                                                                                                                        |
| `docker_stack__cacerts__vault_kv_mount_point` | `secret`                                                                                        | Vault KV mount point for storing certificates.                                                                                                                                                              |
| `docker_stack__cacerts__vault_kv_path`      | `{{ __docker_stack__cacerts__vault_kv_mount_point }}/{{ __docker_stack__ca_root_cn }}/certs`    | Path in Vault where the certificates are stored.                                                                                                                                                            |
| `docker_stack__ca_cert_bundle`              | `/etc/pki/tls/certs/ca-bundle.crt`                                                              | Path to the CA certificate bundle file.                                                                                                                                                                     |
| `docker_stack__ca_java_keystore`            | `/etc/pki/ca-trust/extracted/java/cacerts`                                                      | Path to the Java keystore for CA certificates.                                                                                                                                                              |

## Usage

To use the `bootstrap_docker_stack` role, include it in your playbook and specify the desired action and configuration variables.

### Example Playbook

```yaml
- name: Bootstrap Docker Stack
  hosts: all
  roles:
    - role: bootstrap_docker_stack
      vars:
        docker_stack__action: setup
        docker_stack__swarm_mode: true
        docker_stack__swarm_leader: true
```

## Dependencies

The `bootstrap_docker_stack` role depends on the following Ansible collections and modules:

- `ansible.builtin`
- `community.docker`
- `dettonville.utils`
- `community.crypto`
- `community.hashi_vault`

Ensure these collections are installed in your Ansible environment.

### Installing Collections

```bash
ansible-galaxy collection install community.docker dettonville.utils community.crypto community.hashi_vault
```

## Best Practices

1. **Environment Configuration**: Always specify the correct environment (`docker_stack__environment`) to ensure proper configuration and resource allocation.
2. **Security**: Use secure methods for fetching CA certificates, such as Vault, and ensure sensitive data is encrypted and protected.
3. **Swarm Mode**: When using Docker Swarm mode, ensure that nodes are properly labeled and configured as leaders or managers.
4. **Debugging**: Enable `docker_stack__debug_mode` to get detailed logs during setup and troubleshooting.

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