---
title: Bootstrap LDAP Client Role Documentation
role: bootstrap_ldap_client
category: System Configuration
type: Ansible Role
tags: ldap, client, authentication, nslcd, pam

## Summary
The `bootstrap_ldap_client` role is designed to configure a system as an LDAP client. It installs necessary packages, configures NSS and PAM settings, and sets up the NSLCD service to allow user and group information to be retrieved from an LDAP server.

## Variables

| Variable Name                           | Default Value                                                                                     | Description                                                                                                                                                                                                 |
|-----------------------------------------|---------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_ldap_client__domain`         | `example.int`                                                                                   | The domain name of the LDAP server.                                                                                                                                                                         |
| `bootstrap_ldap_client__host`           | `ldap.{{ bootstrap_ldap_client__domain }}`                                                         | The hostname of the LDAP server, derived from the domain.                                                                                                                                                 |
| `bootstrap_ldap_client__port`           | `"389"`                                                                                           | The port number used to connect to the LDAP server.                                                                                                                                                         |
| `bootstrap_ldap_client__endpoint`       | `"{{ bootstrap_ldap_client__host }}:{{ bootstrap_ldap_client__port }}"`                             | The endpoint for connecting to the LDAP server, combining host and port.                                                                                                                                    |
| `bootstrap_ldap_client__uri`            | `ldap://{{ bootstrap_ldap_client__endpoint }}/`                                                   | The URI used to connect to the LDAP server.                                                                                                                                                                 |
| `bootstrap_ldap_client__sudoers`        | `true`                                                                                            | Whether to enable sudoers support via LDAP.                                                                                                                                                                 |
| `bootstrap_ldap_client__base_dn`        | `dc=example,dc=int`                                                                               | The base distinguished name (DN) for the LDAP directory.                                                                                                                                                    |
| `bootstrap_ldap_client__nss_user_filter`| `(objectClass=posixAccount)`                                                                      | The filter used to find user entries in the LDAP directory.                                                                                                                                                 |
| `bootstrap_ldap_client__base_sudoers`   | `ou=sudoers,{{ bootstrap_ldap_client__base_dn }}`                                                 | The base DN for sudoers entries.                                                                                                                                                                            |
| `bootstrap_ldap_client__lookups`        | (see below)                                                                                       | A dictionary defining various LDAP lookups with their respective bases, scopes, and filters.                                                                                                                |
| `bootstrap_ldap_client__server_host`    | `"{{ bootstrap_ldap_client__host }}"`                                                             | The server host for LDAP connections, defaults to the main LDAP host.                                                                                                                                       |
| `bootstrap_ldap_client__sudo`           | `true`                                                                                            | Whether to enable sudo support via LDAP.                                                                                                                                                                    |
| `bootstrap_ldap_client__sudo_base`      | `ou=SUDOers,{{ bootstrap_ldap_client__base_dn }}`                                                 | The base DN for sudo entries.                                                                                                                                                                               |
| `bootstrap_ldap_client__nss_passwd`     | `true`                                                                                            | Whether to enable NSS passwd support via LDAP.                                                                                                                                                              |
| `bootstrap_ldap_client__nss_group`      | `true`                                                                                            | Whether to enable NSS group support via LDAP.                                                                                                                                                               |
| `bootstrap_ldap_client__nss_shadow`     | `true`                                                                                            | Whether to enable NSS shadow support via LDAP.                                                                                                                                                              |
| `bootstrap_ldap_client__nss_hosts`      | `true`                                                                                            | Whether to enable NSS hosts support via LDAP.                                                                                                                                                               |
| `bootstrap_ldap_client__nss_networks`   | `true`                                                                                            | Whether to enable NSS networks support via LDAP.                                                                                                                                                            |
| `bootstrap_ldap_client__path`           | `/etc/ldap/`                                                                                      | The path where LDAP configuration files will be stored.                                                                                                                                                     |

### Detailed Lookups Configuration
The `bootstrap_ldap_client__lookups` variable is a dictionary that defines various LDAP lookups. Each lookup has the following keys:
- **base**: The base DN for the lookup.
- **scope**: The scope of the search (e.g., `base`, `sub`).
- **filter**: The filter used to find entries in the LDAP directory.

Example configuration:
```yaml
bootstrap_ldap_client__lookups:
  admin:
    base: cn=admins,ou=groups,{{ bootstrap_ldap_client__base_dn }}
    scope: base
    filter: (member=%s)
```

## Usage

To use this role, include it in your playbook and set the necessary variables. Here is an example playbook:

```yaml
---
- name: Configure LDAP client on servers
  hosts: all
  become: yes
  roles:
    - role: bootstrap_ldap_client
      vars:
        bootstrap_ldap_client__domain: mydomain.com
        bootstrap_ldap_client__base_dn: dc=mydomain,dc=com
```

## Dependencies

This role has the following dependencies:

- `nss-pam-ldapd` or `libnss-ldapd`
- `openldap` or `ldap-utils`
- `pam-configs` (Debian-based systems)

These packages are installed automatically by the role based on the operating system family.

## Best Practices

1. **Backup Configuration Files**: The role creates backups of configuration files before making changes.
2. **Use Non-Interactive Mode**: For Debian-based systems, the role preseeds LDAP client selections to prevent interactive PAM drops.
3. **Clear NSCD Cache**: After configuring LDAP, the role clears the NSCD passwd cache to ensure that changes take effect immediately.

## Molecule Tests

This role does not currently include Molecule tests. Consider adding them for automated testing and validation of the role's functionality.

## Backlinks
- [defaults/main.yml](../../roles/bootstrap_ldap_client/defaults/main.yml)
- [tasks/configure_pam.Debian.yml](../../roles/bootstrap_ldap_client/tasks/configure_pam.Debian.yml)
- [tasks/configure_pam.RedHat.yml](../../roles/bootstrap_ldap_client/tasks/configure_pam.RedHat.yml)
- [tasks/main.yml](../../roles/bootstrap_ldap_client/tasks/main.yml)
- [handlers/main.yml](../../roles/bootstrap_ldap_client/handlers/main.yml)