---
title: Bootstrap Linux Locale Role Documentation
role: bootstrap_linux_locale
category: System Configuration
type: Ansible Role
tags: locale, language, configuration
---

## Summary

The `bootstrap_linux_locale` role is designed to ensure that the specified system locale and language settings are correctly configured on a Linux system. It uses the `community.general.locale_gen` module to generate necessary localization files and then applies these settings using the `localectl` command.

## Variables

| Variable Name                | Default Value       | Description                                                                 |
|------------------------------|---------------------|-----------------------------------------------------------------------------|
| `config_system_locale`       | `pt_PT.UTF-8`       | The desired system locale setting.                                          |
| `config_system_language`     | `en_US.UTF-8`       | The desired system language setting.                                        |

## Usage

To use the `bootstrap_linux_locale` role, include it in your playbook and optionally override the default values for `config_system_locale` and `config_system_language`.

### Example Playbook

```yaml
---
- name: Configure System Locale and Language
  hosts: all
  roles:
    - role: bootstrap_linux_locale
      vars:
        config_system_locale: "fr_FR.UTF-8"
        config_system_language: "fr_FR.UTF-8"
```

## Dependencies

This role depends on the `community.general` collection, which must be installed before running this role. You can install it using:

```bash
ansible-galaxy collection install community.general
```

## Tags

No specific tags are defined in this role.

## Best Practices

1. **Locale Availability**: Ensure that the specified locales (`config_system_locale` and `config_system_language`) are available on your system or in your Ansible environment.
2. **Testing**: Use Molecule tests to verify that the role correctly configures the locale settings as expected.
3. **Idempotency**: The role is designed to be idempotent, meaning it should not make unnecessary changes if the desired state is already achieved.

## Molecule Tests

No Molecule tests are provided with this role. However, you can create a `molecule` directory and define test scenarios to validate the role's functionality.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_linux_locale/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_linux_locale/tasks/main.yml)