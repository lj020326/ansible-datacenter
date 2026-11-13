---
title: "Bootstrap AWX Docker Role"
role: roles/bootstrap_awx_docker
category: Infrastructure
type: ansible-role
tags: [ansible, role, bootstrap_awx_docker]
---

# Bootstrap AWX Docker Role

The `bootstrap_awx_docker` role automates the deployment of AWX using Docker containers. It provides a streamlined process for setting up AWX with customizable configurations, ensuring that all necessary services (PostgreSQL, Redis, Memcached, etc.) are properly configured and started.

## Variables

| Variable Name                                      | Default Value                          | Description                                                                                         |
|----------------------------------------------------|----------------------------------------|-----------------------------------------------------------------------------------------------------|
| `bootstrap_awx_docker__docker_registry`            | `registry.example.int:5000`            | Docker registry URL                                                                                 |
| `bootstrap_awx_docker__docker_registry_username`   | `registryuser`                         | Docker registry username                                                                           |
| `bootstrap_awx_docker__docker_registry_password`   | `password`                             | Docker registry password                                                                           |
| `bootstrap_awx_docker__version`                    | `20.1.0`                               | AWX version to deploy                                                                              |
| `bootstrap_awx_docker__web_image`                  | `awx`                                  | Docker image for the AWX web service                                                               |
| `bootstrap_awx_docker__task_image`                 | `awx`                                  | Docker image for the AWX task service                                                               |
| `bootstrap_awx_docker__inventory_dir`              | `~/.awx`                               | Directory for AWX inventory files                                                                  |
| `bootstrap_awx_docker__redis_image`                | `redis`                                | Docker image for Redis                                                                             |
| `bootstrap_awx_docker__postgresql_version`         | `14.2`                                 | PostgreSQL version                                                                                 |
| `bootstrap_awx_docker__postgresql_image`           | `postgres:14.2`                        | Docker image for PostgreSQL                                                                         |
| `bootstrap_awx_docker__memcached_image`            | `memcached`                             | Docker image for Memcached                                                                         |
| `bootstrap_awx_docker__memcached_version`          | `alpine`                               | Memcached version                                                                                  |
| `bootstrap_awx_docker__memcached_hostname`         | `memcached`                             | Memcached hostname                                                                                 |
| `bootstrap_awx_docker__memcached_port`             | `11211`                                | Memcached port                                                                                     |
| `bootstrap_awx_docker__compose_start_containers`   | `true`                                 | Whether to start containers using Docker Compose                                                   |
| `bootstrap_awx_docker__task_hostname`              | `awx`                                  | Hostname for the AWX task service                                                                  |
| `bootstrap_awx_docker__web_hostname`               | `awxweb`                               | Hostname for the AWX web service                                                                    |
| `bootstrap_awx_docker__postgres_data_dir`          | `~/.awx/pgdocker`                      | Directory for PostgreSQL data                                                                       |
| `bootstrap_awx_docker__host_port`                  | `80`                                   | Host port for AWX web service                                                                     |
| `bootstrap_awx_docker__host_port_ssl`              | `443`                                  | Host port for SSL connections                                                                       |
| `bootstrap_awx_docker__docker_compose_dir`         | `~/.awx/awxcompose`                    | Directory for Docker Compose files                                                                  |
| `bootstrap_awx_docker__container_prefix`           | `awx`                                  | Prefix for container names                                                                         |
| `bootstrap_awx_docker__docker_registry_repository` | `awx`                                  | Repository name in the Docker registry                                                             |
| `bootstrap_awx_docker__pg_username`                | `awx`                                  | PostgreSQL username                                                                               |
| `bootstrap_awx_docker__pg_password`                | `pgpass`                               | PostgreSQL password                                                                               |
| `bootstrap_awx_docker__pg_database`                | `awx`                                  | PostgreSQL database name                                                                           |
| `bootstrap_awx_docker__pg_port`                    | `5432`                                 | PostgreSQL port                                                                                   |
| `bootstrap_awx_docker__admin_user`                 | `admin`                                | AWX admin username                                                                               |
| `bootstrap_awx_docker__admin_password`             | `password`                             | AWX admin password                                                                               |
| `bootstrap_awx_docker__create_preload_data`        | `true`                                 | Whether to create preload data                                                                     |
| `bootstrap_awx_docker__secret_key`                 | `awxsecret`                            | Secret key for AWX                                                                               |
| `bootstrap_awx_docker__container_config_templates` | See [defaults/main.yml](../../roles/bootstrap_awx_docker/defaults/main.yml) | List of container configuration templates                                                          |
| `bootstrap_awx_docker__web_volumes`                | See [defaults/main.yml](../../roles/bootstrap_awx_docker/defaults/main.yml) | Volumes for the AWX web service                                                                   |
| `bootstrap_awx_docker__task_volumes`               | See [defaults/main.yml](../../roles/bootstrap_awx_docker/defaults/main.yml) | Volumes for the AWX task service                                                                   |

