---
title: Bootstrap Docker Stack Role Documentation
role: bootstrap_docker_stack
category: Ansible Roles
type: Infrastructure Setup
---

## Summary

The `bootstrap_docker_stack` role is designed to automate the setup, management, and lifecycle operations of a Docker stack. It supports actions such as setup, start, restart, stop, up, and down, and can manage both standalone and Swarm mode configurations. The role handles various components including Docker networks, certificates, firewalld settings, and systemd services.

## Variables

| Variable Name                          | Default Value                                                                 | Description                                                                                                                                                                                                 |
|----------------------------------------|-------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `docker_stack__environment`            | `DEV`                                                                         | Specifies the environment (e.g., DEV, PROD).                                                                                                                                                              |
| `docker_stack__host_network`           | `10.1.0.0/16`                                                                 | Defines the host network range for Docker containers.                                                                                                                                                       |
| `docker_stack__network_subnet__default`| `192.168.10.0/24`                                                             | Default subnet for Docker networks.                                                                                                                                                                         |
| `docker_stack__action`                 | `setup`                                                                       | Action to perform on the Docker stack (e.g., setup, start, restart).                                                                                                                                        |
| `docker_stack__swarm_mode`             | `false`                                                                       | Enables or disables Docker Swarm mode.                                                                                                                                                                      |
| `docker_stack__swarm_leader`           | `false`                                                                       | Indicates if the node is a Swarm leader.                                                                                                                                                                    |
| `docker_stack__swarm_manager`          | `false`                                                                       | Indicates if the node is a Swarm manager.                                                                                                                                                                   |
| `docker_stack__debug_mode`             | `true`                                                                        | Enables or disables debug mode for verbose logging.                                                                                                                                                         |
| `docker_stack__enable_external_route`  | `false`                                                                       | Enables external routing capabilities.                                                                                                                                                                      |
| `docker_stack__enable_cert_resolver`   | `false`                                                                       | Enables certificate resolution using a resolver service.                                                                                                                                                    |
| `docker_stack__cacerts__fetch_method`  | `vault`                                                                       | Method to fetch CA certificates (e.g., vault, local).                                                                                                                                                     |
| `docker_stack__cacerts__vault_url`     | `http://127.0.0.1:8200`                                                       | URL of the Vault server for fetching CA certificates.                                                                                                                                                       |
| `docker_stack__ca_root_cn`             | `your-root-ca.example.com`                                                    | Common Name (CN) of the root CA certificate to fetch from Vault.                                                                                                                                            |

## Usage

To use the `bootstrap_docker_stack` role, include it in your playbook and define the necessary variables as per your requirements. Here is an example:

```yaml
- name: Bootstrap Docker Stack
  hosts: all
  roles:
    - role: bootstrap_docker_stack
      vars:
        docker_stack__environment: PROD
        docker_stack__action: setup
        docker_stack__swarm_mode: true
```

## Dependencies

The `bootstrap_docker_stack` role depends on the following roles and modules:

- `community.docker`
- `dettonville.utils`
- `community.crypto`
- `bootstrap_linux_firewalld`
- `bootstrap_systemd_service`

Ensure these roles and modules are installed in your Ansible environment.

## Best Practices

1. **Environment Configuration**: Always specify the correct environment (`docker_stack__environment`) to ensure proper configuration settings.
2. **Security**: Use secure methods for fetching CA certificates, such as Vault, and manage sensitive information appropriately.
3. **Swarm Mode**: Enable Swarm mode only if required, and configure nodes correctly as leaders or managers.
4. **Logging**: Enable debug mode (`docker_stack__debug_mode`) during initial setup to troubleshoot any issues.

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