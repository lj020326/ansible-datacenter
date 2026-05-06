---
title: "AWX Bootstrap Docker Role"
role: bootstrap_awx_docker
category: Ansible Roles
type: Infrastructure
tags: [awx, docker, automation]
---

## Summary

The `bootstrap_awx_docker` role is designed to automate the deployment of AWX (Ansible Web UI) using Docker. This role handles the setup of necessary directories, configuration files, and Docker containers for running AWX in a Docker environment. It also includes tasks for building, pushing, and managing container images, as well as performing smoke tests to ensure the deployment is successful.

## Variables

| Variable Name                           | Default Value                                                                 | Description                                                                                                                                                                                                 |
|-----------------------------------------|-------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `awx_docker_registry`                   | `registry.example.int:5000`                                                 | The Docker registry URL where AWX images will be pushed and pulled.                                                                                                                                         |
| `awx_docker_registry_username`          | `registryuser`                                                              | Username for authenticating with the Docker registry.                                                                                                                                                       |
| `awx_docker_registry_password`          | `password`                                                                  | Password for authenticating with the Docker registry.                                                                                                                                                       |
| `awx_version`                           | `20.1.0`                                                                    | The version of AWX to be deployed.                                                                                                                                                                          |
| `awx_web_image`                         | `awx`                                                                       | The name of the AWX web image.                                                                                                                                                                              |
| `awx_task_image`                        | `awx`                                                                       | The name of the AWX task image.                                                                                                                                                                             |
| `awx_web_docker_actual_image`           | `{{ awx_docker_registry }}/{{ awx_docker_registry_repository }}/{{ awx_web_image }}:{{ awx_version }}`  | The full path to the AWX web image in the Docker registry.                                                                                                                                                |
| `awx_task_docker_actual_image`          | `{{ awx_docker_registry }}/{{ awx_docker_registry_repository }}/{{ awx_task_image }}:{{ awx_version }}` | The full path to the AWX task image in the Docker registry.                                                                                                                                               |
| `awx_inventory_dir`                     | `~/.awx`                                                                    | Directory where inventory files and other configuration data will be stored.                                                                                                                              |
| `awx_redis_image`                       | `redis`                                                                     | The Redis image used for caching.                                                                                                                                                                           |
| `awx_postgresql_version`                | `"14.2"`                                                                    | Version of PostgreSQL to use for the database.                                                                                                                                                            |
| `awx_postgresql_image`                  | `postgres:{{awx_postgresql_version}}`                                       | Full name of the PostgreSQL image including version tag.                                                                                                                                                    |
| `awx_memcached_image`                   | `memcached`                                                                 | The Memcached image used for caching.                                                                                                                                                                       |
| `awx_memcached_version`                 | `alpine`                                                                    | Version of Memcached to use.                                                                                                                                                                                |
| `awx_memcached_hostname`                | `memcached`                                                                 | Hostname for the Memcached container.                                                                                                                                                                       |
| `awx_memcached_port`                    | `"11211"`                                                                   | Port number for Memcached.                                                                                                                                                                                  |
| `awx_compose_start_containers`          | `true`                                                                      | Whether to start the Docker containers after deployment.                                                                                                                                                    |
| `awx_task_hostname`                     | `awx`                                                                       | Hostname for the AWX task container.                                                                                                                                                                        |
| `awx_web_hostname`                      | `awxweb`                                                                    | Hostname for the AWX web container.                                                                                                                                                                         |
| `awx_postgres_data_dir`                 | `~/.awx/pgdocker`                                                           | Directory where PostgreSQL data will be stored.                                                                                                                                                             |
| `awx_host_port`                         | `80`                                                                        | Port number on the host machine to expose the AWX web interface over HTTP.                                                                                                                                |
| `awx_host_port_ssl`                     | `443`                                                                       | Port number on the host machine to expose the AWX web interface over HTTPS.                                                                                                                               |
| `awx_docker_compose_dir`                | `~/.awx/awxcompose`                                                         | Directory where Docker Compose configuration files will be stored.                                                                                                                                        |
| `awx_container_prefix`                  | `awx`                                                                       | Prefix for container names.                                                                                                                                                                                 |
| `awx_docker_registry_repository`        | `awx`                                                                       | Repository name in the Docker registry where AWX images are stored.                                                                                                                                         |
| `awx_pg_username`                       | `awx`                                                                       | Username for accessing the PostgreSQL database.                                                                                                                                                             |
| `awx_pg_password`                       | `pgpass`                                                                    | Password for accessing the PostgreSQL database.                                                                                                                                                             |
| `awx_pg_database`                       | `awx`                                                                       | Name of the PostgreSQL database used by AWX.                                                                                                                                                                |
| `awx_pg_port`                           | `5432`                                                                      | Port number for the PostgreSQL database.                                                                                                                                                                    |
| `awx_admin_user`                        | `admin`                                                                     | Username for the initial admin user in AWX.                                                                                                                                                                 |
| `awx_admin_password`                    | `password`                                                                  | Password for the initial admin user in AWX.                                                                                                                                                                 |
| `awx_create_preload_data`               | `true`                                                                      | Whether to create preload data during deployment.                                                                                                                                                           |
| `awx_secret_key`                        | `awxsecret`                                                                 | Secret key used by AWX for cryptographic signing and encoding purposes.                                                                                                                                     |
| `awx_container_config_templates`        | List of configuration files with modes                                      | List of configuration templates to be rendered into the Docker Compose directory.                                                                                                                           |
| `awx_web_volumes`                       | List of volume mappings                                                     | Volumes to mount in the AWX web container.                                                                                                                                                                  |
| `awx_task_volumes`                      | List of volume mappings                                                     | Volumes to mount in the AWX task container.                                                                                                                                                                 |

