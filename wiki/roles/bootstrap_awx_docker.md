---
title: "AWX Docker Bootstrap Role"
role: bootstrap_awx_docker
category: Ansible Roles
type: Infrastructure as Code
tags: [ansible, awx, docker, automation]
---

## Summary

The `bootstrap_awx_docker` role is designed to automate the deployment of AWX (Ansible Web UI) using Docker containers. This role handles the setup of necessary Docker images, configuration files, and services required for a fully functional AWX environment. It includes tasks for building, pushing, and managing container images, as well as starting and configuring Docker Compose services.

## Variables

| Variable Name                                      | Default Value                                                                                     | Description                                                                                                                                                                                                 |
|----------------------------------------------------|---------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_awx_docker__docker_registry`            | `registry.example.int:5000`                                                                       | The URL of the Docker registry to pull images from.                                                                                                                                                           |
| `bootstrap_awx_docker__docker_registry_username`   | `registryuser`                                                                                    | Username for authenticating with the Docker registry.                                                                                                                                                         |
| `bootstrap_awx_docker__docker_registry_password`   | `password`                                                                                        | Password for authenticating with the Docker registry.                                                                                                                                                         |
| `bootstrap_awx_docker__version`                    | `20.1.0`                                                                                          | The version of AWX to deploy.                                                                                                                                                                                 |
| `bootstrap_awx_docker__web_image`                  | `awx`                                                                                             | The name of the web image for AWX.                                                                                                                                                                            |
| `bootstrap_awx_docker__task_image`                 | `awx`                                                                                             | The name of the task image for AWX.                                                                                                                                                                           |
| `bootstrap_awx_docker__web_docker_actual_image`    | `{{ bootstrap_awx_docker__docker_registry }}/{{ bootstrap_awx_docker__docker_registry_repository }}/{{ bootstrap_awx_docker__web_image }}:{{ bootstrap_awx_docker__version }}` | The full path of the web image including registry and version.                                                                                                                                                |
| `bootstrap_awx_docker__task_docker_actual_image`   | `{{ bootstrap_awx_docker__docker_registry }}/{{ bootstrap_awx_docker__docker_registry_repository }}/{{ bootstrap_awx_docker__task_image }}:{{ bootstrap_awx_docker__version }}` | The full path of the task image including registry and version.                                                                                                                                               |
| `bootstrap_awx_docker__inventory_dir`              | `~/.awx`                                                                                          | Directory where inventory files are stored.                                                                                                                                                                   |
| `bootstrap_awx_docker__redis_image`                | `redis`                                                                                           | The Redis image to use for caching.                                                                                                                                                                           |
| `bootstrap_awx_docker__postgresql_version`         | `"14.2"`                                                                                          | Version of PostgreSQL to use as the database backend.                                                                                                                                                       |
| `bootstrap_awx_docker__postgresql_image`           | `postgres:{{ bootstrap_awx_docker__postgresql_version }}`                                          | The full path of the PostgreSQL image including version.                                                                                                                                                    |
| `bootstrap_awx_docker__memcached_image`            | `memcached`                                                                                       | The Memcached image to use for caching.                                                                                                                                                                       |
| `bootstrap_awx_docker__memcached_version`          | `alpine`                                                                                          | Version of Memcached to use.                                                                                                                                                                                  |
| `bootstrap_awx_docker__memcached_hostname`         | `memcached`                                                                                       | Hostname for the Memcached service.                                                                                                                                                                           |
| `bootstrap_awx_docker__memcached_port`             | `"11211"`                                                                                         | Port number for the Memcached service.                                                                                                                                                                        |
| `bootstrap_awx_docker__compose_start_containers`   | `true`                                                                                            | Whether to start containers using Docker Compose.                                                                                                                                                             |
| `bootstrap_awx_docker__task_hostname`              | `awx`                                                                                             | Hostname for the AWX task container.                                                                                                                                                                          |
| `bootstrap_awx_docker__web_hostname`               | `awxweb`                                                                                          | Hostname for the AWX web container.                                                                                                                                                                           |
| `bootstrap_awx_docker__postgres_data_dir`          | `~/.awx/pgdocker`                                                                                 | Directory where PostgreSQL data will be stored.                                                                                                                                                               |
| `bootstrap_awx_docker__host_port`                  | `80`                                                                                              | Host port to expose the AWX web interface on HTTP.                                                                                                                                                          |
| `bootstrap_awx_docker__host_port_ssl`              | `443`                                                                                             | Host port to expose the AWX web interface on HTTPS.                                                                                                                                                         |
| `bootstrap_awx_docker__docker_compose_dir`         | `~/.awx/awxcompose`                                                                               | Directory where Docker Compose configuration files are stored.                                                                                                                                                |
| `bootstrap_awx_docker__container_prefix`           | `awx`                                                                                             | Prefix for container names.                                                                                                                                                                                   |
| `bootstrap_awx_docker__docker_registry_repository` | `awx`                                                                                             | Repository name in the Docker registry.                                                                                                                                                                       |
| `bootstrap_awx_docker__pg_username`                | `awx`                                                                                             | Username for PostgreSQL database access.                                                                                                                                                                      |
| `bootstrap_awx_docker__pg_password`                | `pgpass`                                                                                          | Password for PostgreSQL database access.                                                                                                                                                                      |
| `bootstrap_awx_docker__pg_database`                | `awx`                                                                                             | Name of the PostgreSQL database to use.                                                                                                                                                                       |
| `bootstrap_awx_docker__pg_port`                    | `5432`                                                                                            | Port number for the PostgreSQL service.                                                                                                                                                                       |
| `bootstrap_awx_docker__admin_user`                 | `admin`                                                                                           | Admin username for AWX.                                                                                                                                                                                     |
| `bootstrap_awx_docker__admin_password`             | `password`                                                                                        | Admin password for AWX.                                                                                                                                                                                     |
| `bootstrap_awx_docker__create_preload_data`        | `true`                                                                                            | Whether to create preload data during the setup process.                                                                                                                                                    |
| `bootstrap_awx_docker__secret_key`                 | `awxsecret`                                                                                       | Secret key used by AWX for cryptographic signing.                                                                                                                                                           |
| `bootstrap_awx_docker__container_config_templates` | List of configuration files and modes (e.g., `environment.sh`, `credentials.py`)                  | Configuration templates to be rendered and placed in the Docker Compose directory.                                                                                                                            |
| `bootstrap_awx_docker__web_volumes`                | List of volumes for the web container                                                             | Volumes to mount inside the AWX web container.                                                                                                                                                              |
| `bootstrap_awx_docker__task_volumes`               | List of volumes for the task container                                                            | Volumes to mount inside the AWX task container.                                                                                                                                                             |

## Usage

To use this role, include it in your Ansible playbook and provide any necessary variables as needed. Here is an example playbook:

```yaml
---
- name: Deploy AWX using Docker
  hosts: all
  become: yes
  roles:
    - role: bootstrap_awx_docker
      vars:
        bootstrap_awx_docker__version: "20.1.0"
        bootstrap_awx_docker__docker_registry: "registry.example.int:5000"
        bootstrap_awx_docker__docker_registry_username: "registryuser"
        bootstrap_awx_docker__docker_registry_password: "password"
