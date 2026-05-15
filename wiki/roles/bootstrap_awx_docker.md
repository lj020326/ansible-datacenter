---
title: "AWX Bootstrap Docker Role"
role: bootstrap_awx_docker
category: Ansible Roles
type: Infrastructure as Code
tags: [ansible, awx, docker, automation]
---

## Summary

The `bootstrap_awx_docker` role is designed to automate the deployment of AWX (Ansible Web UI) using Docker. This role handles the setup of necessary directories, configuration files, and Docker containers required for running AWX in a Docker environment. It includes tasks for building, pushing, and managing Docker images, as well as starting and stopping Docker containers.

## Variables

| Variable Name                             | Default Value                                                                                      | Description                                                                                                                                                                                                 |
|-------------------------------------------|----------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `awx_docker_registry`                     | `registry.example.int:5000`                                                                      | The URL of the Docker registry where AWX images will be pushed.                                                                                                                                                |
| `awx_docker_registry_username`            | `registryuser`                                                                                   | Username for authenticating with the Docker registry.                                                                                                                                                        |
| `awx_docker_registry_password`            | `password`                                                                                         | Password for authenticating with the Docker registry.                                                                                                                                                        |
| `awx_version`                             | `20.1.0`                                                                                           | The version of AWX to be deployed.                                                                                                                                                                           |
| `awx_web_image`                           | `awx`                                                                                            | The name of the AWX web image.                                                                                                                                                                               |
| `awx_task_image`                          | `awx`                                                                                            | The name of the AWX task image.                                                                                                                                                                              |
| `awx_web_docker_actual_image`             | `{{ awx_docker_registry }}/{{ awx_docker_registry_repository }}/{{ awx_web_image }}:{{ awx_version }}` | The full path to the AWX web Docker image, including registry and version.                                                                                                                                   |
| `awx_task_docker_actual_image`            | `{{ awx_docker_registry }}/{{ awx_docker_registry_repository }}/{{ awx_task_image }}:{{ awx_version }}` | The full path to the AWX task Docker image, including registry and version.                                                                                                                                  |
| `awx_inventory_dir`                       | `~/.awx`                                                                                         | Directory where AWX inventory files will be stored.                                                                                                                                                          |
| `awx_redis_image`                         | `redis`                                                                                          | The name of the Redis image to use for caching.                                                                                                                                                              |
| `awx_postgresql_version`                  | `"14.2"`                                                                                         | Version of PostgreSQL to use as the database backend.                                                                                                                                                      |
| `awx_postgresql_image`                    | `postgres:{{ awx_postgresql_version }}`                                                           | The full path to the PostgreSQL Docker image, including version.                                                                                                                                             |
| `awx_memcached_image`                     | `memcached`                                                                                        | The name of the Memcached image to use for caching.                                                                                                                                                          |
| `awx_memcached_version`                   | `alpine`                                                                                         | Version of Memcached to use.                                                                                                                                                                                 |
| `awx_memcached_hostname`                  | `memcached`                                                                                      | Hostname for the Memcached container.                                                                                                                                                                        |
| `awx_memcached_port`                      | `"11211"`                                                                                        | Port number for Memcached.                                                                                                                                                                                   |
| `awx_compose_start_containers`            | `true`                                                                                           | Whether to start Docker containers after deployment.                                                                                                                                                         |
| `awx_task_hostname`                       | `awx`                                                                                            | Hostname for the AWX task container.                                                                                                                                                                         |
| `awx_web_hostname`                        | `awxweb`                                                                                         | Hostname for the AWX web container.                                                                                                                                                                          |
| `awx_postgres_data_dir`                   | `~/.awx/pgdocker`                                                                                | Directory where PostgreSQL data will be stored.                                                                                                                                                              |
| `awx_host_port`                           | `80`                                                                                             | Port number on the host machine to map to the AWX web container's port 80.                                                                                                                                   |
| `awx_host_port_ssl`                       | `443`                                                                                            | Port number on the host machine to map to the AWX web container's SSL port 443.                                                                                                                               |
| `awx_docker_compose_dir`                  | `~/.awx/awxcompose`                                                                              | Directory where Docker Compose configuration files will be stored.                                                                                                                                         |
| `awx_container_prefix`                    | `awx`                                                                                            | Prefix for AWX container names.                                                                                                                                                                              |
| `awx_docker_registry_repository`          | `awx`                                                                                            | Repository name in the Docker registry.                                                                                                                                                                      |
| `awx_pg_username`                         | `awx`                                                                                            | Username for the PostgreSQL database.                                                                                                                                                                        |
| `awx_pg_password`                         | `pgpass`                                                                                         | Password for the PostgreSQL database.                                                                                                                                                                        |
| `awx_pg_database`                         | `awx`                                                                                            | Name of the PostgreSQL database.                                                                                                                                                                             |
| `awx_pg_port`                             | `5432`                                                                                           | Port number for the PostgreSQL database.                                                                                                                                                                     |
| `awx_admin_user`                          | `admin`                                                                                          | Username for the AWX admin account.                                                                                                                                                                          |
| `awx_admin_password`                      | `password`                                                                                       | Password for the AWX admin account.                                                                                                                                                                          |
| `awx_create_preload_data`                 | `true`                                                                                           | Whether to create preload data during deployment.                                                                                                                                                            |
| `awx_secret_key`                          | `awxsecret`                                                                                      | Secret key used by AWX for cryptographic signing.                                                                                                                                                          |
| `awx_container_config_templates`          | List of configuration templates (e.g., `environment.sh`, `credentials.py`)                         | List of configuration files to be created and managed by the role.                                                                                                                                         |
| `awx_web_volumes`                         | List of volume mappings for web container                                                          | Volumes to mount in the AWX web container.                                                                                                                                                                 |
| `awx_task_volumes`                        | List of volume mappings for task container                                                         | Volumes to mount in the AWX task container.                                                                                                                                                                |