## Usage

To use this role, include it in your Ansible playbook and provide any necessary variables as needed. Here is an example playbook:

```yaml
---
- name: Deploy AWX using Docker
  hosts: awx_servers
  become: yes
  roles:
    - role: bootstrap_awx_docker
      vars:
        awx_version: 20.1.0
        awx_host_port: 8080
```

## Dependencies

- `community.docker` Ansible collection for Docker management tasks.
- `awx.awx` Ansible collection for AWX-specific tasks (used in smoke tests).

Ensure these collections are installed before running the playbook:

```bash
ansible-galaxy collection install community.docker
ansible-galaxy collection install awx.awx
```

## Tags

- `build`: Tasks related to building Docker images.
- `push`: Tasks related to pushing Docker images to a registry.
- `compose`: Tasks related to creating and managing Docker Compose configurations.
- `smoke_test`: Tasks for running smoke tests to verify the deployment.

To run tasks with specific tags, use the `--tags` option:

```bash
ansible-playbook -i inventory playbook.yml --tags build,push
```

## Best Practices

- Always specify a version of AWX in your playbook to ensure consistency.
- Use a secure Docker registry and manage credentials securely.
- Regularly update the PostgreSQL database and other dependencies to the latest versions for security and performance improvements.

## Molecule Tests

This role includes Molecule tests to verify its functionality. To run the tests, navigate to the role directory and execute:

```bash
molecule test
```

Ensure you have Molecule installed along with any necessary drivers (e.g., Docker).

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_awx_docker/defaults/main.yml)
- [tasks/build_image.yml](../../roles/bootstrap_awx_docker/tasks/build_image.yml)
- [tasks/check_docker.yml](../../roles/bootstrap_awx_docker/tasks/check_docker.yml)
- [tasks/compose.yml](../../roles/bootstrap_awx_docker/tasks/compose.yml)
- [tasks/main.yml](../../roles/bootstrap_awx_docker/tasks/main.yml)
- [tasks/push_image.yml](../../roles/bootstrap_awx_docker/tasks/push_image.yml)
- [tasks/set_image.yml](../../roles/bootstrap_awx_docker/tasks/set_image.yml)
- [tasks/smoke_test.yml](../../roles/bootstrap_awx_docker/tasks/smoke_test.yml)