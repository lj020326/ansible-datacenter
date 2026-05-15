---
title: "Bootstrap CFSSL Role Documentation"
role: bootstrap_cfssl
category: Ansible Roles
type: Installation
tags: [tls, certificate, ca, security]
---

## Summary

The `bootstrap_cfssl` role is designed to install and manage the Cloudflare PKI/TLS toolkit (CFSSL) on a target system. This role ensures that the specified version of CFSSL binaries are downloaded, installed, and properly configured in the designated directory.

## Variables

| Variable Name               | Default Value                                                                                     | Description                                                                                                                                 |
|-----------------------------|---------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------|
| `cfssl_version`             | `1.6.5`                                                                                           | The version of CFSSL to install.                                                                                                            |
| `cfssl_arch`                | `{{ 'arm64' if ansible_facts.machine == 'aarch64' else 'amd64' }}`                                  | Architecture of the system (automatically detected).                                                                                        |
| `cfssl_checksum_url`        | `https://github.com/cloudflare/cfssl/releases/download/v{{ cfssl_version }}/cfssl_{{ cfssl_version }}_checksums.txt` | URL to the checksum file for verifying the integrity of the downloaded binaries.                                                            |
| `cfssl_bin_directory`       | `/usr/local/bin`                                                                                  | Directory where CFSSL binaries will be installed.                                                                                           |
| `cfssl_owner`               | `root`                                                                                            | Owner of the CFSSL binaries.                                                                                                                |
| `cfssl_group`               | `root`                                                                                            | Group ownership of the CFSSL binaries.                                                                                                      |
| `cfssl_os`                  | `linux`                                                                                           | Operating system for which to download the binaries (use "darwin" for MacOS X, "windows" for Windows).                                    |

## Usage

To use the `bootstrap_cfssl` role in your Ansible playbook, include it as follows:

```yaml
- hosts: all
  roles:
    - bootstrap_cfssl
```

You can override default variables by specifying them in your playbook or inventory file. For example:

```yaml
- hosts: all
  vars:
    cfssl_version: 1.6.5
    cfssl_bin_directory: /opt/cfssl/bin
  roles:
    - bootstrap_cfssl
```

## Dependencies

This role has no external dependencies other than Ansible itself and the ability to access the internet to download CFSSL binaries.

## Best Practices

- Ensure that the target system has network connectivity to GitHub, where the CFSSL binaries are hosted.
- Verify the integrity of the downloaded binaries using checksums provided by the `cfssl_checksum_url`.
- Adjust the `cfssl_bin_directory`, `cfssl_owner`, and `cfssl_group` variables as needed based on your environment's security policies.

## Molecule Tests

This role does not include Molecule tests. However, it is recommended to test roles in isolated environments using tools like Molecule to ensure reliability and consistency across different systems.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_cfssl/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_cfssl/tasks/main.yml)
- [meta/main.yml](../../roles/bootstrap_cfssl/meta/main.yml)