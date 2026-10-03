---
title: "Bootstrap IPA Kerberos (bootstrap_ipa_krb5)"
role: bootstrap_ipa_krb5
category: Identity Management
type: Role
tags: [ansible, role, bootstrap_ipa_krb5]
---

# Bootstrap IPA Kerberos (bootstrap_ipa_krb5)

This Ansible role configures Kerberos (krb5) on a system, preparing it for integration with an IPA (Identity, Policy, Audit) server. It installs necessary packages, backs up existing configuration files, and templates a new krb5.conf file based on provided variables.

## Variables

| Variable Name                | Default Value                                                                 | Description                                                                                       |
|------------------------------|-------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------|
| `krb5_packages`              | `krb5-workstation`                                                           | List of Kerberos packages to install.                                                             |
| `krb5_conf`                  | `/etc/krb5.conf`                                                             | Path to the Kerberos configuration file.                                                          |
| `krb5_conf_d`                | `/etc/krb5.conf.d/`                                                          | Directory for additional Kerberos configuration files.                                            |
| `krb5_include_d`             | `/var/lib/sss/pubconf/krb5.include.d/`                                       | Directory for SSSD public configuration includes.                                                 |
| `krb5_realm`                 |                                                                               | Kerberos realm to configure.                                                                      |
| `krb5_servers`               |                                                                               | List of Kerberos servers.                                                                         |
| `krb5_dns_lookup_realm`      | `"false"`                                                                     | Whether to use DNS to look up Kerberos realms.                                                     |
| `krb5_dns_lookup_kdc`        | `"false"`                                                                     | Whether to use DNS to look up Kerberos Key Distribution Centers (KDCs).                            |
| `krb5_no_default_domain`     | `"false"`                                                                     | Whether to append the default domain to short usernames.                                          |
| `krb5_default_ccache_name`   | `KEYRING:persistent:%{uid}`                                                   | Default credential cache name.                                                                    |

## Usage

To use this role, include it in your playbook and set the necessary variables:

```yaml
- hosts: all
  roles:
    - role: bootstrap_ipa_krb5
      vars:
        krb5_realm: "EXAMPLE.COM"
        krb5_servers:
          - "kdc1.example.com"
          - "kdc2.example.com"
```

## Dependencies

This role does not have any dependencies.

## Best Practices

- Ensure that the Kerberos realm and server variables are correctly set according to your IPA server configuration.
- Review and customize the `krb5.conf.j2` template as needed to fit your specific environment.
- Regularly back up the original `krb5.conf` file before applying changes.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_ipa_krb5/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_ipa_krb5/tasks/main.yml)
- [meta/main.yml](../../roles/bootstrap_ipa_krb5/meta/main.yml)