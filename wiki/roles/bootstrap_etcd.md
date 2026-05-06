---
title: "bootstrap_etcd Role Documentation"
role: bootstrap_etcd
category: Ansible Roles
type: Installation
tags: etcd, ha, kv

---

## Summary

The `bootstrap_etcd` role is designed to install and configure an etcd cluster. It handles the creation of necessary directories, user accounts, group memberships, and systemd service files for running etcd. The role also manages the download and installation of the specified version of etcd from its official GitHub repository.

## Variables

The following variables are available in this role:

| Variable Name                          | Default Value                                                                                                     | Description                                                                                                                                                                                                 |
|----------------------------------------|-------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_etcd__ca_conf_directory`    | `"{{ '~/etcd-certificates' \| expanduser }}"`                                                                     | The directory containing the etcd certificates.                                                                                                                                                              |
| `bootstrap_etcd__ansible_group`        | `"kubernetes_etcd"`                                                                                               | The Ansible group that includes all etcd nodes.                                                                                                                                                            |
| `bootstrap_etcd__version`              | `"3.6.4"`                                                                                                         | The version of etcd to install.                                                                                                                                                                              |
| `bootstrap_etcd__client_port`          | `"2379"`                                                                                                          | The port on which the etcd client API listens.                                                                                                                                                               |
| `bootstrap_etcd__peer_port`            | `"2380"`                                                                                                          | The port on which etcd peer communication occurs.                                                                                                                                                            |
| `bootstrap_etcd__interface`            | `"tap0"`                                                                                                          | The network interface for etcd to bind to.                                                                                                                                                                   |
| `bootstrap_etcd__user`                 | `"etcd"`                                                                                                          | The user under which etcd will run.                                                                                                                                                                          |
| `bootstrap_etcd__user_shell`           | `"/bin/false"`                                                                                                    | The shell assigned to the etcd user.                                                                                                                                                                         |
| `bootstrap_etcd__user_system`          | `true`                                                                                                            | Whether the etcd user is a system account.                                                                                                                                                                   |
| `bootstrap_etcd__group`                | `"etcd"`                                                                                                          | The group under which etcd will run.                                                                                                                                                                         |
| `bootstrap_etcd__group_system`         | `true`                                                                                                            | Whether the etcd group is a system group.                                                                                                                                                                    |
| `bootstrap_etcd__conf_dir`             | `"/etc/etcd"`                                                                                                     | The directory where etcd configuration files are stored.                                                                                                                                                     |
| `bootstrap_etcd__conf_dir_mode`        | `"0750"`                                                                                                          | Permissions for the etcd configuration directory.                                                                                                                                                            |
| `bootstrap_etcd__conf_dir_user`        | `"root"`                                                                                                          | Owner of the etcd configuration directory.                                                                                                                                                                   |
| `bootstrap_etcd__conf_dir_group`       | `"{{ bootstrap_etcd__group }}"`                                                                                    | Group owner of the etcd configuration directory.                                                                                                                                                             |
| `bootstrap_etcd__download_dir`         | `"/opt/etcd"`                                                                                                     | The directory where etcd binaries are downloaded and extracted.                                                                                                                                                |
| `bootstrap_etcd__download_dir_mode`    | `"0755"`                                                                                                          | Permissions for the download directory.                                                                                                                                                                      |
| `bootstrap_etcd__download_dir_user`    | `"{{ bootstrap_etcd__user }}"`                                                                                    | Owner of the download directory.                                                                                                                                                                             |
| `bootstrap_etcd__download_dir_group`   | `"{{ bootstrap_etcd__group }}"`                                                                                    | Group owner of the download directory.                                                                                                                                                                       |
| `bootstrap_etcd__bin_dir`              | `"/usr/local/bin"`                                                                                                | The directory where etcd binaries are installed.                                                                                                                                                             |
| `bootstrap_etcd__bin_dir_mode`         | `"0755"`                                                                                                          | Permissions for the binary installation directory.                                                                                                                                                           |
| `bootstrap_etcd__bin_dir_user`         | `"{{ bootstrap_etcd__user }}"`                                                                                    | Owner of the binary installation directory.                                                                                                                                                                  |
| `bootstrap_etcd__bin_dir_group`        | `"{{ bootstrap_etcd__group }}"`                                                                                    | Group owner of the binary installation directory.                                                                                                                                                            |
| `bootstrap_etcd__data_dir`             | `"/var/lib/etcd"`                                                                                                 | The directory where etcd data is stored.                                                                                                                                                                     |
| `bootstrap_etcd__data_dir_mode`        | `"0700"`                                                                                                          | Permissions for the etcd data directory.                                                                                                                                                                     |
| `bootstrap_etcd__data_dir_user`        | `"{{ etcd_user }}"`                                                                                               | Owner of the etcd data directory.                                                                                                                                                                            |
| `bootstrap_etcd__data_dir_group`       | `"{{ etcd_group }}"`                                                                                              | Group owner of the etcd data directory.                                                                                                                                                                      |
| `bootstrap_etcd__architecture`         | `"amd64"`                                                                                                         | The architecture for which to download etcd binaries.                                                                                                                                                        |
| `bootstrap_etcd__allow_unsupported_archs` | `false`                                                                                                        | Whether to allow downloading unsupported architectures.                                                                                                                                                      |
| `bootstrap_etcd__download_url`         | `"https://github.com/etcd-io/etcd/releases/download/v{{ etcd_version }}/etcd-v{{ etcd_version }}-linux-{{ bootstrap_etcd__architecture }}.tar.gz"` | The URL from which to download the etcd binaries.                                                                                                                                                          |
| `bootstrap_etcd__download_url_checksum`| `"sha256:https://github.com/coreos/etcd/releases/download/v{{ etcd_version }}/SHA256SUMS"`                         | The checksum URL for verifying the downloaded etcd binaries.                                                                                                                                                |
| `bootstrap_etcd__service_name`         | `"etcd"`                                                                                                          | The name of the systemd service for etcd.                                                                                                                                                                    |
| `bootstrap_etcd__service_options`      | A list of options for the systemd service, including user, group, restart settings, and security configurations.   | Options to configure the etcd systemd service.                                                                                                                                                               |
| `bootstrap_etcd__settings`             | Configuration settings for etcd, including certificates and URLs.                                                   | Settings used in the etcd configuration file.                                                                                                                                                                |

## Usage

To use this role, include it in your playbook as follows:

```yaml
- hosts: kubernetes_etcd
  roles:
    - bootstrap_etcd
```

Ensure that the `kubernetes_etcd` group is defined in your inventory and contains all nodes intended to be part of the etcd cluster.

## Dependencies

This role has no external dependencies. However, it assumes that the necessary certificates are available in the directory specified by `bootstrap_etcd__ca_conf_directory`.

## Tags

The following tags can be used with this role:

- `etcd` - Applies all tasks related to etcd installation and configuration.
- `download` - Manages the download of etcd binaries.
- `install` - Handles the installation of etcd binaries.
- `config` - Configures etcd settings and systemd service.

## Best Practices

1. **Certificate Management**: Ensure that all required certificates are securely managed and placed in the directory specified by `bootstrap_etcd__ca_conf_directory`.
2. **Version Control**: Specify a stable version of etcd to avoid unexpected behavior due to changes in newer versions.
3. **Security**: Configure appropriate permissions for directories and files, especially those related to certificates.

## Molecule Tests

This role does not include Molecule tests at this time.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_etcd/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_etcd/tasks/main.yml)
- [meta/main.yml](../../roles/bootstrap_etcd/meta/main.yml)
- [handlers/main.yml](../../roles/bootstrap_etcd/handlers/main.yml)