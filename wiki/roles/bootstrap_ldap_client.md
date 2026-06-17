---
title: Bootstrap LDAP Client Role Documentation
role: bootstrap_ldap_client
category: System Configuration
type: Ansible Role
tags: ldap, client, nslcd, pam, ssh

## Summary
The `bootstrap_ldap_client` role is designed to configure a system as an LDAP client. It installs necessary packages, configures LDAP authentication and authorization settings, sets up PAM (Pluggable Authentication Modules) for LDAP integration, and ensures that the SSH daemon uses PAM for authentication. This role supports multiple Linux distributions including Debian-based systems (Debian, Ubuntu) and Red Hat-based systems (RedHat, CentOS, Fedora, Scientific).

## Variables

| Variable Name                             | Default Value                                                                                   | Description                                                                                                                                                                                                 |
|-------------------------------------------|-------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_ldap_client__domain`           | `example.int`                                                                                   | The domain name of the LDAP server.                                                                                                                                                                         |
| `bootstrap_ldap_client__host`             | `ldap.{{ bootstrap_ldap_client__domain }}`                                                       | The hostname of the LDAP server, constructed from the domain name.                                                                                                                                          |
| `bootstrap_ldap_client__port`             | `"389"`                                                                                         | The port number on which the LDAP server is listening.                                                                                                                                                      |
| `bootstrap_ldap_client__endpoint`         | `{{ bootstrap_ldap_client__host }}:{{ bootstrap_ldap_client__port }}`                             | The endpoint of the LDAP server, constructed from the host and port.                                                                                                                                        |
| `bootstrap_ldap_client__uri`              | `ldap://{{ bootstrap_ldap_client__endpoint }}/`                                                 | The URI used to connect to the LDAP server.                                                                                                                                                                 |
| `bootstrap_ldap_client__sudoers`          | `true`                                                                                          | Whether to enable sudoers integration with LDAP.                                                                                                                                                            |
| `bootstrap_ldap_client__base_dn`          | `dc=example,dc=int`                                                                             | The base distinguished name (DN) for the LDAP directory.                                                                                                                                                  |
| `bootstrap_ldap_client__nss_user_filter`  | `(objectClass=posixAccount)`                                                                    | The filter used to locate user entries in the LDAP directory.                                                                                                                                             |
| `bootstrap_ldap_client__base_sudoers`     | `ou=sudoers,{{ bootstrap_ldap_client__base_dn }}`                                               | The base DN for sudoers entries in the LDAP directory.                                                                                                                                                    |
| `bootstrap_ldap_client__lookups`          | A dictionary defining various LDAP lookups with their respective bases, scopes, and filters.       | Configures different types of LDAP lookups (e.g., admin, user, host, membership) used by NSS (Name Service Switch).                                                                                           |
| `bootstrap_ldap_client__server_host`      | `{{ bootstrap_ldap_client__host }}`                                                             | The hostname of the LDAP server for configuration purposes.                                                                                                                                                 |
| `bootstrap_ldap_client__sudo`             | `true`                                                                                          | Whether to enable sudoers integration with LDAP.                                                                                                                                                            |
| `bootstrap_ldap_client__sudo_base`        | `ou=SUDOers,{{ bootstrap_ldap_client__base_dn }}`                                               | The base DN for sudoers entries in the LDAP directory.                                                                                                                                                    |
| `bootstrap_ldap_client__nss_passwd`       | `true`                                                                                          | Whether to enable NSS passwd lookups via LDAP.                                                                                                                                                              |
| `bootstrap_ldap_client__nss_group`        | `true`                                                                                          | Whether to enable NSS group lookups via LDAP.                                                                                                                                                               |
| `bootstrap_ldap_client__nss_shadow`       | `true`                                                                                          | Whether to enable NSS shadow lookups via LDAP.                                                                                                                                                              |
| `bootstrap_ldap_client__nss_hosts`        | `true`                                                                                          | Whether to enable NSS hosts lookups via LDAP.                                                                                                                                                               |
| `bootstrap_ldap_client__nss_networks`     | `true`                                                                                          | Whether to enable NSS networks lookups via LDAP.                                                                                                                                                            |
| `bootstrap_ldap_client__path`             | `/etc/ldap/`                                                                                    | The path where LDAP configuration files will be stored.                                                                                                                                                     |
| `bootstrap_ldap_client__nslcd_filter`     | An empty dictionary by default, intended to hold custom filters for nslcd.                          | Custom filters that can be used in the nslcd.conf file.                                                                                                                                                    |

## Usage
To use this role, include it in your playbook and set any necessary variables as needed. Here is an example of how to include the `bootstrap_ldap_client` role in a playbook:

```yaml
---
- hosts: all
  become: yes
  roles:
    - role: bootstrap_ldap_client
      vars:
        bootstrap_ldap_client__domain: mydomain.com
        bootstrap_ldap_client__base_dn: dc=mydomain,dc=com
```

## Dependencies
This role has no external dependencies other than the packages it installs. However, it requires that the target system is running a supported Linux distribution (Debian-based or Red Hat-based).

## Best Practices
- Ensure that the LDAP server is properly configured and accessible from the client systems.
- Verify that the provided `base_dn` and filters match your LDAP directory structure.
- Test the role in a staging environment before deploying it to production.

## Molecule Tests
This role does not include any Molecule tests at this time. However, it is recommended to write and run molecule tests to ensure the role behaves as expected across different operating systems.

## Backlinks
- [defaults/main.yml](../../roles/bootstrap_ldap_client/defaults/main.yml)
- [tasks/configure_pam.Debian.yml](../../roles/bootstrap_ldap_client/tasks/configure_pam.Debian.yml)
- [tasks/configure_pam.RedHat.yml](../../roles/bootstrap_ldap_client/tasks/configure_pam.RedHat.yml)
- [tasks/main.yml](../../roles/bootstrap_ldap_client/tasks/main.yml)
- [handlers/main.yml](../../roles/bootstrap_ldap_client/handlers/main.yml)