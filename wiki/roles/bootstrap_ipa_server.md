---
title: "bootstrap_ipa_server Role Documentation"
role: bootstrap_ipa_server
category: Identity and Access Management
type: Ansible Role
tags: identity, ipa, freeipa

## Summary
The `bootstrap_ipa_server` role is designed to set up an IPA (Identity, Policy, Audit) domain server. This role handles the installation of necessary packages, configuration of firewall rules, copying external certificates if required, and testing the installation.

## Variables

| Variable Name                             | Default Value                | Description                                                                 |
|-------------------------------------------|------------------------------|-----------------------------------------------------------------------------|
| `ipaserver_no_host_dns`                   | `false`                      | If set to true, do not configure DNS for the host.                          |
| `ipaserver_setup_adtrust`                 | `false`                      | If set to true, configure AD trust.                                         |
| `ipaserver_setup_kra`                     | `false`                      | If set to true, configure Key Recovery Authority (KRA).                   |
| `ipaserver_setup_dns`                     | `false`                      | If set to true, configure DNS.                                              |
| `ipaserver_no_hbac_allow`                 | `false`                      | If set to true, do not create default HBAC rules that allow all users.      |
| `ipaserver_no_pkinit`                     | `false`                      | If set to true, disable PKINIT configuration.                               |
| `ipaserver_no_ui_redirect`                | `false`                      | If set to true, do not redirect HTTP to HTTPS for the web UI.               |
| `ipaserver_mem_check`                     | `true`                       | Perform memory check during installation.                                     |
| `ipaserver_random_serial_numbers`         | `false`                      | Use random serial numbers in certificates.                                  |
| `ipaclient_mkhomedir`                     | `false`                      | Create home directories for users on the client side.                       |
| `ipaclient_no_ntp`                        | `false`                      | Do not configure NTP.                                                       |
| `ipaserver_external_ca`                   | `false`                      | Use an external CA to sign certificates.                                    |
| `ipaserver_allow_zone_overlap`            | `false`                      | Allow DNS zone overlap.                                                   |
| `ipaserver_no_reverse`                    | `false`                      | Do not create reverse DNS records.                                          |
| `ipaserver_auto_reverse`                  | `false`                      | Automatically create reverse DNS records.                                   |
| `ipaserver_no_forwarders`                 | `false`                      | Do not configure DNS forwarders.                                            |
| `ipaserver_auto_forwarders`               | `false`                      | Automatically configure DNS forwarders.                                     |
| `ipaserver_no_dnssec_validation`          | `false`                      | Disable DNSSEC validation.                                                |
| `ipaserver_enable_compat`                 | `false`                      | Enable compatibility mode for older clients.                                |
| `ipaserver_setup_ca`                      | `true`                       | Configure Certificate Authority (CA).                                       |
| `ipaserver_install_packages`              | `true`                       | Install necessary IPA server packages.                                    |
| `ipaserver_setup_firewalld`               | `true`                       | Configure firewalld rules for IPA server.                                 |
| `ipaserver_copy_csr_to_controller`        | `false`                      | Copy Certificate Signing Requests (CSRs) to the controller.                 |
| `ipaserver_ignore_topology_disconnect`    | `false`                      | Ignore topology disconnect during removal.                                  |
| `ipaserver_ignore_last_of_role`           | `false`                      | Ignore being the last IPA server in a role during removal.                  |
| `ipaserver_remove_from_domain`            | `false`                      | Remove the IPA server from the domain.                                      |

## Usage

To use this role, include it in your playbook and set any necessary variables:

```yaml
- hosts: ipa_servers
  roles:
    - role: bootstrap_ipa_server
      vars:
        ipaserver_setup_dns: true
        ipaserver_setup_adtrust: true
```

Ensure that the required passwords and other sensitive information are provided as variables or through Ansible Vault.

## Dependencies

This role has no external dependencies listed in `meta/main.yml`.

## Tags

- `identity`
- `ipa`
- `freeipa`

## Best Practices

1. **Secure Passwords**: Always use Ansible Vault to manage sensitive information such as passwords.
2. **Firewall Configuration**: Ensure that the firewall rules are correctly configured for your network environment.
3. **External CA**: If using an external CA, ensure that the certificates and keys are securely managed.

## Molecule Tests

This role does not include Molecule tests at this time.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_ipa_server/defaults/main.yml)
- [tasks/copy_external_cert.yml](../../roles/bootstrap_ipa_server/tasks/copy_external_cert.yml)
- [tasks/install.yml](../../roles/bootstrap_ipa_server/tasks/install.yml)
- [tasks/main.yml](../../roles/bootstrap_ipa_server/tasks/main.yml)
- [tasks/python_2_3_test.yml](../../roles/bootstrap_ipa_server/tasks/python_2_3_test.yml)
- [tasks/uninstall.yml](../../roles/bootstrap_ipa_server/tasks/uninstall.yml)
- [meta/main.yml](../../roles/bootstrap_ipa_server/meta/main.yml)