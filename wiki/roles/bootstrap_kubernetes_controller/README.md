```markdown
---
title: Ansible Role for Kubernetes Controller
original_path: roles/bootstrap_kubernetes_controller/README.md
category: Ansible Roles
tags: [Kubernetes, Ansible, Control Plane]
---

# Ansible Role for Kubernetes Controller

This role is used in [Kubernetes the not so hard way with Ansible - Control plane](https://www.tauceti.blog/post/kubernetes-the-not-so-hard-way-with-ansible-control-plane/). It installs the Kubernetes API server, scheduler, and controller manager. For more information about this role, please refer to [Kubernetes the not so hard way with Ansible - Control plane](https://www.tauceti.blog/post/kubernetes-the-not-so-hard-way-with-ansible-control-plane/).

## Versions

I tag every release and adhere to [semantic versioning](http://semver.org). If you want to use this role, I recommend checking out the latest tag. The `main` branch is primarily for development, while tags mark stable releases. Generally, I aim to keep `main` in good shape as well.

A tag like `26.0.1+1.31.5` indicates that this is release `26.0.1` of the role and it's intended for Kubernetes version `1.31.5`. However, it should work with any K8s 1.31.x release. If there are changes to the role itself, `X.Y.Z` before the `+` will increase. If the Kubernetes version changes, `X.Y.Z` after the `+` will increase. This allows tagging bugfixes and new major versions of the role while it's still developed for a specific Kubernetes release. This is especially useful for Kubernetes major releases with breaking changes.

## Requirements

This role requires that you have already created certificates for the Kubernetes API server (see [Kubernetes the not so hard way with Ansible - Certificate authority (CA)](https://www.tauceti.blog/post/kubernetes-the-not-so-hard-way-with-ansible-certificate-authority/)). The role copies these certificates from `bootstrap_kubernetes_controller__ca_conf_directory` (which defaults to the same as `deploy_pki_certs__local_cert_dir` used by the `deploy_ca_certs` role) to the destination host.

Your hosts should be able to communicate with each other. For an additional layer of security, you can set up a fully meshed VPN using WireGuard, for example (see [Kubernetes the not so hard way with Ansible - WireGuard](https://www.tauceti.blog/post/kubernetes-the-not-so-hard-way-with-ansible-wireguard/)). This encrypts all communication between Kubernetes nodes if the Kubernetes processes use the WireGuard interface. Using WireGuard also makes it easy to have a Kubernetes cluster distributed across various data centers.

Additionally, you need an [etcd](https://etcd.io/) cluster (see [Kubernetes the not so hard way with Ansible - etcd cluster](https://www.tauceti.blog/post/kubernetes-the-not-so-hard-way-with-ansible-etcd/)) to store the state of the Kubernetes cluster.

## Supported OS

- Ubuntu 20.04 (Focal Fossa) (reaches EOL April 2025 - not recommended)
- Ubuntu 22.04 (Jammy Jellyfish)
- Ubuntu 24.04 (Noble Numbat) (recommended)

## Role Variables

### Default Variables

```yaml
# Base directory for Kubernetes configuration and certificate files for everything control plane related.
bootstrap_kubernetes_controller__conf_dir: "/etc/kubernetes/controller"

# Directory to store all certificate files specified in "bootstrap_kubernetes_controller__certificates" and "bootstrap_kubernetes_controller__etcd_certificates".
bootstrap_kubernetes_controller__pki_dir: "{{ bootstrap_kubernetes_controller__conf_dir }}/pki"

# Directory to store Kubernetes binaries.
bootstrap_kubernetes_controller__bin_dir: "/usr/local/bin"

# The Kubernetes release version.
bootstrap_kubernetes_controller__release: "1.31.11"

# Network interface on which the Kubernetes services should listen.
bootstrap_kubernetes_controller__interface: "eth0"

# User under which Kubernetes control plane services (kube-apiserver, kube-scheduler, kube-controller-manager) will run.
bootstrap_kubernetes_controller__run_as_user: "k8s"
```

### Additional Variables

For a complete list of variables and their descriptions, refer to the `vars/main.yml` file in this role.

## Backlinks

- [Kubernetes the not so hard way with Ansible - Control plane](https://www.tauceti.blog/post/kubernetes-the-not-so-hard-way-with-ansible-control-plane/)
- [Kubernetes the not so hard way with Ansible - Certificate authority (CA)](https://www.tauceti.blog/post/kubernetes-the-not-so-hard-way-with-ansible-certificate-authority/)
- [Kubernetes the not so hard way with Ansible - WireGuard](https://www.tauceti.blog/post/kubernetes-the-not-so-hard-way-with-ansible-wireguard/)
- [Kubernetes the not so hard way with Ansible - etcd cluster](https://www.tauceti.blog/post/kubernetes-the-not-so-hard-way-with-ansible-etcd/)

```

This improved version includes a clean and professional structure, proper headings, and additional metadata in the YAML frontmatter. It also adds a "Backlinks" section for easy navigation to related resources.