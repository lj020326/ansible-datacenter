---
title: "Bootstrap Ldap Client Role"
role: roles/bootstrap_ldap_client
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_ldap_client]
---

# Bootstrap LDAP Client Role

This Ansible role configures an LDAP client on a system, enabling LDAP-based authentication and user management. It sets up necessary LDAP configurations, installs required packages, and configures PAM and SSH to work with LDAP.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_ldap_client__domain` | `"example.int"` | The domain for the LDAP server. |
| `bootstrap_ldap_client__host` | `"ldap.{{ bootstrap_ldap_client__domain }}"` | The hostname of the LDAP server. |
| `bootstrap_ldap_client__port` | `"389"` | The port on which the LDAP server is listening. |
| `bootstrap_ldap_client__endpoint` | `"{{ bootstrap_ldap_client__host }}:{{ bootstrap_ldap_client__port }}"` | The endpoint of the LDAP server. |
| `bootstrap_ldap_client__uri` | `"ldap://{{ bootstrap_ldap_client__endpoint }}/"` | The URI for the LDAP server. |
| `bootstrap_ldap_client__binddn` | `""` | The bind DN for LDAP authentication. |
| `bootstrap_ldap_client__bindpw` | `""` | The password for the bind DN. |
| `bootstrap_ldap_client__sudoers` | `true` | Whether to configure sudoers via LDAP. |
| `bootstrap_ldap_client__base_dn` | `"dc=example,dc=int"` | The base DN for LDAP queries. |
| `bootstrap_ldap_client__nss_user_filter` | `"(objectClass=posixAccount)"` | The filter for NSS user lookups. |
| `bootstrap_ldap_client__base_sudoers` | `"ou=sudoers,{{ bootstrap_ldap_client__base_dn }}"` | The base DN for sudoers. |
| `bootstrap_ldap_client__lookups` | `...` | Defines various LDAP lookups for different entities. |
| `bootstrap_ldap_client__server_host` | `"{{ bootstrap_ldap_client__host }}"` | The server host for LDAP. |
| `bootstrap_ldap_client__sudo` | `true` | Whether to enable sudo configuration. |
| `bootstrap_ldap_client__sudo_base` | `"ou=SUDOers,{{ bootstrap_ldap_client__base_dn }}"` | The base DN for sudo configurations. |
| `bootstrap_ldap_client__nss_passwd` | `true` | Whether to enable NSS passwd lookups. |
| `bootstrap_ldap_client__nss_group` | `true` | Whether to enable NSS group lookups. |
| `bootstrap_ldap_client__nss_shadow` | `true` | Whether to enable NSS shadow lookups. |
| `bootstrap_ldap_client__nss_hosts` | `true` | Whether to enable NSS hosts lookups. |
| `bootstrap_ldap_client__nss_networks` | `true` | Whether to enable NSS networks lookups. |
| `bootstrap_ldap_client__path` | `"/etc/ldap/"` | The path for LDAP configuration files. |
| `bootstrap_ldap_client__nslcd_filter` | `""` | The filter for NSLCD. |

## Usage

To use this role, include it in your playbook and set the necessary variables:

```yaml
- hosts: all
  roles:
    - role: bootstrap_ldap_client
      vars:
        bootstrap_ldap_client__domain: "example.com"
        bootstrap_ldap_client__binddn: "cn=admin,dc=example,dc=com"
        bootstrap_ldap_client__bindpw: "password"
```

## Dependencies

This role does not have any external dependencies, but it assumes that the system has internet access to install necessary packages.

## Platform Support

This role supports the following platforms:
- Debian-based systems (tested on Ubuntu)
- RedHat-based systems (tested on CentOS)

## Best Practices

1. **Security**: Ensure that the LDAP bind credentials are stored securely and not hard-coded in playbooks.
2. **Testing**: Test the configuration in a development environment before applying it to production systems.
3. **Backups**: Always take backups of existing configuration files before applying this role.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_ldap_client/defaults/main.yml)
- [tasks/configure_pam.Debian.yml](../../roles/bootstrap_ldap_client/tasks/configure_pam.Debian.yml)
- [tasks/configure_pam.RedHat.yml](../../roles/bootstrap_ldap_client/tasks/configure_pam.RedHat.yml)
- [tasks/main.yml](../../roles/bootstrap_ldap_client/tasks/main.yml)
- [handlers/main.yml](../../roles/bootstrap_ldap_client/handlers/main.yml)