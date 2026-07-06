---
title: Bootstrap LDAP Client Role Documentation
role: bootstrap_ldap_client
category: System Configuration
type: Ansible Role
tags: ldap, client, authentication, nslcd, pam

## Summary

The `bootstrap_ldap_client` role is designed to configure an LDAP client on a Linux system. It installs necessary packages, configures LDAP settings, and sets up PAM (Pluggable Authentication Modules) to authenticate users against an LDAP server. This role supports various distributions including RedHat-based systems (Red Hat Enterprise Linux, CentOS, Fedora, Scientific Linux), Debian, and Ubuntu.

## Variables

| Variable Name                         | Default Value                                                                                           | Description                                                                                                                                                                                                 |
|---------------------------------------|---------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_ldap_client__domain`       | `example.int`                                                                                           | The domain of the LDAP server.                                                                                                                                                                              |
| `bootstrap_ldap_client__host`         | `ldap.{{ bootstrap_ldap_client__domain }}`                                                               | The hostname of the LDAP server, derived from the domain.                                                                                                                                                   |
| `bootstrap_ldap_client__port`         | `"389"`                                                                                                 | The port number for the LDAP server.                                                                                                                                                                        |
| `bootstrap_ldap_client__endpoint`     | `{{ bootstrap_ldap_client__host }}:{{ bootstrap_ldap_client__port }}`                                     | The endpoint of the LDAP server, combining host and port.                                                                                                                                                   |
| `bootstrap_ldap_client__uri`          | `ldap://{{ bootstrap_ldap_client__endpoint }}/`                                                           | The URI for the LDAP server, including the protocol, endpoint, and trailing slash.                                                                                                                          |
| `bootstrap_ldap_client__binddn`       | `""`                                                                                                    | The distinguished name (DN) to bind to the LDAP server. Leave empty for anonymous binding.                                                                                                                    |
| `bootstrap_ldap_client__bindpw`       | `""`                                                                                                    | The password for the DN specified in `bootstrap_ldap_client__binddn`. Leave empty for anonymous binding.                                                                                                      |
| `bootstrap_ldap_client__sudoers`      | `true`                                                                                                  | Whether to enable sudoers support via LDAP.                                                                                                                                                                 |
| `bootstrap_ldap_client__base_dn`      | `dc=example,dc=int`                                                                                     | The base distinguished name (DN) for the LDAP directory.                                                                                                                                                      |
| `bootstrap_ldap_client__nss_user_filter` | `(objectClass=posixAccount)`                                                                          | The filter used to search for user entries in the LDAP directory.                                                                                                                                           |
| `bootstrap_ldap_client__base_sudoers` | `ou=sudoers,{{ bootstrap_ldap_client__base_dn }}`                                                       | The base DN for sudoers entries.                                                                                                                                                                            |
| `bootstrap_ldap_client__lookups`      | See defaults/main.yml                                                                                   | A dictionary defining various LDAP lookups with their respective bases, scopes, and filters.                                                                                                                |
| `bootstrap_ldap_client__server_host`  | `{{ bootstrap_ldap_client__host }}`                                                                     | The server host for LDAP operations, typically the same as `bootstrap_ldap_client__host`.                                                                                                                   |
| `bootstrap_ldap_client__sudo`         | `true`                                                                                                  | Whether to enable sudo support via LDAP.                                                                                                                                                                    |
| `bootstrap_ldap_client__sudo_base`    | `ou=SUDOers,{{ bootstrap_ldap_client__base_dn }}`                                                       | The base DN for sudo entries.                                                                                                                                                                               |
| `bootstrap_ldap_client__nss_passwd`   | `true`                                                                                                  | Whether to enable NSS (Name Service Switch) passwd support via LDAP.                                                                                                                                        |
| `bootstrap_ldap_client__nss_group`    | `true`                                                                                                  | Whether to enable NSS group support via LDAP.                                                                                                                                                               |
| `bootstrap_ldap_client__nss_shadow`   | `true`                                                                                                  | Whether to enable NSS shadow support via LDAP.                                                                                                                                                              |
| `bootstrap_ldap_client__nss_hosts`    | `true`                                                                                                  | Whether to enable NSS hosts support via LDAP.                                                                                                                                                               |
| `bootstrap_ldap_client__nss_networks` | `true`                                                                                                  | Whether to enable NSS networks support via LDAP.                                                                                                                                                            |
| `bootstrap_ldap_client__path`         | `/etc/ldap/`                                                                                            | The path where LDAP configuration files will be stored.                                                                                                                                                     |
| `bootstrap_ldap_client__nslcd_filter` | See defaults/main.yml                                                                                   | Custom filters for nslcd (Name Service Lookup Daemon).                                                                                                                                                    |

## Usage

To use the `bootstrap_ldap_client` role, include it in your playbook and provide necessary variables as needed. Here is an example of how to include this role in a playbook:

```yaml
- hosts: all
  roles:
    - role: bootstrap_ldap_client
      vars:
        bootstrap_ldap_client__domain: mydomain.com
        bootstrap_ldap_client__binddn: "cn=admin,dc=mydomain,dc=com"
        bootstrap_ldap_client__bindpw: "adminpassword"
```

## Dependencies

This role does not have any external dependencies other than the packages it installs. However, ensure that your system has internet access to download and install required packages.

## Best Practices

- Always specify `bootstrap_ldap_client__domain`, `bootstrap_ldap_client__host`, and `bootstrap_ldap_client__base_dn` according to your LDAP server configuration.
- For security reasons, avoid hardcoding sensitive information like `bootstrap_ldap_client__bindpw`. Consider using Ansible Vault or environment variables to manage secrets.
- Test the role in a staging environment before applying it to production systems.

## Molecule Tests

This role includes molecule tests to verify its functionality. To run the tests, ensure you have molecule installed and execute:

```bash
molecule test
```

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_ldap_client/defaults/main.yml)
- [tasks/configure_pam.Debian.yml](../../roles/bootstrap_ldap_client/tasks/configure_pam.Debian.yml)
- [tasks/configure_pam.RedHat.yml](../../roles/bootstrap_ldap_client/tasks/configure_pam.RedHat.yml)
- [tasks/main.yml](../../roles/bootstrap_ldap_client/tasks/main.yml)
- [handlers/main.yml](../../roles/bootstrap_ldap_client/handlers/main.yml)