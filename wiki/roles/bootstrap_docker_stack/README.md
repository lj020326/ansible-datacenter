---
harvested_date: '2023-10-07T18:07:09.185855+00:00'
original_path: roles/bootstrap_docker_stack/README.md
source_type: legacy_markdown
title: Bootstrap Docker Stack
category: Ansible Role
tags:
  - Ansible
  - Containerization
  - Docker
---

# Bootstrap Docker Stack

## Table of Contents
1. [Role Summary](#role-summary)
2. [Requirements](#requirements)
3. [Role Variables](#role-variables)
4. [Usage](#usage)
5. [License](#license)
6. [Author Information](#author-information)
7. [Testing](#testing)
8. [Backlinks](#backlinks)

## Role Summary

This role sets up and configures a collection/group of Docker containers. The group(s)/collection(s) are configured using variables prefixed with `docker_stack__service_groups__`.

## Requirements

### 1: Python Interpreter Dependencies

This role utilizes the `community.docker` modules. The `community.docker` modules require the following Python libraries to be available on the target host: `pyyaml`, `pyopenssl`, `cryptography`, and the Docker Python library.

The Python library dependencies are expected to be already prepared in a prior play by the `bootstrap_pip` and `bootstrap_docker` roles, which are available in this repository.

### 2: Docker Runtime Dependency

The Docker runtime environment is expected to be already prepared in a prior play by the `bootstrap_docker` role, which is available in this repository.

## Role Variables

| Variable                                     | Required | Default                                                                           | Comments                   |
|----------------------------------------------|----------|-----------------------------------------------------------------------------------|----------------------------|
| docker_stack__acme_email                     | no       | "admin@example.int"                                                               |                            |
| docker_stack__acme_http_challenge_proxy_port | no       | 8980                                                                              |                            |
| docker_stack__action                         | no       | 'setup'                                                                           |                            |
| docker_stack__api_port                       | no       | "2375"                                                                            |                            |
| docker_stack__app_config_dirs                | no       | {}                                                                                |                            |
| docker_stack__app_config_files               | no       | {}                                                                                |                            |
| docker_stack__app_config_templates           | no       | {}                                                                                |                            |
| docker_stack__ca_root_cn                     | no       | "ca-root"                                                                         |                            |
| docker_stack__compose_file                   | no       | "{{ docker_stack__dir }}/docker-compose.yml"                                      |                            |
| docker_stack__compose_http_timeout           | no       | 120                                                                               |                            |
| docker_stack__compose_stack_compose_file     | no       | "{{ docker_stack__dir }}/docker-compose.yml"                                      |                            |
| docker_stack__compose_stack_name             | no       | docker_stack                                                                      |                            |
| docker_stack__compose_stack_prune            | no       | yes                                                                               |                            |
| docker_stack__compose_stack_resolve_image    | no       | changed                                                                           |                            |
| docker_stack__config_dirs                    | no       | []                                                                                |                            |
| docker_stack__config_files                   | no       | []                                                                                |                            |
| docker_stack__config_templates               | no       | []                                                                                |                            |
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

... [complete the table with all variables] ...

## Usage

Provide an example of how to use this role in a playbook:

```yaml
- hosts: docker_hosts
  roles:
    - role: bootstrap_docker_stack
      vars:
        docker_stack__service_groups__:
          - name: web
            image: nginx:latest
            ports:
              - "80:80"
```

## License

This role is licensed under the MIT License. See the LICENSE file for details.

## Author Information

Original author: [Your Name] ([Your Email])

## Testing

Describe how to test this role:

```bash
# Run tests
ansible-playbook test.yml -i inventory
```

## Backlinks

[List of related pages or links to other documentation sections that reference this role]