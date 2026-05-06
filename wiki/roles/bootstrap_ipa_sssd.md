---
title: Bootstrap IPA SSSD Role Documentation
role: bootstrap_ipa_sssd
category: Identity and Access Management
type: Ansible Role
tags: [identity, ipa]
---

## Summary

The `bootstrap_ipa_sssd` role is designed to configure the System Security Services Daemon (SSSD) for integration with an Identity, Policy, and Audit (IPA) server. This role installs necessary packages and configures SSSD using a template configuration file.

## Variables

| Variable Name                | Default Value                      | Description                                                                 |
|------------------------------|------------------------------------|-----------------------------------------------------------------------------|
| `sssd_conf`                  | `/etc/sssd/sssd.conf`              | Path to the SSSD configuration file.                                        |
| `sssd_packages`              | `sssd, libselinux-python`          | List of packages to be installed for SSSD functionality.                    |
| `sssd_on_master`             | `"false"`                          | Indicates if the role is being run on an IPA master server.                 |
| `sssd_domains`               |                                    | Domains to be configured in SSSD.                                           |
| `sssd_id_provider`           |                                    | Identity provider for SSSD (e.g., `ipa`).                                   |
| `sssd_auth_provider`         |                                    | Authentication provider for SSSD (e.g., `ipa`).                             |
| `sssd_access_provider`       |                                    | Access control provider for SSSD (e.g., `permit_all`, `simple`).            |
| `sssd_chpass_provider`       |                                    | Password change provider for SSSD (e.g., `ipa`).                            |
| `sssd_cache_credentials`     | `False`                            | Whether to cache credentials locally.                                       |
| `sssd_krb5_offline_passwords`| `False`                            | Whether to allow offline password changes using Kerberos tickets.           |
| `sssd_ipa_servers`           |                                    | List of IPA servers for SSSD configuration.                                 |
| `sssd_services`              |                                    | Services to be enabled and configured in SSSD (e.g., `nss`, `pam`).         |

## Usage

To use the `bootstrap_ipa_sssd` role, include it in your playbook and provide necessary variables as per your environment. Below is an example of how to include this role in a playbook:

```yaml
- name: Configure SSSD for IPA
  hosts: all
  roles:
    - role: bootstrap_ipa_sssd
      vars:
        sssd_domains: "example.com"
        sssd_id_provider: "ipa"
        sssd_auth_provider: "ipa"
        sssd_access_provider: "permit_all"
        sssd_chpass_provider: "ipa"
        sssd_ipa_servers: ["ipa1.example.com", "ipa2.example.com"]
        sssd_services: ["nss", "pam"]
```

## Dependencies

This role has no external dependencies.

## Tags

- `identity`
- `ipa`

## Best Practices

- Ensure that the IPA servers specified in `sssd_ipa_servers` are reachable from the target hosts.
- Configure appropriate access providers based on your organization's security policies.
- Review and test the SSSD configuration thoroughly before deploying it to production environments.

## Molecule Tests

This role does not include any Molecule tests at this time. Consider adding Molecule scenarios for automated testing of the role in future updates.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_ipa_sssd/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_ipa_sssd/tasks/main.yml)
- [meta/main.yml](../../roles/bootstrap_ipa_sssd/meta/main.yml)

---

This documentation provides a comprehensive overview of the `bootstrap_ipa_sssd` role, including its purpose, configuration variables, usage instructions, and best practices.