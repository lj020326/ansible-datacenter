---
title: "Bootstrap IPA Replica Role"
role: bootstrap_ipa_replica
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_ipa_replica]
---

# Bootstrap IPA Replica Role

The `bootstrap_ipa_replica` role is designed to set up an IPA (Identity, Policy, Audit) domain replica on a server. This role handles the installation, configuration, and management of IPA replica services, including DNS, AD trust, and firewall settings.

## Prerequisites

- Ensure that the target server meets the minimum requirements for memory and CPU.
- Verify that the IPA server is properly configured and reachable from the replica server.
- Ensure that necessary packages are available in the system's repositories.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `ipareplica_no_host_dns` | `false` | Whether to skip DNS hostname check |
| `ipareplica_skip_conncheck` | `false` | Skip connectivity check |
| `ipareplica_hidden_replica` | `false` | Configure as a hidden replica |
| `ipareplica_mem_check` | `true` | Perform memory check |
| `ipareplica_setup_adtrust` | `false` | Set up Active Directory trust |
| `ipareplica_setup_ca` | `false` | Set up Certificate Authority |
| `ipareplica_setup_kra` | `false` | Set up Key Recovery Authority |
| `ipareplica_setup_dns` | `false` | Set up DNS |
| `ipareplica_no_pkinit` | `false` | Skip PKINIT setup |
| `ipareplica_no_ui_redirect` | `false` | Skip UI redirection |
| `ipaclient_mkhomedir` | `false` | Create home directories |
| `ipaclient_force_join` | `false` | Force join to domain |
| `ipaclient_no_ntp` | `false` | Skip NTP configuration |
| `ipaclient_ssh_trust_dns` | `false` | Trust DNS for SSH |
| `ipareplica_skip_schema_check` | `false` | Skip schema check |
| `ipareplica_allow_zone_overlap` | `false` | Allow zone overlap |
| `ipareplica_no_reverse` | `false` | Skip reverse DNS setup |
| `ipareplica_auto_reverse` | `false` | Automatically configure reverse DNS |
| `ipareplica_no_forwarders` | `false` | Skip forwarders setup |
| `ipareplica_auto_forwarders` | `false` | Automatically configure forwarders |
| `ipareplica_no_dnssec_validation` | `false` | Skip DNSSEC validation |
| `ipareplica_enable_compat` | `false` | Enable compatibility mode |
| `ipareplica_ignore_topology_disconnect` | `false` | Ignore topology disconnect |
| `ipareplica_ignore_last_of_role` | `false` | Ignore last of role check |
| `ipareplica_install_packages` | `true` | Install IPA replica packages |
| `ipareplica_setup_firewalld` | `true` | Set up firewalld |

## Usage

To use this role, include it in your playbook and set the necessary variables. At a minimum, you need to specify the IPA server details:

```yaml
- hosts: ipareplicas
  roles:
    - role: bootstrap_ipa_replica
      vars:
        ipa_server: "ipa.example.com"
        ipa_domain: "example.com"
        ipa_admin_password: "your_password"
        ipareplica_setup_dns: true
        ipareplica_setup_adtrust: true
```

## Dependencies

This role does not have any dependencies.

## Best Practices

- Test the role in a development environment before deploying it to production.
- Regularly update the role to benefit from the latest features and security fixes.
- Monitor the replica server's resources to ensure it meets the IPA service requirements.
- Keep the IPA server and replica servers synchronized in terms of time using NTP.
- Regularly back up the IPA server and replica servers.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_ipa_replica/defaults/main.yml)
- [tasks/install.yml](../../roles/bootstrap_ipa_replica/tasks/install.yml)
- [tasks/main.yml](../../roles/bootstrap_ipa_replica/tasks/main.yml)
- [tasks/uninstall.yml](../../roles/bootstrap_ipa_replica/tasks/uninstall.yml)
- [meta/main.yml](../../roles/bootstrap_ipa_replica/meta/main.yml)