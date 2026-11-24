---
title: "Bootstrap IPA SSSD Role"
role: bootstrap_ipa_sssd
category: Identity Management
type: ansible-role
tags: [ansible, role, bootstrap_ipa_sssd]
---

# Bootstrap IPA SSSD Role

The `bootstrap_ipa_sssd` role is designed to configure SSSD (System Security Services Daemon) for integration with IPA (Identity, Policy, Audit) servers. This role ensures that the necessary SSSD packages are installed and that the SSSD configuration file (`sssd.conf`) is properly templated and secured.

## Variables

| Variable Name                | Default Value                            | Description                                                                 |
|------------------------------|------------------------------------------|-----------------------------------------------------------------------------|
| `sssd_conf`                  | `/etc/sssd/sssd.conf`                    | Path to the SSSD configuration file.                                        |
| `sssd_packages`              | `sssd, libselinux-python`                | List of SSSD packages to be installed.                                      |
| `sssd_on_master`             | `false`                                  | Boolean indicating if SSSD should be configured on the master node.         |
| `sssd_domains`               |                                          | List of domains to be configured in SSSD.                                   |
| `sssd_id_provider`           |                                          | ID provider for SSSD.                                                       |
| `sssd_auth_provider`         |                                          | Authentication provider for SSSD.                                           |
| `sssd_access_provider`       |                                          | Access provider for SSSD.                                                   |
| `sssd_chpass_provider`       |                                          | Change password provider for SSSD.                                          |
| `sssd_cache_credentials`     | `false`                                  | Boolean indicating if credentials should be cached.                          |
| `sssd_krb5_offline_passwords`| `false`                                  | Boolean indicating if offline Kerberos passwords are allowed.               |
| `sssd_ipa_servers`           |                                          | List of IPA servers to be used by SSSD.                                     |
| `sssd_services`              |                                          | List of services to be configured in SSSD.                                  |

## Usage

To use this role, include it in your playbook and set the necessary variables. Below is an example playbook:

```yaml
---
- hosts: all
  roles:
    - role: bootstrap_ipa_sssd
      vars:
        sssd_domains:
          - example.com
        sssd_id_provider: ipa
        sssd_auth_provider: ipa
        sssd_access_provider: ipa
        sssd_chpass_provider: ipa
        sssd_cache_credentials: true
        sssd_krb5_offline_passwords: true
        sssd_ipa_servers:
          - ipa.example.com
        sssd_services:
          - sshd
          - sudo
```

## Dependencies

This role does not have any dependencies.

## Best Practices

- Ensure that the IPA servers are properly configured and reachable from the nodes where this role is applied.
- Regularly update the SSSD packages to benefit from the latest security patches and features.
- Test the SSSD configuration in a development environment before applying it to production systems.
- Validate the SSSD configuration file syntax using `sssctl config-check` before restarting the SSSD service.
- Monitor SSSD logs for any errors or warnings after applying the configuration.

## Verification

To verify that the role has been applied correctly, you can:
- Check the existence of the SSSD configuration file at the specified path.
- Validate the SSSD configuration syntax using `sssctl config-check`.
- Restart the SSSD service and check its status using `systemctl status sssd`.
- Verify that the configured domains and services are properly recognized by SSSD.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_ipa_sssd/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_ipa_sssd/tasks/main.yml)
- [meta/main.yml](../../roles/bootstrap_ipa_sssd/meta/main.yml)
- [templates/sssd.conf.j2](../../roles/bootstrap_ipa_sssd/templates/sssd.conf.j2)