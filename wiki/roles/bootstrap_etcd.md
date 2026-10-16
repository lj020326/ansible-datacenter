---
title: "Bootstrap ETCD Role"
role: roles/bootstrap_etcd
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_etcd]
---

```yaml
---
title: "Bootstrap ETCD Role Documentation"
role: "bootstrap_etcd"
category: "Kubernetes"
type: "Role"
---

# Bootstrap ETCD Role Documentation

## Summary

The `bootstrap_etcd` role is designed to install and configure an ETCD cluster on Ubuntu systems. ETCD is a distributed key-value store used for configuration management and service discovery in Kubernetes clusters. This role automates the setup of ETCD, including user and group creation, directory configuration, certificate management, binary installation, and service configuration.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_etcd__ca_conf_directory` | `~/etcd-certificates` | Directory where CA certificates are stored. |
| `bootstrap_etcd__ansible_group` | `kubernetes_etcd` | Ansible group for ETCD nodes. |
| `bootstrap_etcd__version` | `3.6.4` | Version of ETCD to install. |
| `bootstrap_etcd__client_port` | `2379` | Client port for ETCD. |
| `bootstrap_etcd__peer_port` | `2380` | Peer port for ETCD. |
| `bootstrap_etcd__interface` | `tap0` | Network interface for ETCD. |
| `bootstrap_etcd__user` | `etcd` | Username for ETCD service. |
| `bootstrap_etcd__user_shell` | `/bin/false` | Shell for ETCD user. |
| `bootstrap_etcd__user_system` | `true` | Whether the ETCD user is a system user. |
| `bootstrap_etcd__group` | `etcd` | Group for ETCD service. |
| `bootstrap_etcd__group_system` | `true` | Whether the ETCD group is a system group. |
| `bootstrap_etcd__conf_dir` | `/etc/etcd` | Directory for ETCD configuration files. |
| `bootstrap_etcd__conf_dir_mode` | `0750` | Permissions for ETCD configuration directory. |
| `bootstrap_etcd__conf_dir_user` | `root` | Owner of ETCD configuration directory. |
| `bootstrap_etcd__conf_dir_group` | `{{ bootstrap_etcd__group }}` | Group owner of ETCD configuration directory. |
| `bootstrap_etcd__download_dir` | `/opt/etcd` | Directory for ETCD binaries. |
| `bootstrap_etcd__download_dir_mode` | `0755` | Permissions for ETCD download directory. |
| `bootstrap_etcd__download_dir_user` | `{{ bootstrap_etcd__user }}` | Owner of ETCD download directory. |
| `bootstrap_etcd__download_dir_group` | `{{ bootstrap_etcd__group }}` | Group owner of ETCD download directory. |
| `bootstrap_etcd__bin_dir` | `/usr/local/bin` | Directory for ETCD binaries. |
| `bootstrap_etcd__bin_dir_mode` | `0755` | Permissions for ETCD binaries directory. |
| `bootstrap_etcd__bin_dir_user` | `{{ bootstrap_etcd__user }}` | Owner of ETCD binaries directory. |
| `bootstrap_etcd__bin_dir_group` | `{{ bootstrap_etcd__group }}` | Group owner of ETCD binaries directory. |
| `bootstrap_etcd__data_dir` | `/var/lib/etcd` | Directory for ETCD data. |
| `bootstrap_etcd__data_dir_mode` | `0700` | Permissions for ETCD data directory. |
| `bootstrap_etcd__data_dir_user` | `{{ bootstrap_etcd__user }}` | Owner of ETCD data directory. |
| `bootstrap_etcd__data_dir_group` | `{{ bootstrap_etcd__group }}` | Group owner of ETCD data directory. |
| `bootstrap_etcd__architecture` | `{{ 'arm64' if ansible_facts.machine == 'aarch64' else 'amd64' }}` | Architecture for ETCD binaries. |
| `bootstrap_etcd__allow_unsupported_archs` | `false` | Allow unsupported architectures. |
| `bootstrap_etcd__download_url` | `https://github.com/etcd-io/etcd/releases/download/v{{ bootstrap_etcd__version }}/etcd-v{{ bootstrap_etcd__version }}-linux-{{ bootstrap_etcd__architecture }}.tar.gz` | URL for ETCD download. |
| `bootstrap_etcd__download_url_checksum` | `sha256:https://github.com/coreos/etcd/releases/download/v{{ bootstrap_etcd__version }}/SHA256SUMS` | Checksum for ETCD download. |
| `bootstrap_etcd__service_name` | `etcd` | Name of the ETCD service. |
| `bootstrap_etcd__service_options` | `[User={{ bootstrap_etcd__user }}, Group={{ bootstrap_etcd__group }}, Restart=on-failure, RestartSec=5, Type=notify, ProtectHome=true, PrivateTmp=true, ProtectSystem=full, ProtectKernelModules=true, ProtectKernelTunables=true, ProtectControlGroups=true, CapabilityBoundingSet=~CAP_SYS_PTRACE]` | Options for the ETCD service. |
| `bootstrap_etcd__settings` | `{"name": "{{ ansible_facts['hostname'] }}", "cert-file": "{{ bootstrap_etcd__conf_dir }}/cert-etcd-server.pem", "key-file": "{{ bootstrap_etcd__conf_dir }}/cert-etcd-server-key.pem", "trusted-ca-file": "{{ bootstrap_etcd__conf_dir }}/ca-etcd.pem", "peer-cert-file": "{{ bootstrap_etcd__conf_dir }}/cert-etcd-peer.pem", "peer-key-file": "{{ bootstrap_etcd__conf_dir }}/cert-etcd-peer-key.pem", "peer-trusted-ca-file": "{{ bootstrap_etcd__conf_dir }}/ca-etcd.pem"}` | Settings for ETCD configuration. |

