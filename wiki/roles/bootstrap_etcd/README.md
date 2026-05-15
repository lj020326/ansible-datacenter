```markdown
---
title: Ansible Role for etcd Installation
original_path: roles/bootstrap_etcd/README.md
category: Ansible Roles
tags: [etcd, Kubernetes, Ansible]
---

# Ansible Role: `bootstrap_etcd`

This Ansible role is used in the guide [Kubernetes the not so hard way with Ansible - etcd cluster](https://www.tauceti.blog/post/kubernetes-the-not-so-hard-way-with-ansible-etcd/). However, it can be utilized independently of a Kubernetes cluster.

## Overview

The `bootstrap_etcd` role installs an etcd cluster. **Important Note:** This playbook does not automatically reload or restart the etcd processes after modifying the systemd service file. This is intentional to prevent simultaneous restarts across all nodes, which could disrupt the cluster. If changes are made to the `etcd.service` file, manually restart/reload each node one by one and verify that it re-joins the cluster. While this process can be automated, it is not included in this role.

A `systemctl daemon-reload` command is issued after modifying the etcd service file to ensure systemd recognizes the changes. This means a reboot of an etcd node will activate the new configuration.

For upgrading an etcd cluster installed with this role, refer to [Upgrading Kubernetes and etcd](https://www.tauceti.blog/posts/kubernetes-the-not-so-hard-way-with-ansible-upgrading-kubernetes/#etcd).

## Requirements

This role requires pre-existing certificates for `etcd`. These can be generated using the guide [Kubernetes the not so hard way with Ansible - Certificate authority (CA)](https://www.tauceti.blog/post/kubernetes-the-not-so-hard-way-with-ansible-certificate-authority/) or the Ansible role [kubernetes_ca](https://galaxy.ansible.com/ui/standalone/roles/githubixx/kubernetes_ca/). The playbook expects to find these certificates in the `bootstrap_etcd__ca_conf_directory` on the host where the playbook is executed. Alternatively, you can generate self-signed certificates using the instructions found in [Generate self-signed certificates](https://github.com/coreos/docs/blob/master/os/generate-self-signed-certificates.md) (note that this Git repository is archived but the information remains valid).

## Role Variables

```yaml
# Directory containing etcd certificates.
bootstrap_etcd__ca_conf_directory: "{{ '~/etcd-certificates' | expanduser }}"

# Ansible group for etcd nodes.
bootstrap_etcd__ansible_group: "kubernetes_etcd"

# Version of etcd to install.
bootstrap_etcd__version: "3.5.22"

# Port for client connections.
bootstrap_etcd__client_port: "2379"

# Port for peer connections.
bootstrap_etcd__peer_port: "2380"

# Network interface to bind etcd ports.
bootstrap_etcd__interface: "tap0"

# User under which the etcd daemon will run.
#
# Note 1: To use a port < 1024, you may need to run etcd as root.
# Note 2: If the user does not exist, it will be created. Existing users' UID/GID and shell can be adjusted if specified.
bootstrap_etcd__user: "etcd"

# UID for the etcd user (optional).
# bootstrap_etcd__user_uid: "999"

# Shell for the etcd user (default is /bin/false for security reasons).
bootstrap_etcd__user_shell: "/bin/false"

# Whether the etcd user should be a system user.
bootstrap_etcd__user_system: true

# Home directory for the etcd user (ignored if bootstrap_etcd__user_system is true).
# bootstrap_etcd__user_home: "/home/etcd"

# Group under which the etcd daemon will run.
#
# Note: If the group does not exist, it will be created. Existing groups' GID can be adjusted if specified.
bootstrap_etcd__group: "etcd"

# GID for the etcd group (optional).
# bootstrap_etcd__group_gid: "999"

# Whether the etcd group should be a system group.
bootstrap_etcd__group_system: true

# Directory for etcd configuration files.
bootstrap_etcd__conf_dir: "/etc/etcd"

# Permissions for the etcd configuration directory.
bootstrap_etcd__conf_dir_mode: "0750"

# Owner of the etcd configuration directory.
bootstrap_etcd__conf_dir_user: "root"

# Group owner of the etcd configuration directory.
bootstrap_etcd__conf_dir_group: "{{ bootstrap_etcd__group }}"

# Directory to store downloaded etcd archive.
bootstrap_etcd__download_dir: "/opt/etcd"

# Permissions for the download directory.
bootstrap_etcd__download_dir_mode: "0755"

# Owner of the download directory.
bootstrap_etcd__download_dir_user: "{{ bootstrap_etcd__user }}"

# Group owner of the download directory.
bootstrap_etcd__download_dir_group: "{{ bootstrap_etcd__group }}"

# Directory to store etcd binaries.
#
# IMPORTANT: The default value is "/usr/local/bin".
...
```

## Backlinks

- [Kubernetes the not so hard way with Ansible - etcd cluster](https://www.tauceti.blog/post/kubernetes-the-not-so-hard-way-with-ansible-etcd/)
- [Upgrading Kubernetes and etcd](https://www.tauceti.blog/posts/kubernetes-the-not-so-hard-way-with-ansible-upgrading-kubernetes/#etcd)
```

This improved version includes a structured layout, enhanced readability, and additional metadata in the YAML frontmatter.