---
title: Bootstrap PDC Role Documentation
role: bootstrap_pdc
category: Ansible Roles
type: Infrastructure Provisioning
tags: [ansible, role, pdc, domain-controller, active-directory]
---

## Summary

The `bootstrap_pdc` Ansible role is designed to automate the setup of a Primary Domain Controller (PDC) in an Active Directory environment. This role ensures that all necessary prerequisites are met, including setting up local users, installing required PowerShell modules and Windows features, configuring DNS settings, and establishing the domain and forest structure.

## Variables

The following variables can be configured in `defaults/main.yml` to customize the behavior of this role:

| Variable Name                         | Default Value                          | Description                                                                 |
|---------------------------------------|----------------------------------------|-----------------------------------------------------------------------------|
| `pdc_administrator_username`          | `Administrator`                        | The username for the local administrator account.                           |
| `pdc_administrator_password`          | `P@ssw0rd!`                            | The password for the local administrator account.                           |
| `pdc_dns_nics`                      | `"*"`                                  | Specifies which network interfaces to configure DNS settings on.            |
| `pdc_dns_servers`                     | `{{ ansible_host }}`                   | List of DNS servers to use. By default, it uses the host's IP address.    |
| `pdc_domain`                          | `ad.example.test`                      | The fully qualified domain name (FQDN) for the new Active Directory domain.|
| `pdc_netbios`                         | `TEST`                                 | The NetBIOS name of the domain.                                             |
| `pdc_domain_safe_mode_password`       | `P@ssw0rd!`                            | Password used for directory services restore mode.                          |
| `pdc_domain_functional_level`         | `Default`                              | Functional level of the domain (e.g., Windows2016Domain).                   |
| `pdc_forest_functional_level`         | `Default`                              | Functional level of the forest (e.g., Windows2016Forest).                   |
| `pdc_required_psmodules`              | `[xPSDesiredStateConfiguration, NetworkingDsc, ComputerManagementDsc, ActiveDirectoryDsc]` | List of PowerShell modules required for DSC configurations.                 |
| `pdc_required_features`               | `[AD-domain-services, DNS]`            | List of Windows features to install on the PDC.                             |
| `pdc_desired_dns_forwarders`          | `[8.8.8.8, 8.8.4.4]`                   | List of desired DNS forwarder IP addresses.                                 |

## Usage

To use this role in your Ansible playbook, include it as follows:

```yaml
- hosts: pdc_servers
  roles:
    - role: bootstrap_pdc
      vars:
        pdc_domain: ad.example.test
        pdc_netbios: TEST
```

Ensure that the target host is a Windows server and has the necessary permissions to install domain services and configure DNS.

## Dependencies

This role depends on the following Ansible collections:

- `ansible.windows`
- `community.windows`
- `microsoft.ad`

These collections should be installed before running this role. You can install them using the following command:

```bash
ansible-galaxy collection install ansible.windows community.windows microsoft.ad
```

## Best Practices

1. **Secure Passwords**: Ensure that passwords are stored securely and not hard-coded in playbooks. Consider using Ansible Vault or environment variables.
2. **Network Configuration**: Verify network settings to ensure proper DNS resolution and communication between domain controllers.
3. **Backup**: Regularly back up Active Directory data to prevent data loss.

## Molecule Tests

This role includes Molecule tests to verify its functionality. To run the tests, execute:

```bash
molecule test
```

Ensure that you have Docker installed on your system as it is required for running the Molecule tests.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_pdc/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_pdc/tasks/main.yml)
- [handlers/main.yml](../../roles/bootstrap_pdc/handlers/main.yml)