---
title: "Bootstrap EPEL Repository Role"
role: bootstrap_epel_repo
category: Ansible Roles
type: Configuration
tags: epel, repository, yum, rpm
---

## Summary

The `bootstrap_epel_repo` role is designed to configure and enable the Extra Packages for Enterprise Linux (EPEL) repository on Red Hat-based systems. This role ensures that the EPEL GPG key is imported, the repository file is created, and the system's package cache is updated.

## Variables

| Variable Name                         | Default Value                                                                                       | Description                                                                 |
|---------------------------------------|---------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------|
| `bootstrap_epel_repo__url`            | `"https://dl.fedoraproject.org/pub/epel/epel-release-latest-\{\{ ansible_facts['distribution_major_version'] \}\}.noarch.rpm"` | URL for the EPEL repository release package.                                  |
| `bootstrap_epel_repo__gpg_key_url`    | `"https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-\{\{ ansible_facts['distribution_major_version'] \}\}"`             | URL for the EPEL GPG key.                                                     |
| `bootstrap_epel_repo__gpg_key_path`   | `"/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-\{\{ ansible_facts['distribution_major_version'] \}\}"`                                | Local path where the EPEL GPG key will be stored.                             |
| `bootstrap_epel_repo__repofile_path`  | `"/etc/yum.repos.d/epel.repo"`                                                                      | Path to the EPEL repository configuration file.                               |
| `bootstrap_epel_repo__disable`        | `false`                                                                                           | Boolean flag to disable the role's execution.                                 |

## Usage

To use this role, include it in your playbook and optionally override any of the default variables as needed:

```yaml
- hosts: all
  roles:
    - role: bootstrap_epel_repo
      vars:
        bootstrap_epel_repo__disable: false
```

## Dependencies

This role does not have any external dependencies.

## Tags

No specific tags are defined for this role. The default Ansible tags can be used to target the tasks within this role.

## Best Practices

- Ensure that the `bootstrap_epel_repo__url` and `bootstrap_epel_repo__gpg_key_url` variables point to valid and secure locations.
- Review the EPEL repository policies and terms of use before enabling it on your systems.
- Monitor system updates after enabling the EPEL repository to ensure compatibility with existing packages.

## Molecule Tests

This role does not include Molecule tests at this time. Consider adding Molecule scenarios for testing in future versions.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_epel_repo/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_epel_repo/tasks/main.yml)