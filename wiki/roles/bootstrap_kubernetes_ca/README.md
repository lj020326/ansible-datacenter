---
title: Ansible Role - Kubernetes CA
original_path: roles/bootstrap_kubernetes_ca/README.md
category: Ansible
tags: [Kubernetes, CA, Ansible, CFSSL]
---

# Ansible Role - Kubernetes CA

This role creates two Certificate Authorities (CAs): one for `etcd` and one for Kubernetes components. These CAs are essential for securing communication between Kubernetes components. Typically, only the Kubernetes API server needs to communicate directly with the `etcd` cluster. For infrastructure components like [Cilium](https://cilium.io/) for K8s networking or [Traefik](https://traefik.io) for ingress, it may make sense to reuse the existing `etcd` cluster. For more information, see [Kubernetes the not so hard way with Ansible - Certificate authority (CA)](https://www.tauceti.blog/post/kubernetes-the-not-so-hard-way-with-ansible-certificate-authority/).

The `bootstrap_kubernetes_ca__use_existing_root_ca` variable acts as a toggle. When set to true, the role will look for the external root CA at the paths specified by `bootstrap_kubernetes_ca__root_ca_cert_path` and `bootstrap_kubernetes_ca__root_ca_key_path` to sign the new Kubernetes CA certificates. When set to false, the role will generate new, self-signed CAs.

## Table of Contents
1. [Versions](#versions)
2. [Requirements](#requirements)
3. [Role Variables](#role-variables)
4. [Example Playbook](#example-playbook)
5. [Testing the Role](#testing-the-role)
6. [Known Issues](#known-issues)
7. [Backlinks](#backlinks)

## Versions

I tag every release and try to stay with [semantic versioning](http://semver.org). If you want to use the role, I recommend checking out the latest tag. The master branch is primarily for development, while the tags mark stable releases. In general, I try to keep the master branch in good shape as well.

A tag `12.0.0+1.28.5` means this is release `12.0.0` of this role and it's meant to be used with Kubernetes version >= `1.28.5` (while it should normally work with any Kubernetes version >= 1.18.0 but I tested it with the version tagged). If the role itself changes `X.Y.Z` before `+` will increase. If the Kubernetes version changes `X.Y.Z` after `+` will increase and also the role patch version will increase (e.g., from `12.0.0` to `12.0.1`). This allows tagging bugfixes and new major versions of the role while it's still being developed for a specific Kubernetes release.

## Requirements

This playbook requires the [CFSSL](https://github.com/cloudflare/cfssl) PKI toolkit binaries to be installed. You can use the [bootstrap_cfssl](https://github.com/lj020326/ansible-datacenter/blob/main/roles/bootstrap_cfssl) role to install CFSSL locally on your machine. If CFSSL is not installed, the role will fail. If you want to store the generated certificates and CAs locally or on a network share, specify the role variables below in `host_vars/localhost` or in `group_vars/all`.

## Role Variables

This playbook has several variables, primarily for certificate information.

```yaml
# The directory where to store the certificates. By default, this will expand to the user's LOCAL $HOME
# (the user that runs "ansible-playbook ...") plus "/k8s/certs". For example, if the user's $HOME directory
# is "/home/da_user", then "bootstrap_kubernetes_ca__ca_conf_directory" will have a value of
# "/home/da_user/k8s/certs".
bootstrap_kubernetes_ca__ca_conf_directory: "{{ '~/k8s/certs' | expanduser }}"

# Directory permissions for the directory specified in "bootstrap_kubernetes_ca__ca_conf_directory"
bootstrap_kubernetes_ca__ca_conf_directory_perm: "0770"

# File permissions for certificates, CSRs, and so on
bootstrap_kubernetes_ca__ca_file_perm: "0660"

# Owner of the certificate files (you should probably change this)
bootstrap_kubernetes_ca__ca_certificate_owner: "root"

# Group to which the certificate files belong (you should probably change this)
bootstrap_kubernetes_ca__ca_certificate_group: "root"

# Specifies Ansible's hosts group which contains all K8s controller nodes (as specified in Ansible's "hosts" file).
bootstrap_kubernetes_ca__ca_controller_nodes_group: "bootstrap_kubernetes_ca__controller"

# As above but for the K8s etcd nodes.
bootstrap_kubernetes_ca__ca_etcd_nodes_group: "bootstrap_kubernetes_ca__etcd"

# As above but for the K8s worker nodes.
bootstrap_kubernetes_ca__ca_worker_nodes_group: "bootstrap_kubernetes_ca__worker"

# This role will include the IP address of the interface you specify here in the etcd, kube-apiserver, and kubelet certificate SAN (subject alternative name).
# This is the interface where all the Kubernetes cluster services communicate and should be on an encrypted network. Some examples for interface names:
# "wg0" (WireGuard), "peervpn0" (PeerVPN), "eth0", "tap0"
bootstrap_kubernetes_ca__interface: "eth0"

# Expiry for etcd root certificate
bootstrap_kubernetes_ca__etcd_expiry: "87600h"

# Certificate authority (CA) parameters for etcd certificates. This CA is used to sign certificates used by etcd (like peer and server certificates) and etcd clients (like "Kube API Server", "Traefik", and "Cilium" e.g.).
bootstrap_kubernetes_ca__ca_etcd_csr_cn: "etcd"
bootstrap_kubernetes_ca__ca_etcd_csr_key_algo: "rsa"
bootstrap_kubernetes_ca__ca_etcd_csr_key_size: "2048"
bootstrap_kubernetes_ca__ca_etcd_csr_names_c: "DE"
bootstrap_kubernetes_ca__ca_etcd_csr_names_l: "The_Internet"
bootstrap_kubernetes_ca__ca_etcd_csr_names_o: "Kubernetes"
bootstrap_kubernetes_ca__ca_etcd_csr_names_ou: "BY"
bootstrap_kubernetes_ca__ca_etcd_csr_names_st: "Bayern"

# Expiry for Kubernetes API server root certificate
bootstrap_kubernetes_ca__ca_apiserver_expiry: "87600h"

# Certificate authority (CA) parameters for Kubernetes API server. The CA is used to sign certificates for various Kubernetes services like the Kubernetes API server e.g.
bootstrap_kubernetes_ca__apiserver_csr_cn: "Kubernetes"
bootstrap_kubernetes_ca__apiserver_csr_key_algo: "rsa"
bootstrap_kubernetes_ca__apiserver_csr_key_size: "2048"
bootstrap_kubernetes_ca__apiserver_csr_names_c: "DE"
bootstrap_kubernetes_ca__apiserver_csr_names_l: "The_Internet"
bootstrap_kubernetes_ca__apiserver_csr_names_o: "Kubernetes"
bootstrap_kubernetes_ca__apiserver_csr_names_ou: "BY"
bootstrap_kubernetes_ca__apiserver_csr_names_st: "Bayern"

# CSR parameter for etcd server certificate. The server certificate
... [truncated - large file] ...
```

## Example Playbook

Here's an example of how to use the role in a playbook:

```yaml
---
- name: Setup Kubernetes CA
  hosts: localhost
  roles:
    - role: bootstrap_kubernetes_ca
      vars:
        bootstrap_kubernetes_ca__use_existing_root_ca: false
        bootstrap_kubernetes_ca__ca_conf_directory: "/path/to/certs"
```

## Testing the Role

To test the role, you can use the following command:

```bash
ansible-playbook -i localhost, -c local test.yml
```

Where `test.yml` is a playbook that includes the role.

## Known Issues

- None known at this time.

## Backlinks

[Add backlinks to related documentation pages here]