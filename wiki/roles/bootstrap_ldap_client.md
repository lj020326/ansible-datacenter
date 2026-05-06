---
title: Bootstrap LDAP Client Role Documentation
role: bootstrap_ldap_client
category: Configuration Management
type: Ansible Role
tags: ldap, client, nslcd, pam, ssh

---

## Summary

The `bootstrap_ldap_client` role is designed to configure an LDAP client on various Linux distributions. It installs necessary packages, configures LDAP settings, sets up PAM for authentication, and ensures SSH uses PAM for user verification. The role supports multiple operating systems including RedHat-based (RedHat, CentOS, Fedora, Scientific), Debian, and Ubuntu.

## Variables

| Variable Name                          | Default Value                                                                                   | Description                                                                                                                                                                                                 |
|----------------------------------------|-------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_ldap_client__domain`        | `example.int`                                                                                 | The domain name of the LDAP server.                                                                                                                                                                          |
| `bootstrap_ldap_client__host`          | `ldap.{{ bootstrap_ldap_client__domain }}`                                                      | The hostname of the LDAP server, derived from the domain.                                                                                                                                                    |
| `bootstrap_ldap_client__port`          | `"389"`                                                                                         | The port number on which the LDAP server is listening.                                                                                                                                                       |
| `bootstrap_ldap_client__endpoint`      | `"{{ bootstrap_ldap_client__host }}:{{ bootstrap_ldap_client__port }}"`                          | The endpoint of the LDAP server, combining host and port.                                                                                                                                                    |
| `bootstrap_ldap_client__uri`           | `ldap://{{ bootstrap_ldap_client__endpoint }}/`                                                 | The URI used to connect to the LDAP server.                                                                                                                                                                  |
| `bootstrap_ldap_client__sudoers`       | `true`                                                                                          | Whether to configure sudoers via LDAP.                                                                                                                                                                       |
| `bootstrap_ldap_client__base_dn`       | `dc=example,dc=int`                                                                             | The base distinguished name (DN) for the LDAP directory.                                                                                                                                                     |
| `bootstrap_ldap_client__nss_user_filter` | `(objectClass=posixAccount)`                                                                    | The filter used to locate user entries in LDAP.                                                                                                                                                              |
| `bootstrap_ldap_client__base_sudoers`  | `ou=sudoers,{{ bootstrap_ldap_client__base_dn }}`                                               | The base DN for sudoers configuration.                                                                                                                                                                       |
| `bootstrap_ldap_client__lookups`       | A dictionary defining various LDAP lookups with bases, scopes, and filters.                     | Configures different types of LDAP lookups used by the system.                                                                                                                                             |
| `bootstrap_ldap_client__server_host`   | `"{{ bootstrap_ldap_client__host }}"`                                                            | The hostname of the LDAP server (same as `bootstrap_ldap_client__host`).                                                                                                                                     |
| `bootstrap_ldap_client__sudo`          | `true`                                                                                          | Whether to enable sudo configuration via LDAP.                                                                                                                                                               |
| `bootstrap_ldap_client__sudo_base`     | `ou=SUDOers,{{ bootstrap_ldap_client__base_dn }}`                                               | The base DN for sudo rules in LDAP.                                                                                                                                                                          |
| `bootstrap_ldap_client__nss_passwd`    | `true`                                                                                          | Whether to configure NSS (Name Service Switch) for password lookups via LDAP.                                                                                                                                |
| `bootstrap_ldap_client__nss_group`     | `true`                                                                                          | Whether to configure NSS for group lookups via LDAP.                                                                                                                                                         |
| `bootstrap_ldap_client__nss_shadow`    | `true`                                                                                          | Whether to configure NSS for shadow password (password hash) lookups via LDAP.                                                                                                                               |
| `bootstrap_ldap_client__nss_hosts`     | `true`                                                                                          | Whether to configure NSS for host lookups via LDAP.                                                                                                                                                          |
| `bootstrap_ldap_client__nss_networks`  | `true`                                                                                          | Whether to configure NSS for network lookups via LDAP.                                                                                                                                                       |
| `bootstrap_ldap_client__path`          | `/etc/ldap/`                                                                                    | The path where LDAP configuration files are stored.                                                                                                                                                            |

## Usage

To use the `bootstrap_ldap_client` role, include it in your playbook and provide necessary variables as needed. Here is an example:

```yaml
- hosts: all
  roles:
    - role: bootstrap_ldap_client
      vars:
        bootstrap_ldap_client__domain: mydomain.com
        bootstrap_ldap_client__base_dn: dc=mydomain,dc=com
```

## Dependencies

The role has dependencies based on the operating system:

- **RedHat-based (RedHat, CentOS, Fedora, Scientific)**:
  - `nss-pam-ldapd`
  - `openldap`
  - `openldap-clients` (for RedHat)
  - `libpam-ldapd`, `libnss-ldapd`, `ldap-utils` (for Debian/Ubuntu)

- **Debian/Ubuntu**:
  - `nslcd`
  - `nscd`
  - `libnss-ldapd`
  - `libpam-ldapd`
  - `ldap-utils`

## Tags

The role uses the following tags:

- `config`: Used for tasks related to configuration files and settings.

To run only the configuration tasks, use:

```bash
ansible-playbook playbook.yml --tags config
```

## Best Practices

1. **Backup Configuration Files**: The role creates backups of existing configuration files before making changes.
2. **Use Secure Connections**: Ensure that LDAP connections are secure by using LDAPS or configuring TLS in `ldap.conf`.
3. **Test Changes**: Use Molecule tests to verify the role's functionality on different operating systems.

## Molecule Tests

This role includes Molecule tests for various operating systems. To run the tests, navigate to the role directory and execute:

```bash
molecule test
```

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_ldap_client/defaults/main.yml)
- [tasks/configure_pam.Debian.yml](../../roles/bootstrap_ldap_client/tasks/configure_pam.Debian.yml)
- [tasks/configure_pam.RedHat.yml](../../roles/bootstrap_ldap_client/tasks/configure_pam.RedHat.yml)
- [tasks/main.yml](../../roles/bootstrap_ldap_client/tasks/main.yml)
- [handlers/main.yml](../../roles/bootstrap_ldap_client/handlers/main.yml)

---

This documentation provides a comprehensive overview of the `bootstrap_ldap_client` role, including its purpose, configuration variables, usage instructions, dependencies, and best practices.