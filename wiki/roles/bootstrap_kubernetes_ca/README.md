```markdown
---
title: ansible-role-kubernetes-ca
original_path: roles/bootstrap_kubernetes_ca/README.md
category: Ansible Roles
tags: [kubernetes, etcd, certificate-authority, ansible]
---

# ansible-role-kubernetes-ca

This role creates two CAs: one for `etcd` and another for Kubernetes components to secure their communication. The Kubernetes API server is the only component that needs direct access to the `etcd` cluster. For infrastructure components like [Cilium](https://cilium.io/) for K8s networking or [Traefik](https://traefik.io) for ingress, reusing the existing `etcd` cluster may be beneficial. For more information, see [Kubernetes the not so hard way with Ansible - Certificate authority (CA)](https://www.tauceti.blog/post/kubernetes-the-not-so-hard-way-with-ansible-certificate-authority/).

## Versions

I tag every release and adhere to [semantic versioning](http://semver.org). To use this role, it is recommended to checkout the latest tag. The master branch is primarily for development, while tags mark stable releases. Generally, I aim to keep the master branch in good condition as well. A tag `12.0.0+1.28.5` indicates that this is release `12.0.0` of the role and it is intended for Kubernetes version >= `1.28.5`. Typically, it should work with any Kubernetes version >= 1.18.0, but I have tested it specifically with the tagged version. If there are changes to the role itself, `X.Y.Z` before `+` will increase. If the Kubernetes version changes, `X.Y.Z` after `+` will increase, and the role patch version will also increase (e.g., from `12.0.0` to `12.0.1`). This allows tagging bugfixes and new major versions of the role while it is still developed for a specific Kubernetes release.

## Requirements

This playbook requires [CFSSL](https://github.com/cloudflare/cfssl) PKI toolkit binaries to be installed. You can use [bootstrap_cfssl](https://github.com/lj020326/ansible-datacenter/blob/main/roles/bootstrap_cfssl) to install CFSSL locally on your machine. To store the generated certificates and CAs locally or on a network share, specify the role variables below in `host_vars/localhost` or in `group_vars/all`.

## Role Variables

This playbook has several variables that provide necessary information for the certificates.

```yaml
# The directory where to store the certificates. By default this will expand to the user's LOCAL $HOME (the user that runs "ansible-playbook ...")
# plus "/k8s/certs". For example, if the user's $HOME directory is "/home/da_user", then "bootstrap_kubernetes_ca__ca_conf_directory" will have a value of
# "/home/da_user/k8s/certs".
bootstrap_kubernetes_ca__ca_conf_directory: "{{ '~/k8s/certs' | expanduser }}"

# Directory permissions for the directory specified in "bootstrap_kubernetes_ca__ca_conf_directory"
bootstrap_kubernetes_ca__ca_conf_directory_perm: "0770"

# File permissions for certificates, csr, and so on
bootstrap_kubernetes_ca__ca_file_perm: "0660"

# Owner of the certificate files (you should probably change this)
bootstrap_kubernetes_ca__ca_certificate_owner: "root"

# Group to which the certificate files belong (you should probably change this)
bootstrap_kubernetes_ca__ca_certificate_group: "root"

# Specifies Ansible's hosts group containing all K8s controller nodes (as specified in Ansible's "hosts" file).
bootstrap_kubernetes_ca__ca_controller_nodes_group: "bootstrap_kubernetes_ca__controller"

# As above but for the K8s etcd nodes.
bootstrap_kubernetes_ca__ca_etcd_nodes_group: "bootstrap_kubernetes_ca__etcd"

# As above but for the K8s worker nodes.
bootstrap_kubernetes_ca__ca_worker_nodes_group: "bootstrap_kubernetes_ca__worker"

# This role will include the IP address of the interface you specify here in
# the etcd, kube-apiserver and kubelet certificate SAN (subject alternative name).
# This is the interface where all Kubernetes cluster services communicate
# and should be an encrypted network. Examples for interface names:
# "wg0" (WireGuard), "peervpn0" (PeerVPN), "eth0", "tap0"
bootstrap_kubernetes_ca__interface: "eth0"

# Expiry for etcd root certificate
bootstrap_kubernetes_ca__etcd_expiry: "87600h"

# Certificate authority (CA) parameters for etcd certificates. This CA is used
# to sign certificates used by etcd (like peer and server certificates) and
# etcd clients (like "Kube API Server", "Traefik" and "Cilium" e.g.).
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

# Certificate authority (CA) parameters for Kubernetes API server. The CA is
# used to sign certificates for various Kubernetes services like Kubernetes API
# server e.g.
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

## Backlinks

- [Kubernetes the not so hard way with Ansible](https://www.tauceti.blog/post/kubernetes-the-not-so-hard-way-with-ansible-certificate-authority/)
- [bootstrap_cfssl Role](https://github.com/lj020326/ansible-datacenter/blob/main/roles/bootstrap_cfssl)
```

This improved version includes a clean and professional structure with proper headings, standardized Markdown formatting, and added YAML frontmatter for better organization.