```

## Dependencies

This role depends on the following Ansible collections:

- `community.docker`
- `awx.awx`

Ensure these collections are installed before running this role. You can install them using:

```bash
ansible-galaxy collection install community.docker awx.awx
```

## Best Practices

1. **Secure Credentials**: Ensure that sensitive information such as passwords and secrets is managed securely, for example by using Ansible Vault.
2. **Version Control**: Keep track of changes to your inventory files and configuration templates in a version control system.
3. **Backup Data**: Regularly back up PostgreSQL data stored in `bootstrap_awx_docker__postgres_data_dir` to prevent data loss.

## Molecule Tests

This role includes Molecule tests to verify its functionality. To run the tests, navigate to the role directory and execute:

```bash
molecule test
```

Ensure that Docker is installed and running on your system before executing the tests.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_awx_docker/defaults/main.yml)
- [tasks/build_image.yml](../../roles/bootstrap_awx_docker/tasks/build_image.yml)
- [tasks/check_docker.yml](../../roles/bootstrap_awx_docker/tasks/check_docker.yml)
- [tasks/compose.yml](../../roles/bootstrap_awx_docker/tasks/compose.yml)
- [tasks/main.yml](../../roles/bootstrap_awx_docker/tasks/main.yml)
- [tasks/push_image.yml](../../roles/bootstrap_awx_docker/tasks/push_image.yml)
- [tasks/set_image.yml](../../roles/bootstrap_awx_docker/tasks/set_image.yml)
- [tasks/smoke_test.yml](../../roles/bootstrap_awx_docker/tasks/smoke_test.yml)