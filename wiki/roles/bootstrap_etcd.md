---
title: Bootstrap etcd Role Documentation
role: bootstrap_etcd
category: Kubernetes
type: Ansible Role
tags: etcd, ha, kv
---

## Summary

The `bootstrap_etcd` role is designed to install and configure an etcd cluster. It handles the creation of necessary directories, user accounts, group permissions, certificate management, binary installation, and systemd service configuration for etcd.

## Variables

| Variable Name                             | Default Value                                                                                   | Description                                                                                                                                                           |
|-------------------------------------------|-------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_etcd__ca_conf_directory`       | `"~/etcd-certificates" \| expanduser`                                                           | Directory containing the CA certificates and keys.                                                                                                                    |
| `bootstrap_etcd__ansible_group`           | `"kubernetes_etcd"`                                                                             | Ansible group to which etcd nodes belong.                                                                                                                             |
| `bootstrap_etcd__version`                 | `"3.6.4"`                                                                                       | Version of etcd to install.                                                                                                                                         |
| `bootstrap_etcd__client_port`             | `"2379"`                                                                                        | Port for client communication with etcd.                                                                                                                              |
| `bootstrap_etcd__peer_port`               | `"2380"`                                                                                        | Port for peer communication between etcd nodes.                                                                                                                       |
| `bootstrap_etcd__interface`               | `"tap0"`                                                                                        | Network interface to use for etcd communication.                                                                                                                      |
| `bootstrap_etcd__user`                    | `"etcd"`                                                                                        | User under which etcd will run.                                                                                                                                       |
| `bootstrap_etcd__user_shell`              | `"/bin/false"`                                                                                  | Shell for the etcd user.                                                                                                                                            |
| `bootstrap_etcd__user_system`             | `true`                                                                                          | Whether to create a system user for etcd.                                                                                                                           |
| `bootstrap_etcd__group`                   | `"etcd"`                                                                                        | Group under which etcd will run.                                                                                                                                      |
| `bootstrap_etcd__group_system`            | `true`                                                                                          | Whether to create a system group for etcd.                                                                                                                          |
| `bootstrap_etcd__conf_dir`                | `"/etc/etcd"`                                                                                   | Directory where etcd configuration files are stored.                                                                                                                  |
| `bootstrap_etcd__conf_dir_mode`           | `"0750"`                                                                                        | Permissions mode for the configuration directory.                                                                                                                     |
| `bootstrap_etcd__conf_dir_user`           | `"root"`                                                                                        | Owner of the configuration directory.                                                                                                                                 |
| `bootstrap_etcd__conf_dir_group`          | `"{{ bootstrap_etcd__group }}"`                                                                  | Group owner of the configuration directory.                                                                                                                           |
| `bootstrap_etcd__download_dir`            | `"/opt/etcd"`                                                                                   | Directory where etcd binaries are downloaded and extracted.                                                                                                           |
| `bootstrap_etcd__download_dir_mode`       | `"0755"`                                                                                        | Permissions mode for the download directory.                                                                                                                        |
| `bootstrap_etcd__download_dir_user`       | `"{{ bootstrap_etcd__user }}"`                                                                  | Owner of the download directory.                                                                                                                                      |
| `bootstrap_etcd__download_dir_group`      | `"{{ bootstrap_etcd__group }}"`                                                                  | Group owner of the download directory.                                                                                                                                |
| `bootstrap_etcd__bin_dir`                 | `"/usr/local/bin"`                                                                              | Directory where etcd binaries are installed.                                                                                                                          |
| `bootstrap_etcd__bin_dir_mode`            | `"0755"`                                                                                        | Permissions mode for the binary directory.                                                                                                                          |
| `bootstrap_etcd__bin_dir_user`            | `"{{ bootstrap_etcd__user }}"`                                                                  | Owner of the binary directory.                                                                                                                                        |
| `bootstrap_etcd__bin_dir_group`           | `"{{ bootstrap_etcd__group }}"`                                                                  | Group owner of the binary directory.                                                                                                                                  |
| `bootstrap_etcd__data_dir`                | `"/var/lib/etcd"`                                                                               | Directory where etcd data is stored.                                                                                                                                  |
| `bootstrap_etcd__data_dir_mode`           | `"0700"`                                                                                        | Permissions mode for the data directory.                                                                                                                            |
| `bootstrap_etcd__data_dir_user`           | `"{{ bootstrap_etcd__user }}"`                                                                  | Owner of the data directory.                                                                                                                                          |
| `bootstrap_etcd__data_dir_group`          | `"{{ bootstrap_etcd__group }}"`                                                                  | Group owner of the data directory.                                                                                                                                    |
| `bootstrap_etcd__architecture`            | `{{ 'arm64' if ansible_facts.machine == 'aarch64' else 'amd64' }}`                               | Architecture of the system (automatically detected).                                                                                                                  |
| `bootstrap_etcd__allow_unsupported_archs` | `false`                                                                                         | Whether to allow unsupported architectures.                                                                                                                           |
| `bootstrap_etcd__download_url`            | `"https://github.com/etcd-io/etcd/releases/download/v{{ etcd_version }}/etcd-v{{ etcd_version }}-linux-{{ bootstrap_etcd__architecture }}.tar.gz"` | URL for downloading the etcd binary package.                                                                                                                        |
| `bootstrap_etcd__download_url_checksum`   | `"sha256:https://github.com/coreos/etcd/releases/download/v{{ etcd_version }}/SHA256SUMS"`         | Checksum URL for verifying the downloaded etcd binary package.                                                                                                      |
| `bootstrap_etcd__service_name`            | `"etcd"`                                                                                        | Name of the systemd service for etcd.                                                                                                                                 |
| `bootstrap_etcd__service_options`         | List of options for the systemd service (e.g., User, Group, Restart settings)                   | Options to configure the systemd service for etcd.                                                                                                                    |
| `bootstrap_etcd__settings`                | Dictionary containing configuration settings for etcd (e.g., name, cert-file, key-file)           | Configuration settings for etcd, including paths to certificates and keys.                                                                                        |

## Usage

To use this role, include it in your playbook and specify the necessary variables as needed. Here is an example of how you might include this role in a playbook:

```yaml
- hosts: kubernetes_etcd
  roles:
    - role: bootstrap_etcd
      vars:
        bootstrap_etcd__version: "3.6.4"
        bootstrap_etcd__client_port: "2379"
        bootstrap_etcd__peer_port: "2380"
```

## Dependencies

This role does not have any external dependencies beyond the standard Ansible modules and the ability to download files from the internet.

## Best Practices

- Ensure that the `bootstrap_etcd__ca_conf_directory` contains all necessary certificates and keys before running this role.
- Verify that the `bootstrap_etcd__download_url_checksum` is correct to prevent downloading corrupted or malicious binaries.
- Use a dedicated user and group for etcd to enhance security.

## Molecule Tests

This role does not currently include Molecule tests. However, it is recommended to write and run tests to ensure the role functions as expected in different environments.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_etcd/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_etcd/tasks/main.yml)
- [meta/main.yml](../../roles/bootstrap_etcd/meta/main.yml)
- [handlers/main.yml](../../roles/bootstrap_etcd/handlers/main.yml)