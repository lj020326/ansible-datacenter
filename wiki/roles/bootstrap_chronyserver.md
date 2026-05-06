---
title: Bootstrap Chrony Server Role Documentation
role: bootstrap_chronyserver
category: Ansible Roles
type: Configuration Management
tags: chrony, ntp, timezone
---

## Summary

The `bootstrap_chronyserver` role is designed to configure a system as an NTP server using the `chrony` daemon. It sets the system's timezone, ensures that the deprecated `ntpdate` package is not installed, installs and configures `chrony`, and manages related services.

## Variables

| Variable Name        | Default Value | Description                                                                 |
|----------------------|---------------|-----------------------------------------------------------------------------|
| `timezone`           | America/Denver | The system timezone to be set.                                              |

**Note:** Double-underscore variables (e.g., `__internal_var`) are internal role variables and should not be configured by the user.

## Usage

To use this role, include it in your playbook as follows:

```yaml
- hosts: chrony_servers
  roles:
    - bootstrap_chronyserver
```

Ensure that you have a secrets file located at `~/0/vault/secrets.yml` for any sensitive data required by the role.

## Dependencies

This role does not have any external dependencies beyond standard Ansible modules and the presence of the `chrony` package in your system's repositories.

## Tags

- `timezone`: Configures the system timezone.
- `ntpdate`: Ensures `ntpdate` is uninstalled.
- `chrony`: Installs and configures `chrony`.
- `chrony_config`: Manages configuration files for `chrony`.

## Best Practices

- Always ensure that your Ansible control node has the necessary permissions to manage the target hosts.
- Use a secrets management tool like Ansible Vault to handle sensitive data included in `secrets.yml`.
- Regularly update the `chrony-server.conf.j2` and `chrony.keys.j2` templates as needed for your environment.

## Molecule Tests

This role does not include any Molecule tests at this time. Consider adding them to ensure the role functions correctly across different environments.

## Backlinks

- [tasks/main.yml](../../roles/bootstrap_chronyserver/tasks/main.yml)
- [handlers/main.yml](../../roles/bootstrap_chronyserver/handlers/main.yml)