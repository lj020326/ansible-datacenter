---
title: "Docker Stack Bootstrap Role"
role: bootstrap_docker_stack
category: Docker
type: Ansible Role
tags: docker, ansible, swarm, traefik, openldap, certificates

---

## Summary

The `bootstrap_docker_stack` role is designed to automate the setup and management of a Docker stack, including Docker Swarm mode configuration, Traefik proxy setup, OpenLDAP integration, certificate management (both self-signed and CA-based), and various other configurations required for deploying containerized applications. This role supports actions such as setup, start, restart, stop, up, and down, making it versatile for different stages of application deployment.

## Variables

| Variable Name                             | Default Value                                                                                   | Description                                                                                                                                                                                                 |
|---------------------------------------------|---------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `docker_stack__environment`               | `DEV`                                                                                           | Specifies the environment (e.g., DEV, PROD) in which the Docker stack is being deployed.                                                                                                                |
| `docker_stack__host_network`              | `10.1.0.0/16`                                                                                   | Defines the host network range used by the Docker stack.                                                                                                                                                  |
| `docker_stack__network_subnet__default`   | `192.168.10.0/24`                                                                               | Default subnet for internal Docker networks.                                                                                                                                                                |
| `docker_stack__network_subnet__socket_proxy`| `192.168.11.0/24`                                                                               | Subnet used by the socket proxy service.                                                                                                                                                                    |
| `docker_stack__network_subnet__traefik_proxy`| `192.168.12.0/24`                                                                              | Subnet used by the Traefik proxy service.                                                                                                                                                                   |
| `docker_stack__network_subnet__vpn`       | `192.168.13.0/24`                                                                               | Subnet used for VPN services.                                                                                                                                                                               |
| `docker_stack__action`                    | `setup`                                                                                         | Action to perform on the Docker stack (e.g., setup, start, restart, stop, up, down).                                                                                                                     |
| `docker_stack__swarm_mode`                | `false`                                                                                         | Enables or disables Docker Swarm mode.                                                                                                                                                                      |
| `docker_stack__swarm_leader`              | `false`                                                                                         | Indicates if the node is a swarm leader.                                                                                                                                                                    |
| `docker_stack__swarm_manager`             | `false`                                                                                         | Indicates if the node is a swarm manager.                                                                                                                                                                   |
| `docker_stack__swarm_node_traefik_label`  | `traefik-enabled`                                                                               | Label used to identify Traefik-enabled nodes in Docker Swarm.                                                                                                                                             |
| `docker_stack__debug_mode`                | `true`                                                                                          | Enables or disables debug mode for the role, providing more verbose output during execution.                                                                                                              |
| `docker_stack__enable_external_route`     | `false`                                                                                         | Enables external routing if set to true.                                                                                                                                                                    |
| `docker_stack__enable_cert_resolver`      | `false`                                                                                         | Enables certificate resolver if set to true.                                                                                                                                                                |
| `docker_stack__cacerts__fetch_method`     | `vault`                                                                                         | Method used to fetch CA certificates (e.g., vault, local).                                                                                                                                                  |
| `docker_stack__cacerts__vault_url`        | `http://127.0.0.1:8200`                                                                         | URL of the Vault server from which CA certificates are fetched.                                                                                                                                             |
| `docker_stack__ca_root_cn`                | `your-root-ca.example.com`                                                                      | Common Name (CN) of the root CA certificate to fetch from Vault.                                                                                                                                          |
| `docker_stack__cacerts__vault_kv_mount_point`| `secret`                                                                                       | Vault KV mount point where CA certificates are stored.                                                                                                                                                      |
| `docker_stack__cacerts__vault_kv_path`    | `{{ __docker_stack__cacerts__vault_kv_mount_point }}/{{ __docker_stack__ca_root_cn }}/certs`  | Path in Vault where the CA certificates are located.                                                                                                                                                    |
| `docker_stack__ca_cert_bundle`            | `/etc/pki/tls/certs/ca-bundle.crt`                                                              | Path to the CA certificate bundle file on the host system.                                                                                                                                                  |
| `docker_stack__ca_java_keystore`          | `/etc/pki/ca-trust/extracted/java/cacerts`                                                      | Path to the Java keystore file where CA certificates are stored.                                                                                                                                          |

## Usage

To use the `bootstrap_docker_stack` role, include it in your playbook and specify the desired action using the `docker_stack__action` variable. Here is an example of how to deploy a Docker stack with Traefik and OpenLDAP:

```yaml
- name: Deploy Docker Stack with Traefik and OpenLDAP
  hosts: docker_hosts
  become: yes
  roles:
    - role: bootstrap_docker_stack
      vars:
        docker_stack__action: setup
        docker_stack__swarm_mode: true
        docker_stack__swarm_leader: true
        docker_stack__enable_external_route: true
        docker_stack__enable_cert_resolver: true
```

## Dependencies

- `community.docker` collection for Docker management.
- `dettonville.utils` collection for additional utilities like certificate validation.
- `bootstrap_systemd_service` role for setting up systemd services.
- `bootstrap_linux_firewalld` role for configuring firewall rules.

Ensure these dependencies are installed before running the playbook:

```bash
ansible-galaxy collection install community.docker dettonville.utils
```

## Best Practices

1. **Environment Isolation**: Use separate environments (e.g., DEV, PROD) to avoid conflicts and ensure proper isolation.
2. **Security**: Always use secure methods for fetching CA certificates, such as Vault, and manage secrets securely.
3. **Logging**: Enable debug mode during initial setup to troubleshoot any issues that arise.
4. **Firewall Configuration**: Ensure firewall rules are correctly configured to allow necessary traffic between services.

## Molecule Tests

This role includes Molecule tests to verify its functionality. To run the tests, navigate to the role directory and execute:

```bash
molecule test
```

Ensure you have Molecule installed along with any required dependencies:

```bash
pip install molecule ansible-lint yamllint
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