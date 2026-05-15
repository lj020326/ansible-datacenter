---
title: Bootstrap Chrony Client Role Documentation
role: bootstrap_chronyclient
category: Ansible Roles
type: Configuration Management
tags: chrony, ntp, timezone, ansible
---

## Summary

The `bootstrap_chronyclient` role is designed to configure and manage the NTP (Network Time Protocol) service on target systems using the Chrony client. This role sets the system timezone, ensures that the deprecated `ntpdate` package is not installed, disables and masks the traditional NTP service (`ntpd`), installs and configures the Chrony client, and manages its configuration files.

## Variables
| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `timezone`    | `America/Denver` | The desired system timezone. This variable is set internally within the role but can be overridden if necessary. |

**Note:** Double-underscore variables (e.g., `__internal_var`) are internal to the role and should not be configured by users.

## Usage
To use the `bootstrap_chronyclient` role, include it in your playbook as follows:

```yaml
---
- name: Configure Chrony Client
  hosts: all
  roles:
    - role: bootstrap_chronyclient
```

Ensure that the secrets file (`~/0/vault/secrets.yml`) is correctly configured and accessible by Ansible.

## Dependencies
This role does not have any external dependencies beyond standard Ansible modules. However, it requires the following Ansible collections:

- `community.general`

You can install these collections using the following command:

```bash
ansible-galaxy collection install community.general
```

## Tags
The following tags are available for this role:

- `timezone`: Configures the system timezone.
- `ntpdate`: Ensures that `ntpdate` is not installed.
- `ntpd`: Disables and masks the NTP service (`ntpd`).
- `chrony`: Installs, configures, and manages the Chrony client.

You can use these tags to target specific tasks within the role. For example:

```bash
ansible-playbook playbook.yml --tags timezone,chrony
```

## Best Practices
- Always ensure that your Ansible environment is up-to-date with the latest collections.
- Use vaults to securely manage sensitive information such as keys and secrets.
- Test your playbooks in a staging environment before deploying them to production.

## Molecule Tests
This role does not include any Molecule tests. However, it is recommended to write and run tests to ensure that the role behaves as expected across different environments.

## Backlinks
- [tasks/main.yml](../../roles/bootstrap_chronyclient/tasks/main.yml)
- [handlers/main.yml](../../roles/bootstrap_chronyclient/handlers/main.yml)