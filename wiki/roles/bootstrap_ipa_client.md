---
title: "Bootstrap IPA Client Role"
role: bootstrap_ipa_client
category: Identity Management
type: Ansible Role
tags: identity, ipa, freeipa
---

## Summary

The `bootstrap_ipa_client` role is designed to join a machine to an IPA (Identity, Policy, Audit) domain. It handles the installation and configuration of the IPA client packages, sets up DNS resolver configurations if required, and ensures that the system can authenticate against the IPA server.

## Variables
Below are the configurable variables for this role:

| Variable Name                         | Default Value         | Description                                                                 |
|---------------------------------------|-----------------------|-----------------------------------------------------------------------------|
| `ipaclient_force_join`                | `false`               | Forcefully join the client to the IPA domain.                             |
| `ipaclient_mkhomedir`                 | `false`               | Create home directories for users on first login.                           |
| `ipaclient_kinit_attempts`            | `5`                   | Number of attempts to authenticate with Kerberos.                         |
| `ipaclient_use_otp`                   | `false`               | Use one-time password (OTP) for authentication.                             |
| `ipaclient_allow_repair`              | `false`               | Allow repair during client installation.                                    |
| `ipaclient_on_controller`             | `false`               | Indicate if the client is running on a controller node.                     |
| `ipaclient_no_ntp`                    | `false`               | Do not configure NTP with IPA server.                                       |
| `ipaclient_no_dns_lookup`             | `false`               | Do not perform DNS lookups for IPA servers.                                 |
| `ipaclient_ssh_trust_dns`             | `false`               | Trust DNS for SSH host key verification.                                    |
| `ipaclient_no_ssh`                    | `false`               | Do not configure SSH client to use IPA server.                              |
| `ipaclient_no_sshd`                   | `false`               | Do not configure SSH daemon to use IPA server.                              |
| `ipaclient_no_sudo`                   | `false`               | Do not configure sudo to use IPA server.                                    |
| `ipaclient_subid`                     | `false`               | Configure sub-id ranges for user namespaces.                                |
| `ipaclient_no_dns_sshfp`              | `false`               | Do not add SSHFP records to DNS.                                            |
| `ipaclient_force`                     | `false`               | Force client installation even if some checks fail.                         |
| `ipaclient_force_ntpd`                | `false`               | Force configuration of NTP with IPA server.                                 |
| `ipaclient_no_nisdomain`              | `false`               | Do not set the NIS domain name to the IPA realm.                            |
| `ipaclient_configure_firefox`         | `false`               | Configure Firefox to use IPA for authentication.                            |
| `ipaclient_all_ip_addresses`          | `false`               | Register all IP addresses of the client with IPA server.                    |
| `ipasssd_fixed_primary`               | `false`               | Use a fixed primary domain in SSSD configuration.                           |
| `ipasssd_permit`                      | `false`               | Permit users to authenticate using SSSD.                                    |
| `ipasssd_enable_dns_updates`          | `false`               | Enable DNS updates via SSSD.                                                |
| `ipasssd_no_krb5_offline_passwords`   | `false`               | Disable offline Kerberos password authentication in SSSD.                   |
| `ipasssd_preserve_sssd`               | `false`               | Preserve existing SSSD configuration during installation.                     |
| `ipaclient_request_cert`              | `false`               | Request a certificate for the client from IPA server.                       |
| `ipaclient_install_packages`          | `true`                | Install IPA client packages.                                                |
| `ipaclient_configure_dns_resolver`    | `false`               | Configure DNS resolver to use IPA servers.                                |
| `ipaclient_cleanup_dns_resolver`      | `false`               | Unconfigure DNS resolver during uninstallation.                             |

## Usage
To use the `bootstrap_ipa_client` role, include it in your playbook and set the necessary variables as required:

```yaml
- hosts: all
  roles:
    - role: bootstrap_ipa_client
      vars:
        ipaserver_domain: example.com
        ipaserver_realm: EXAMPLE.COM
        ipaadmin_password: secret
```

## Dependencies
This role has no external dependencies.

## Tags
The following tags are available for this role:

- `ipaclient_install`: For tasks related to installing the IPA client.
- `ipaclient_uninstall`: For tasks related to uninstalling the IPA client.
- `ipaclient_dns`: For tasks related to DNS resolver configuration.

## Best Practices
- Ensure that the IPA server details (`ipaserver_domain`, `ipaserver_realm`) are correctly specified.
- Use secure methods for passing sensitive information like `ipaadmin_password`.
- Test the role in a non-production environment before deploying it widely.

## Molecule Tests
This role does not include Molecule tests at this time. Future versions may include test scenarios to validate functionality.

## Backlinks
- [defaults/main.yml](../../roles/bootstrap_ipa_client/defaults/main.yml)
- [tasks/install.yml](../../roles/bootstrap_ipa_client/tasks/install.yml)
- [tasks/main.yml](../../roles/bootstrap_ipa_client/tasks/main.yml)
- [tasks/python_2_3_test.yml](../../roles/bootstrap_ipa_client/tasks/python_2_3_test.yml)
- [tasks/uninstall.yml](../../roles/bootstrap_ipa_client/tasks/uninstall.yml)
- [meta/main.yml](../../roles/bootstrap_ipa_client/meta/main.yml)