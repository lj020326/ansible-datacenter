---
title: Bootstrap Nginx Service Role Documentation
role: bootstrap_nginx_service
category: Ansible Roles
type: Configuration Management
tags: [nginx, openresty, firewall, systemd]
---

## Summary

The `bootstrap_nginx_service` role is designed to configure and manage the OpenResty service on a Linux system. It includes tasks for configuring the firewall to allow Nginx traffic, installing the OpenResty systemd unit file, enabling the service, and ensuring it starts automatically.

## Variables

| Variable Name               | Default Value                 | Description                                                                 |
|-----------------------------|-------------------------------|-----------------------------------------------------------------------------|
| `nginx_firewalld_ports`     | `[80/tcp, 443/tcp]`           | List of ports to be opened in the firewall for Nginx traffic.                |

## Usage

To use this role, include it in your playbook and optionally override any default variables as needed:

```yaml
- hosts: webservers
  roles:
    - role: bootstrap_nginx_service
      nginx_firewalld_ports:
        - 80/tcp
        - 443/tcp
```

## Dependencies

This role depends on the `bootstrap_linux_firewalld` role for configuring firewall rules. Ensure that this role is available in your Ansible environment.

## Tags

- `firewall-config-nginx`: This tag can be used to run only the tasks related to configuring the firewall for Nginx.

Example usage with tags:

```bash
ansible-playbook -i inventory playbook.yml --tags=firewall-config-nginx
```

## Best Practices

1. **Firewalld Configuration**: Ensure that `firewalld` is enabled on your system before running this role, or manage its state using another role.
2. **Service Management**: The role ensures that the OpenResty service is enabled and started. Verify that the service starts correctly after applying the configuration.

## Molecule Tests

No Molecule tests are provided for this role at this time. Consider adding tests to ensure the role behaves as expected in different environments.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_nginx_service/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_nginx_service/tasks/main.yml)
- [handlers/main.yml](../../roles/bootstrap_nginx_service/handlers/main.yml)