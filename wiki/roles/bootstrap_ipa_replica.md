---
title: "Bootstrap IPA Replica Role"
role: bootstrap_ipa_replica
category: Identity Management
type: Ansible Role
tags: identity, ipa, freeipa

---

## Summary

The `bootstrap_ipa_replica` role is designed to set up an IPA (Identity, Policy, Audit) domain replica. This role handles the installation of necessary packages, firewall configuration, and replica setup based on provided variables.

## Variables

| Variable Name                         | Default Value           | Description                                                                 |
|---------------------------------------|-------------------------|-----------------------------------------------------------------------------|
| `ipareplica_no_host_dns`              | `false`                 | Do not use DNS for hostname resolution.                                     |
| `ipareplica_skip_conncheck`           | `false`                 | Skip connection check to IPA server.                                        |
| `ipareplica_hidden_replica`           | `false`                 | Install a hidden replica.                                                   |
| `ipareplica_mem_check`                | `true`                  | Perform memory check before installation.                                   |
| `ipareplica_setup_adtrust`            | `false`                 | Setup AD trust during installation.                                         |
| `ipareplica_setup_ca`                 | `false`                 | Setup CA during installation.                                               |
| `ipareplica_setup_kra`                | `false`                 | Setup KRA (Key Recovery Agent) during installation.                         |
| `ipareplica_setup_dns`                | `false`                 | Setup DNS during installation.                                              |
| `ipareplica_no_pkinit`                | `false`                 | Disable PKINIT authentication.                                              |
| `ipareplica_no_ui_redirect`           | `false`                 | Do not redirect to the web UI after installation.                           |
| `ipaclient_mkhomedir`                 | `false`                 | Create home directories for users on the replica.                           |
| `ipaclient_force_join`                | `false`                 | Force client join even if already joined.                                   |
| `ipaclient_no_ntp`                    | `false`                 | Do not configure NTP during installation.                                     |
| `ipaclient_ssh_trust_dns`             | `false`                 | Trust DNS for SSH host key verification.                                    |
| `ipareplica_skip_schema_check`        | `false`                 | Skip schema check before installation.                                      |
| `ipareplica_allow_zone_overlap`       | `false`                 | Allow zone overlap during DNS setup.                                        |
| `ipareplica_no_reverse`               | `false`                 | Do not create reverse DNS records.                                          |
| `ipareplica_auto_reverse`             | `false`                 | Automatically create reverse DNS records.                                   |
| `ipareplica_no_forwarders`            | `false`                 | Do not configure DNS forwarders.                                            |
| `ipareplica_auto_forwarders`          | `false`                 | Automatically configure DNS forwarders.                                     |
| `ipareplica_no_dnssec_validation`     | `false`                 | Disable DNSSEC validation.                                                  |
| `ipareplica_enable_compat`            | `false`                 | Enable compatibility mode for older clients.                                |
| `ipareplica_ignore_topology_disconnect` | `false`               | Ignore topology disconnect during installation.                             |
| `ipareplica_ignore_last_of_role`      | `false`                 | Ignore being the last of a role during uninstallation.                      |
| `ipareplica_install_packages`         | `true`                  | Install necessary packages for IPA replica setup.                           |
| `ipareplica_setup_firewalld`          | `true`                  | Setup firewalld rules for IPA replica.                                      |

## Usage

To use the `bootstrap_ipa_replica` role, include it in your playbook and provide any necessary variables as needed:

```yaml
- name: Setup IPA Replica
  hosts: ipareplicas
  roles:
    - role: bootstrap_ipa_replica
      vars:
        ipareplica_setup_dns: true
        ipareplica_setup_adtrust: true
```

## Dependencies

This role has no external dependencies.

## Tags

- `identity`
- `ipa`
- `freeipa`

## Best Practices

- Ensure that the IPA server is reachable from the replica.
- Verify network connectivity and DNS resolution before running the playbook.
- Use appropriate firewall rules to allow necessary traffic between the IPA server and replicas.

## Molecule Tests

This role does not include Molecule tests. Please ensure thorough testing in a staging environment before deploying in production.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_ipa_replica/defaults/main.yml)
- [tasks/install.yml](../../roles/bootstrap_ipa_replica/tasks/install.yml)
- [tasks/main.yml](../../roles/bootstrap_ipa_replica/tasks/main.yml)
- [tasks/uninstall.yml](../../roles/bootstrap_ipa_replica/tasks/uninstall.yml)
- [meta/main.yml](../../roles/bootstrap_ipa_replica/meta/main.yml)

---

This documentation provides a comprehensive overview of the `bootstrap_ipa_replica` role, including its purpose, configuration options, usage guidelines, and best practices.