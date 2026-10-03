---
title: Ansible Role - Kubernetes Controller
original_path: roles/bootstrap_kubernetes_controller/README.md
source_type: legacy_markdown
category: Ansible
tags:
  - Kubernetes
  - Ansible
  - Control Plane
  - DevOps
harvested_date: '2026-08-07T18:07:09.266691+00:00'
---

# Ansible Role - Kubernetes Controller

This role is used to install and configure the Kubernetes control plane components, including the API server, scheduler, and controller manager. It is part of the [Kubernetes the not so hard way with Ansible - Control plane](https://www.tauceti.blog/post/kubernetes-the-not-so-hard-way-with-ansible-control-plane/) series.

## Table of Contents
- [Introduction](#introduction)
- [Versions](#versions)
- [Requirements](#requirements)
- [Supported OS](#supported-os)
- [Role (default) variables](#role-default-variables)
- [Usage](#usage)
- [Backlinks](#backlinks)

## Introduction

This role installs the Kubernetes API server, scheduler, and controller manager. It is designed to be used as part of a larger Kubernetes deployment process.

## Versions

I tag every release and try to stay with [semantic versioning](http://semver.org). If you want to use the role, I recommend checking out the latest tag. The main branch is primarily for development, while the tags mark stable releases. In general, I try to keep the main branch in good shape as well.

A tag `26.0.1+1.31.5` means this is release `26.0.1` of this role and it's meant to be used with Kubernetes version `1.31.5` (but should work with any K8s 1.31.x release). If the role itself changes, `X.Y.Z` before `+` will increase. If the Kubernetes version changes, `X.Y.Z` after `+` will increase too. This allows tagging bugfixes and new major versions of the role while it's still developed for a specific Kubernetes release. This is especially useful for Kubernetes major releases with breaking changes.

## Requirements

This role requires that you have already created some certificates for the Kubernetes API server (see [Kubernetes the not so hard way with Ansible - Certificate authority (CA)](https://www.tauceti.blog/post/kubernetes-the-not-so-hard-way-with-ansible-certificate-authority/)). The role copies the certificates from `bootstrap_kubernetes_controller__ca_conf_directory` (which is by default the same as `deploy_pki_certs__local_cert_dir` used by `deploy_ca_certs` role) to the destination host.

Your hosts on which you want to install Kubernetes should be able to communicate with each other. To add an additional layer of security, you can set up a fully meshed VPN with WireGuard, for example (see [Kubernetes the not so hard way with Ansible - WireGuard](https://www.tauceti.blog/post/kubernetes-the-not-so-hard-way-with-ansible-wireguard/)). This encrypts every communication between the Kubernetes nodes if the Kubernetes processes use the WireGuard interface. Using WireGuard actually makes it easily possible to have a Kubernetes cluster that is distributed across various data centers.

And of course, you need an [etcd](https://etcd.io/) cluster (see [Kubernetes the not so hard way with Ansible - etcd cluster](https://www.tauceti.blog/post/kubernetes-the-not-so-hard-way-with-ansible-etcd/)) to store the state of the Kubernetes cluster.

## Supported OS

- Ubuntu 20.04 (Focal Fossa) (reaches EOL April 2025 - not recommended)
- Ubuntu 22.04 (Jammy Jellyfish)
- Ubuntu 24.04 (Noble Numbat) (recommended)

## Role (default) variables

```yaml
# The base directory for Kubernetes configuration and certificate files for
# everything control plane related. After the playbook is done this directory
# contains various sub-folders.
bootstrap_kubernetes_controller__conf_dir: "/etc/kubernetes/controller"

# All certificate files (Private Key Infrastructure related) specified in
# "bootstrap_kubernetes_controller__certificates" and "bootstrap_kubernetes_controller__etcd_certificates" (see "vars/main.yml")
# will be stored here. Owner of this new directory will be "root". Group will
# be the group specified in "bootstrap_kubernetes_controller__run_as_group"`. The files in this directory
# will be owned by "root" and group as specified in "bootstrap_kubernetes_controller__run_as_group"`. File
# permissions will be "0640".
bootstrap_kubernetes_controller__pki_dir: "{{ bootstrap_kubernetes_controller__conf_dir }}/pki"

# The directory to store the Kubernetes binaries (see "bootstrap_kubernetes_controller__binaries"
# variable in "vars/main.yml"). Owner and group of this new directory
# will be "root" in both cases. Permissions for this directory will be "0755".
#
# NOTE: The default directory "/usr/local/bin" normally already exists on every
# Linux installation with the owner, group and permissions mentioned above. If
# your current settings are different consider a different directory. But make sure
# that the new directory is included in your "$PATH" variable value.
bootstrap_kubernetes_controller__bin_dir: "/usr/local/bin"

# The Kubernetes release.
bootstrap_kubernetes_controller__release: "1.31.11"

# The interface on which the Kubernetes services should listen on. As all cluster
# communication should use a VPN interface the interface name is
# normally "wg0" (WireGuard),"peervpn0" (PeerVPN) or "tap0".
#
# The network interface on which the Kubernetes control plane services should
# listen on. That is:
#
# - kube-apiserver
# - kube-scheduler
# - kube-controller-manager
#
bootstrap_kubernetes_controller__interface: "eth0"

# Run Kubernetes control plane service (kube-apiserver, kube-scheduler,
# kube-controller-manager) as this user.
#
# If you want to use a "secure-port" < 1024 for "kube-apiserver" you most
# probably need to run "kube-apiserver" as user "root" (not recommended).
#
# If the user specified in "bootstrap_kubernetes_controller__run_as_user" does not exist then the role
# will create it. Only if the user already exists the role will not create it
# but it will adjust it's UID/GID and shell if specified (see settings below).
# So make sure that UID, GID and shell matches the existing user if you don't
# want that that user will be changed.
#
# Additionally if "bootstrap_kubernetes_controller__run_as_user" is "root" then this role wont touch the user
# at all.
bootstrap_kubernetes_controller__run_as_user: "k8s"

# UID of user specified in "bootstrap_kubernetes_controller__run_as_user". If not specified the next available
# UID from "/etc/login.defs" will be taken.
...
```

## Usage

To use this role, include it in your playbook as follows:

```yaml
- hosts: kubernetes_control_plane
  roles:
    - bootstrap_kubernetes_controller
```

Make sure to set the required variables in your inventory or playbook.

## Backlinks

- [Kubernetes the not so hard way with Ansible - Control plane](https://www.tauceti.blog/post/kubernetes-the-not-so-hard-way-with-ansible-control-plane/)
- [Kubernetes the not so hard way with Ansible - Certificate authority (CA)](https://www.tauceti.blog/post/kubernetes-the-not-so-hard-way-with-ansible-certificate-authority/)
- [Kubernetes the not so hard way with Ansible - WireGuard](https://www.tauceti.blog/post/kubernetes-the-not-so-hard-way-with-ansible-wireguard/)
- [Kubernetes the not so hard way with Ansible - etcd cluster](https://www.tauceti.blog/post/kubernetes-the-not-so-hard-way-with-ansible-etcd/)