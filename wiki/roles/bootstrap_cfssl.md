---
title: "Bootstrap CFSSL Role Documentation"
role: bootstrap_cfssl
category: Ansible Roles
type: Installation
tags: tls, certificate, ca, security
---

## Summary

The `bootstrap_cfssl` role is designed to install and manage the Cloudflare PKI/TLS toolkit (CFSSL) on target systems. It ensures that CFSSL binaries are installed in a specified directory with appropriate permissions and verifies the integrity of the downloaded files using checksums.

## Variables

| Variable Name            | Default Value                                                                                          | Description                                                                 |
|--------------------------|--------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------|
| `cfssl_version`          | `1.6.5`                                                                                                | The version of CFSSL to install.                                            |
| `cfssl_checksum_url`     | `https://github.com/cloudflare/cfssl/releases/download/v{{ cfssl_version }}/cfssl_{{ cfssl_version }}_checksums.txt` | URL for the checksum file used to verify the integrity of the downloaded binaries. |
| `cfssl_bin_directory`    | `/usr/local/bin`                                                                                       | The directory where CFSSL binaries will be installed.                         |
| `cfssl_owner`            | `root`                                                                                                 | The owner of the CFSSL binaries.                                              |
| `cfssl_group`            | `root`                                                                                                 | The group ownership of the CFSSL binaries.                                      |
| `cfssl_os`               | `linux`                                                                                                | The operating system for which to download the CFSSL binaries (e.g., `darwin`, `windows`). |
| `cfssl_arch`             | `amd64`                                                                                                | The architecture for which to download the CFSSL binaries.                    |

## Usage

To use this role, include it in your playbook and specify any variables you wish to override from their default values.

### Example Playbook

```yaml
- hosts: all
  roles:
    - role: bootstrap_cfssl
      vars:
        cfssl_version: "1.6.5"
```

## Dependencies

This role has no external dependencies other than the availability of `curl` or `wget` on the target system for downloading files.

## Tags

- `tls`
- `certificate`
- `ca`
- `security`

## Best Practices

- Ensure that the specified version of CFSSL is compatible with your environment.
- Verify that the checksum URL points to a trusted source to prevent tampering or corruption of downloaded binaries.
- Adjust permissions and ownership settings as necessary for your security requirements.

## Molecule Tests

This role does not include Molecule tests. However, it is recommended to test roles in isolated environments using tools like Molecule to ensure reliability and consistency across different systems.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_cfssl/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_cfssl/tasks/main.yml)
- [meta/main.yml](../../roles/bootstrap_cfssl/meta/main.yml)
- [handlers/main.yml](../../roles/bootstrap_cfssl/handlers/main.yml)