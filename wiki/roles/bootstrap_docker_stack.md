---
title: Bootstrap Docker Stack Role Documentation
role: bootstrap_docker_stack
category: Docker Management
type: Ansible Role
---

## Summary

The `bootstrap_docker_stack` role is designed to automate the setup, start, restart, stop, and management of a Docker stack. It supports both standalone Docker environments and Docker Swarm clusters, providing comprehensive configuration options for network settings, certificates, firewalld rules, and more.

## Variables

| Variable Name                         | Default Value                                      | Description                                                                                                                                                                                                 |
|---------------------------------------|----------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `docker_stack__environment`           | `DEV`                                              | Specifies the environment (e.g., DEV, PROD). Used to tailor configurations accordingly.                                                                                                                    |
| `docker_stack__host_network`          | `10.1.0.0/16`                                      | Defines the host network range for Docker containers.                                                                                                                                                       |
| `docker_stack__network_subnet__default` | `192.168.10.0/24`                                  | Default subnet for Docker networks.                                                                                                                                                                         |
| `docker_stack__action`                | `setup`                                            | Action to perform on the Docker stack (e.g., setup, start, restart, stop, up, down).                                                                                                                       |
| `docker_stack__swarm_mode`            | `false`                                            | Enables or disables Docker Swarm mode.                                                                                                                                                                      |
| `docker_stack__swarm_leader`          | `false`                                            | Indicates if the node is a Swarm leader.                                                                                                                                                                    |
| `docker_stack__swarm_manager`         | `false`                                            | Indicates if the node is a Swarm manager.                                                                                                                                                                   |
| `docker_stack__debug_mode`            | `true`                                             | Enables or disables debug mode for verbose logging.                                                                                                                                                         |
| `docker_stack__enable_external_route` | `false`                                            | Enables external routing capabilities in Docker stack configurations.                                                                                                                                       |
| `docker_stack__enable_cert_resolver`  | `false`                                            | Enables certificate resolver functionality, typically used with Traefik.                                                                                                                                      |
| `docker_stack__cacerts__fetch_method` | `vault`                                            | Method to fetch CA certificates (e.g., vault, local).                                                                                                                                                     |
| `docker_stack__cacerts__vault_url`    | `http://127.0.0.1:8200`                            | URL of the Vault server for fetching CA certificates.                                                                                                                                                       |
| `docker_stack__ca_root_cn`            | `your-root-ca.example.com`                         | Common Name (CN) of the Root CA to fetch from Vault.                                                                                                                                                    |
| `docker_stack__cacerts__vault_kv_path`| `secret/your-root-ca.example.com/certs`              | Path in Vault where CA certificates are stored.                                                                                                                                                           |
| `docker_stack__ca_cert_bundle`        | `/etc/pki/tls/certs/ca-bundle.crt`                 | Path to the CA certificate bundle file on the host system.                                                                                                                                                |
| `docker_stack__ca_java_keystore`      | `/etc/pki/ca-trust/extracted/java/cacerts`         | Path to the Java keystore for storing CA certificates.                                                                                                                                                  |

## Usage

To use the `bootstrap_docker_stack` role, include it in your playbook and define the necessary variables as per your requirements. Here is an example of how to include this role in a playbook:

```yaml
---
- name: Bootstrap Docker Stack
  hosts: all
  become: yes
  roles:
    - role: bootstrap_docker_stack
      vars:
        docker_stack__environment: PROD
        docker_stack__action: setup
        docker_stack__swarm_mode: true
        docker_stack__swarm_leader: false
        docker_stack__swarm_manager: true
```

## Dependencies

This role depends on the following Ansible collections and modules:

- `community.docker`
- `dettonville.utils`
- `community.hashi_vault`
- `community.crypto`

Ensure these collections are installed in your Ansible environment before running this role.

```bash
ansible-galaxy collection install community.docker dettonville.utils community.hashi_vault community.crypto
```

## Best Practices

1. **Environment-Specific Configurations**: Use the `docker_stack__environment` variable to tailor configurations for different environments (e.g., DEV, PROD).
2. **Security**: Enable and configure certificate management (`docker_stack__enable_cert_resolver`) to secure your Docker stack.
3. **Swarm Mode**: If using Docker Swarm, ensure that nodes are correctly configured as leaders or managers by setting `docker_stack__swarm_leader` and `docker_stack__swarm_manager`.
4. **Debugging**: Enable debug mode (`docker_stack__debug_mode`) for verbose logging during setup to troubleshoot issues.

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

This documentation provides a comprehensive overview of the `bootstrap_docker_stack` role, its variables, usage, dependencies, and best practices. For more detailed information, refer to the linked files in the Backlinks section.