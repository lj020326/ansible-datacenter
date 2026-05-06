---
title: "bootstrap_ipa_krb5 Role Documentation"
role: bootstrap_ipa_krb5
category: Configuration
type: Ansible Role
tags: [identity, ipa]
---

## Summary

The `bootstrap_ipa_krb5` role is designed to configure Kerberos (krb5) on a target system. It installs the necessary krb5 packages, backs up the existing `krb5.conf` file, and deploys a new configuration template tailored for use with Identity Management (IPA).

## Variables

| Variable Name                | Default Value                              | Description                                                                 |
|------------------------------|--------------------------------------------|-----------------------------------------------------------------------------|
| `krb5_packages`              | `krb5-workstation`                         | The list of krb5 packages to install.                                       |
| `krb5_conf`                  | `/etc/krb5.conf`                           | Path to the main krb5 configuration file.                                   |
| `krb5_conf_d`                | `/etc/krb5.conf.d/`                        | Directory for additional krb5 configuration files.                          |
| `krb5_include_d`             | `/var/lib/sss/pubconf/krb5.include.d/`     | Directory for SSSD-generated krb5 include files.                            |
| `krb5_realm`                 |                                            | The Kerberos realm to configure (must be set by the user).                  |
| `krb5_servers`               |                                            | List of Kerberos Key Distribution Centers (KDCs) (must be set by the user).|
| `krb5_dns_lookup_realm`      | `"false"`                                  | Whether DNS should be used to find the Kerberos realm.                      |
| `krb5_dns_lookup_kdc`        | `"false"`                                  | Whether DNS should be used to locate KDCs.                                |
| `krb5_no_default_domain`     | `"false"`                                  | Whether to disable appending the default domain to unqualified names.       |
| `krb5_default_ccache_name`   | `KEYRING:persistent:%{uid}`                | Default credential cache name template.                                     |

## Usage

To use this role, include it in your playbook and set the required variables such as `krb5_realm` and `krb5_servers`. Here is an example playbook:

```yaml
---
- hosts: all
  become: yes
  roles:
    - role: bootstrap_ipa_krb5
      vars:
        krb5_realm: "EXAMPLE.COM"
        krb5_servers:
          - kdc1.example.com
          - kdc2.example.com
```

## Dependencies

This role has no external dependencies.

## Tags

- `identity`
- `ipa`

## Best Practices

- Ensure that the `krb5_realm` and `krb5_servers` variables are correctly set to match your Kerberos environment.
- Review the generated `krb5.conf` file for correctness after applying this role.
- Consider using Ansible Vault to manage sensitive information such as Kerberos server details.

## Molecule Tests

This role does not include any Molecule tests at this time. Future versions may include test scenarios to validate the configuration.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_ipa_krb5/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_ipa_krb5/tasks/main.yml)
- [meta/main.yml](../../roles/bootstrap_ipa_krb5/meta/main.yml)