## Usage

To use this role, include it in your Ansible playbook and provide the necessary variables as shown below:

```yaml
- hosts: awx_servers
  roles:
    - role: bootstrap_awx_docker
      vars:
        awx_version: "20.1.0"
        awx_host_port: 8080
```

## Dependencies

This role depends on the following Ansible collections:

- `community.docker`
- `awx.awx`

Ensure these collections are installed before running the playbook:

```bash
ansible-galaxy collection install community.docker
ansible-galaxy collection install awx.awx
```

## Best Practices

1. **Security**: Ensure that sensitive information such as passwords and secret keys are stored securely, preferably using Ansible Vault.
2. **Version Control**: Use version control for your Ansible playbooks and roles to track changes and collaborate with other team members.
3. **Testing**: Test the role in a staging environment before deploying it to production to ensure that all configurations and dependencies are correctly set up.

## Molecule Tests

This role includes Molecule tests to verify its functionality. To run the tests, navigate to the role directory and execute:

```bash
molecule test
```

Ensure you have Molecule installed along with the necessary drivers (e.g., Docker).

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_awx_docker/defaults/main.yml)
- [tasks/build_image.yml](../../roles/bootstrap_awx_docker/tasks/build_image.yml)
- [tasks/check_docker.yml](../../roles/bootstrap_awx_docker/tasks/check_docker.yml)
- [tasks/compose.yml](../../roles/bootstrap_awx_docker/tasks/compose.yml)
- [tasks/main.yml](../../roles/bootstrap_awx_docker/tasks/main.yml)
- [tasks/push_image.yml](../../roles/bootstrap_awx_docker/tasks/push_image.yml)
- [tasks/set_image.yml](../../roles/bootstrap_awx_docker/tasks/set_image.yml)
- [tasks/smoke_test.yml](../../roles/bootstrap_awx_docker/tasks/smoke_test.yml)