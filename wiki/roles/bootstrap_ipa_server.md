---
title: "Bootstrap Ipa Server Role"
role: roles/bootstrap_ipa_server
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_ipa_server]
---

# Bootstrap IPA Server Role

The `bootstrap_ipa_server` role is designed to set up an IPA (Identity, Policy, Audit) domain server. This role handles the installation, configuration, and optional integration with Active Directory, DNS, and other services. It provides a comprehensive solution for deploying a FreeIPA server in various environments.

## Table of Contents

- [Variables](#variables)
- [Usage](#usage)
- [Dependencies](#dependencies)
- [Best Practices](#best-practices)
- [Backlinks](#backlinks)

## Variables

The following table lists the default variables for this role:

| Variable Name                       | Default Value | Description                                                                 |
|-------------------------------------|---------------|-----------------------------------------------------------------------------|
| `ipaserver_no_host_dns`             | `false`       | Do not use the host as a DNS server.                                       |
| `ipaserver_setup_adtrust`           | `false`       | Set up Active Directory trust.                                              |
| `ipaserver_setup_kra`               | `false`       | Set up the KRA (Key Recovery Agent).                                        |
| `ipaserver_setup_dns`               | `false`       | Set up DNS integration.                                                     |
| `ipaserver_no_hbac_allow`           | `false`       | Do not allow HBAC (Host-Based Access Control).                              |
| `ipaserver_no_pkinit`               | `false`       | Do not use PKINIT for authentication.                                       |
| `ipaserver_no_ui_redirect`          | `false`       | Do not redirect to the web UI.                                              |
| `ipaserver_mem_check`               | `true`        | Perform memory checks.                                                      |
| `ipaserver_random_serial_numbers`   | `false`       | Use random serial numbers.                                                  |
| `ipaclient_mkhomedir`               | `false`       | Create home directories for users.                                          |
| `ipaclient_no_ntp`                  | `false`       | Do not configure NTP.                                                      |
| `ipaserver_external_ca`             | `false`       | Use an external CA.                                                        |
| `ipaserver_allow_zone_overlap`      | `false`       | Allow DNS zone overlap.                                                     |
| `ipaserver_no_reverse`              | `false`       | Do not configure reverse DNS zones.                                         |
| `ipaserver_auto_reverse`            | `false`       | Automatically configure reverse DNS zones.                                  |
| `ipaserver_no_forwarders`           | `false`       | Do not configure DNS forwarders.                                            |
| `ipaserver_auto_forwarders`         | `false`       | Automatically configure DNS forwarders.                                     |
| `ipaserver_no_dnssec_validation`    | `false`       | Do not validate DNSSEC.                                                     |
| `ipaserver_enable_compat`           | `false`       | Enable compatibility plugins.                                               |
| `ipaserver_setup_ca`                | `true`        | Set up the CA (Certificate Authority).                                      |
| `ipaserver_install_packages`        | `true`        | Install IPA server packages.                                                |
| `ipaserver_setup_firewalld`         | `true`        | Set up firewalld.                                                           |
| `ipaserver_copy_csr_to_controller`  | `false`       | Copy CSR to the Ansible controller.                                         |
| `ipaserver_ignore_topology_disconnect` | `false` | Ignore topology disconnect errors.                                          |
| `ipaserver_ignore_last_of_role`     | `false`       | Ignore last of role errors.                                                 |
| `ipaserver_remove_from_domain`      | `false`       | Remove the server from the domain.                                          |

## Usage

To use this role, include it in your playbook and set the necessary variables:

```yaml
---
- hosts: ipa_servers
  roles:
    - role: bootstrap_ipa_server
      vars:
        ipaserver_setup_dns: true
        ipaserver_setup_adtrust: true
        ipaserver_install_packages: true
```

## Dependencies

This role does not have any dependencies. However, ensure that the required Ansible collections and modules are installed in your environment.

## Best Practices

- Ensure that the target systems meet the minimum requirements for FreeIPA server installation.
- Test the role in a development environment before deploying it to production.
- Regularly update the role to benefit from the latest features and security fixes.
- Review and understand the variables and their default values before deployment.
- Monitor the FreeIPA server logs for any issues during or after installation.

## Backlinks

- [roles/bootstrap_ipa_server/defaults/main.yml](../../roles/bootstrap_ipa_server/defaults/main.yml)
- [roles/bootstrap_ipa_server/tasks/copy_external_cert.yml](../../roles/bootstrap_ipa_server/tasks/copy_external_cert.yml)
- [roles/bootstrap_ipa_server/tasks/install.yml](../../roles/bootstrap_ipa_server/tasks/install.yml)
- [roles/bootstrap_ipa_server/tasks/main.yml](../../roles/bootstrap_ipa_server/tasks/main.yml)
- [roles/bootstrap_ipa_server/tasks/python_2_3_test.yml](../../roles/bootstrap_ipa_server/tasks/python_2_3_test.yml)
- [roles/bootstrap_ipa_server/tasks/uninstall.yml](../../roles/bootstrap_ipa_server/tasks/uninstall.yml)
- [roles/bootstrap_ipa_server/meta/main.yml](../../roles/bootstrap_ipa_server/meta/main.yml)