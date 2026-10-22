---
title: "Bootstrap PDC Role"
role: bootstrap_pdc
category: Windows
type: Role
tags: [ansible, role, bootstrap_pdc]
---

# Bootstrap PDC Role

The `bootstrap_pdc` role is designed to set up a Primary Domain Controller (PDC) on a Windows server. It configures the necessary Active Directory and DNS settings, installs required PowerShell modules and Windows features, and ensures the domain controller is properly set up and operational.

## Variables

| Variable Name                          | Default Value                          | Description                                                                 |
|----------------------------------------|----------------------------------------|-----------------------------------------------------------------------------|
| `pdc_administrator_username`           | `Administrator`                        | The username for the domain administrator.                                   |
| `pdc_administrator_password`           | `P@ssw0rd!`                            | The password for the domain administrator.                                   |
| `pdc_dns_nics`                         | `'*'`                                   | The network interfaces to configure DNS on.                                  |
| `pdc_dns_servers`                      | `{{ ansible_host }}`                   | The DNS servers to use.                                                      |
| `pdc_domain`                           | `ad.example.test`                      | The domain name to create.                                                   |
| `pdc_netbios`                          | `TEST`                                  | The NetBIOS name for the domain.                                             |
| `pdc_domain_safe_mode_password`        | `P@ssw0rd!`                            | The safe mode password for the domain.                                       |
| `pdc_domain_functional_level`          | `Default`                              | The functional level for the domain.                                         |
| `pdc_forest_functional_level`          | `Default`                              | The functional level for the forest.                                         |
| `pdc_required_psmodules`               | `[xPSDesiredStateConfiguration, NetworkingDsc, ComputerManagementDsc, ActiveDirectoryDsc]` | The required PowerShell modules to install.                                   |
| `pdc_required_features`                | `[AD-domain-services, DNS]`            | The required Windows features to install.                                    |
| `pdc_desired_dns_forwarders`           | `[8.8.8.8, 8.8.4.4]`                   | The desired DNS forwarders to configure.                                      |

## Usage

To use this role, include it in your playbook and set the necessary variables:

```yaml
---
- hosts: windows
  roles:
    - role: bootstrap_pdc
      vars:
        pdc_administrator_username: "Admin"
        pdc_administrator_password: "SecureP@ssw0rd!"
        pdc_domain: "example.com"
        pdc_netbios: "EXAMPLE"
        pdc_domain_safe_mode_password: "SecureP@ssw0rd!"
```

## Dependencies

This role requires the following Ansible collections:

- `community.windows`
- `microsoft.ad`

Ensure these collections are installed in your Ansible environment:

```bash
ansible-galaxy collection install community.windows
ansible-galaxy collection install microsoft.ad
```

## Best Practices

- Ensure that the target machine has internet access to download the required PowerShell modules.
- Verify that the target machine meets the hardware and software requirements for running Active Directory Domain Services.
- Test the role in a development environment before deploying it to production.
- Regularly update the role to incorporate the latest security patches and updates.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_pdc/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_pdc/tasks/main.yml)
- [handlers/main.yml](../../roles/bootstrap_pdc/handlers/main.yml)