## Usage

To use the `bootstrap_etcd` role, include it in your playbook and configure the necessary variables. Here is an example playbook:

```yaml
---
- hosts: kubernetes_etcd
  become: true
  roles:
    - role: bootstrap_etcd
      vars:
        bootstrap_etcd__version: "3.6.4"
        bootstrap_etcd__client_port: "2379"
        bootstrap_etcd__peer_port: "2380"
        bootstrap_etcd__interface: "tap0"
        bootstrap_etcd__user: "etcd"
        bootstrap_etcd__group: "etcd"
        bootstrap_etcd__conf_dir: "/etc/etcd"
        bootstrap_etcd__download_dir: "/opt/etcd"
        bootstrap_etcd__bin_dir: "/usr/local/bin"
        bootstrap_etcd__data_dir: "/var/lib/etcd"
        bootstrap_etcd__architecture: "{{ 'arm64' if ansible_facts.machine == 'aarch64' else 'amd64' }}"
        bootstrap_etcd__allow_unsupported_archs: false
        bootstrap_etcd__download_url: "https://github.com/etcd-io/etcd/releases/download/v{{ bootstrap_etcd__version }}/etcd-v{{ bootstrap_etcd__version }}-linux-{{ bootstrap_etcd__architecture }}.tar.gz"
        bootstrap_etcd__download_url_checksum: "sha256:https://github.com/coreos/etcd/releases/download/v{{ bootstrap_etcd__version }}/SHA256SUMS"
        bootstrap_etcd__service_name: "etcd"
        bootstrap_etcd__service_options: "[User={{ bootstrap_etcd__user }}, Group={{ bootstrap_etcd__group }}, Restart=on-failure, RestartSec=5, Type=notify, ProtectHome=true, PrivateTmp=true, ProtectSystem=full, ProtectKernelModules=true, ProtectKernelTunables=true, ProtectControlGroups=true, CapabilityBoundingSet=~CAP_SYS_PTRACE]"
        bootstrap_etcd__settings: "{\"name\": \"{{ ansible_facts['hostname'] }}\", \"cert-file\": \"{{ bootstrap_etcd__conf_dir }}/cert-etcd-server.pem\", \"key-file\": \"{{ bootstrap_etcd__conf_dir }}/cert-etcd-server-key.pem\", \"trusted-ca-file\": \"{{ bootstrap_etcd__conf_dir }}/ca-etcd.pem\", \"peer-cert-file\": \"{{ bootstrap_etcd__conf_dir }}/cert-etcd-peer.pem\", \"peer-key-file\": \"{{ bootstrap_etcd__conf_dir }}/cert-etcd-peer-key.pem\", \"peer-trusted-ca-file\": \"{{ bootstrap_etcd__conf_dir }}/ca-etcd.pem\""
```

## Dependencies

This role does not have any external dependencies. It assumes that the necessary CA certificates are already present in the specified directory.

## Best Practices

1. **Security**: Ensure that the CA certificates are securely managed and stored.
2. **Permissions**: Set appropriate permissions for directories and files to prevent unauthorized access.
3. **Monitoring**: Implement monitoring for the ETCD service to ensure its availability and performance.
4. **Backups**: Regularly back up the ETCD data directory to prevent data loss.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_etcd/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_etcd/tasks/main.yml)
- [meta/main.yml](../../roles/bootstrap_etcd/meta/main.yml)
- [handlers/main.yml](../../roles/bootstrap_etcd/handlers/main.yml)