## Usage

To use the `bootstrap_awx_docker` role, include it in your playbook and define the necessary variables. Here is an example playbook:

```yaml
---
- name: Deploy AWX using Docker
  hosts: awx_hosts
  become: yes
  roles:
    - role: bootstrap_awx_docker
      vars:
        bootstrap_awx_docker__docker_registry: "your-docker-registry.example.com:5000"
        bootstrap_awx_docker__docker_registry_username: "your-registry-username"
        bootstrap_awx_docker__docker_registry_password: "your-registry-password"
        bootstrap_awx_docker__version: "21.0.0"
        bootstrap_awx_docker__admin_password: "your-admin-password"
```

## Dependencies

This role requires the following dependencies:

- `community.docker.docker_image`
- `community.docker.docker_container`
- `community.docker.docker_compose_v2`
- `awx.awx.job_launch`

Ensure these collections are installed in your Ansible environment.

## Best Practices

1. **Security**: Always use secure methods for handling sensitive information such as passwords and secret keys. Consider using Ansible Vault for encrypting sensitive variables.
2. **Backup**: Regularly back up your PostgreSQL data directory (`bootstrap_awx_docker__postgres_data_dir`) to prevent data loss.
3. **Monitoring**: Implement monitoring for your AWX deployment to ensure high availability and quick issue resolution.
4. **Updates**: Keep your AWX version up to date to benefit from the latest features and security patches.

## Example Inventory

Here is an example inventory file for using this role:

```ini
[awx_hosts]
awx.example.com
```

## Overriding Specific Tasks

To override specific tasks in this role, you can create a new playbook that includes the role and then use the `tasks` directive to specify your custom tasks:

```yaml
---
- name: Deploy AWX using Docker with custom tasks
  hosts: awx_hosts
  become: yes
  roles:
    - role: bootstrap_awx_docker
  tasks:
    - name: Custom task to run after bootstrap_awx_docker
      debug:
        msg: "This is a custom task"
```

## Troubleshooting

If you encounter issues with the role, consider the following troubleshooting steps:

1. **Check Docker Service**: Ensure the Docker service is running on the target host.
2. **Review Logs**: Check the logs for the AWX containers for any error messages.
3. **Network Issues**: Verify that there are no network issues preventing communication between containers.
4. **Permissions**: Ensure that the user running the Ansible playbook has the necessary permissions to manage Docker resources.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_awx_docker/defaults/main.yml)
- [tasks/build_image.yml](../../roles/bootstrap_awx_docker/tasks/build_image.yml)
- [tasks/check_docker.yml](../../roles/bootstrap_awx_docker/tasks/check_docker.yml)
- [tasks/compose.yml](../../roles/bootstrap_awx_docker/tasks/compose.yml)
- [tasks/main.yml](../../roles/bootstrap_awx_docker/tasks/main.yml)
- [tasks/push_image.yml](../../roles/bootstrap_awx_docker/tasks/push_image.yml)
- [tasks/set_image.yml](../../roles/bootstrap_awx_docker/tasks/set_image.yml)
- [tasks/smoke_test.yml](../../roles/bootstrap_awx_docker/tasks/smoke_test.yml)