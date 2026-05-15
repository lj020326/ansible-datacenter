```markdown
---
title: bootstrap_docker_stack Role Documentation
original_path: roles/bootstrap_docker_stack/README.md
category: Ansible Roles
tags: [docker, ansible, automation]
---

# bootstrap_docker_stack

## Role Summary

This role sets up and configures a collection or group of Docker containers. The configuration is managed using variables prefixed with `docker_stack__service_groups__`.

## Requirements

### 1. Python Interpreter Dependencies

This role utilizes the `community.docker` modules, which require specific Python libraries (`pyyaml`, `pyopenssl`, `cryptography`, etc.) and the Docker Python library to be installed on the target host.

**Note:** These dependencies are expected to be installed by the `bootstrap_pip` and `bootstrap_docker` roles available in this repository.

### 2. Docker Runtime Dependency

The Docker runtime environment must be set up beforehand using the `bootstrap_docker` role, also available in this repository.

## Role Variables

| Variable                                     | Required | Default                                                                           | Comments                   |
|----------------------------------------------|----------|-----------------------------------------------------------------------------------|----------------------------|
| docker_stack__acme_email                     | no       | "admin@example.int"                                                               |                            |
| docker_stack__acme_http_challenge_proxy_port | no       | 8980                                                                              |                            |
| docker_stack__action                         | no       | 'setup'                                                                           |                            |
| docker_stack__api_port                       | no       | "2375"                                                                            |                            |
| docker_stack__app_config_dirs                | no       | {}                                                                                |                            |
| docker_stack__app_config_files               | no       | {}                                                                                |                            |
| docker_stack__app_config_tpls                | no       | {}                                                                                |                            |
| docker_stack__ca_root_cn                     | no       | "ca-root"                                                                         |                            |
| docker_stack__compose_file                   | no       | "{{ docker_stack__dir }}/docker-compose.yml"                                      |                            |
| docker_stack__compose_http_timeout           | no       | 120                                                                               |                            |
| docker_stack__compose_stack_compose_file     | no       | "{{ docker_stack__dir }}/docker-compose.yml"                                      |                            |
| docker_stack__compose_stack_name             | no       | docker_stack                                                                      |                            |
| docker_stack__compose_stack_prune            | no       | yes                                                                               |                            |
| docker_stack__compose_stack_resolve_image    | no       | changed                                                                           |                            |
| docker_stack__config_dirs                    | no       | []                                                                                |                            |
| docker_stack__config_files                   | no       | []                                                                                |                            |
| docker_stack__config_tpls                    | no       | []                                                                                |                            |
| docker_stack__config_users_group             | no       |                                                                                   |                            |
| docker_stack__config_users_passwd            | no       |                                                                                   |                            |
| docker_stack__configs                        | no       | {}                                                                                |                            |
| docker_stack__container_configs              | no       | {}                                                                                |                            |
| docker_stack__container_user_home            | no       | /var/internaluser                                                                 |                            |
| docker_stack__dir                            | no       | "{{ docker_stack__user_home }}/docker"                                            |                            |
| docker_stack__docker_group_gid               | no       | 991                                                                               |                            |
| docker_stack__email_default_suffix           | no       | "@example.com"                                                                    |                            |
| docker_stack__email_from                     | no       | "admin@example.com"                                                               |                            |
| docker_stack__email_jenkins_admin_address    | no       | "admin@example.com"                                                               |                            |

## Backlinks

- [Ansible Roles Index](../README.md)
```

This improved version includes a clean and professional structure with proper headings, YAML frontmatter for better metadata management, and a "Backlinks" section to help navigate related documentation.