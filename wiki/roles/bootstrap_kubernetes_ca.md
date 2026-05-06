---
title: "Bootstrap Kubernetes CA Role Documentation"
role: bootstrap_kubernetes_ca
category: Ansible Roles
type: Infrastructure as Code
tags: tls, certificate, security, kubernetes

## Summary
The `bootstrap_kubernetes_ca` role is designed to generate a Certificate Authority (CA) for Kubernetes and issue certificates for etcd and the Kubernetes API server. This role supports both generating a new CA or using an existing one, and it integrates with HashiCorp Vault for secure storage of certificates.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_kubernetes_ca__use_existing_root_ca` | `false` | Specifies whether to use an existing root CA. |
| `bootstrap_kubernetes_ca__root_ca_cert_path` | `/path/to/your/root-ca.pem` | Path to the existing root CA certificate file if using an existing CA. |
| `bootstrap_kubernetes_ca__root_ca_key_path` | `/path/to/your/root-ca-key.pem` | Path to the existing root CA key file if using an existing CA. |
| `bootstrap_kubernetes_ca__vault_url` | `http://127.0.0.1:8200` | URL of the HashiCorp Vault server for storing certificates securely. |
| `bootstrap_kubernetes_ca__vault_token` | `""` | Token to authenticate with HashiCorp Vault. |
| `bootstrap_kubernetes_ca__vault_kv_path` | `secret/kubernetes/ca` | Path in Vault where Kubernetes CA and certificates will be stored. |
| `bootstrap_kubernetes_ca__ca_conf_directory` | `"{{ '~/k8s/certs' \| expanduser }}"` | Directory to store the generated CA configuration files. |
| `bootstrap_kubernetes_ca__ca_conf_directory_perm` | `"0770"` | Permissions for the CA configuration directory. |
| `bootstrap_kubernetes_ca__ca_file_perm` | `"0660"` | Permissions for the generated certificate and key files. |
| `bootstrap_kubernetes_ca__ca_certificate_owner` | `"root"` | Owner of the generated certificate and key files. |
| `bootstrap_kubernetes_ca__ca_certificate_group` | `"root"` | Group owner of the generated certificate and key files. |
| `bootstrap_kubernetes_ca__ca_controller_nodes_group` | `"kubernetes_controller"` | Ansible group name for Kubernetes controller nodes. |
| `bootstrap_kubernetes_ca__ca_etcd_nodes_group` | `"kubernetes_etcd"` | Ansible group name for etcd nodes. |
| `bootstrap_kubernetes_ca__ca_worker_nodes_group` | `"kubernetes_worker"` | Ansible group name for worker nodes. |
| `bootstrap_kubernetes_ca__offline_nodes_group` | `"host_offline"` | Ansible group name for offline nodes to be excluded from the process. |
| `bootstrap_kubernetes_ca__interface` | `"eth0"` | Network interface used to gather IP addresses of nodes. |
| `bootstrap_kubernetes_ca__etcd_expiry` | `"87600h"` | Expiry time for etcd certificates in hours. |
| `bootstrap_kubernetes_ca__ca_etcd_csr_cn` | `"etcd"` | Common Name (CN) for the etcd CSR. |
| `bootstrap_kubernetes_ca__ca_etcd_csr_key_algo` | `"rsa"` | Key algorithm for the etcd CSR. |
| `bootstrap_kubernetes_ca__ca_etcd_csr_key_size` | `"2048"` | Key size for the etcd CSR. |
| `bootstrap_kubernetes_ca__ca_etcd_csr_names_c` | `"DE"` | Country (C) field in the etcd CSR names. |
| `bootstrap_kubernetes_ca__ca_etcd_csr_names_l` | `"The_Internet"` | Locality (L) field in the etcd CSR names. |
| `bootstrap_kubernetes_ca__ca_etcd_csr_names_o` | `"Kubernetes"` | Organization (O) field in the etcd CSR names. |
| `bootstrap_kubernetes_ca__ca_etcd_csr_names_ou` | `"BY"` | Organizational Unit (OU) field in the etcd CSR names. |
| `bootstrap_kubernetes_ca__ca_etcd_csr_names_st` | `"Bayern"` | State/Province (ST) field in the etcd CSR names. |
| `bootstrap_kubernetes_ca__ca_apiserver_expiry` | `"87600h"` | Expiry time for Kubernetes API server certificates in hours. |
| `bootstrap_kubernetes_ca__ca_apiserver_csr_cn` | `"Kubernetes"` | Common Name (CN) for the Kubernetes API server CSR. |
| `bootstrap_kubernetes_ca__ca_apiserver_csr_key_algo` | `"rsa"` | Key algorithm for the Kubernetes API server CSR. |
| `bootstrap_kubernetes_ca__ca_apiserver_csr_key_size` | `"2048"` | Key size for the Kubernetes API server CSR. |
| `bootstrap_kubernetes_ca__ca_apiserver_csr_names_c` | `"DE"` | Country (C) field in the Kubernetes API server CSR names. |
| `bootstrap_kubernetes_ca__ca_apiserver_csr_names_l` | `"The_Internet"` | Locality (L) field in the Kubernetes API server CSR names. |
| `bootstrap_kubernetes_ca__ca_apiserver_csr_names_o` | `"Kubernetes"` | Organization (O) field in the Kubernetes API server CSR names. |
| `bootstrap_kubernetes_ca__ca_apiserver_csr_names_ou` | `"BY"` | Organizational Unit (OU) field in the Kubernetes API server CSR names. |
| `bootstrap_kubernetes_ca__ca_apiserver_csr_names_st` | `"Bayern"` | State/Province (ST) field in the Kubernetes API server CSR names. |
| `bootstrap_kubernetes_ca__etcd_server_csr_cn` | `"etcd-server"` | Common Name (CN) for the etcd server CSR. |
| `bootstrap_kubernetes_ca__etcd_server_csr_key_algo` | `"rsa"` | Key algorithm for the etcd server CSR. |
| `bootstrap_kubernetes_ca__etcd_server_csr_key_size` | `"2048"` | Key size for the etcd server CSR. |
| `bootstrap_kubernetes_ca__etcd_server_csr_names_c` | `"DE"` | Country (C) field in the etcd server CSR names. |
| `bootstrap_kubernetes_ca__etcd_server_csr_names_l` | `"The_Internet"` | Locality (L) field in the etcd server CSR names. |
| `bootstrap_kubernetes_ca__etcd_server_csr_names_o` | `"Kubernetes"` | Organization (O) field in the etcd server CSR names. |
| `bootstrap_kubernetes_ca__etcd_server_csr_names_ou` | `"BY"` | Organizational Unit (OU) field in the etcd server CSR names. |
| `bootstrap_kubernetes_ca__etcd_server_csr_names_st` | `"Bayern"` | State/Province (ST) field in the etcd server CSR names. |

## Usage
To use this role, include it in your playbook and define the necessary variables as per your environment configuration.

Example Playbook:
```yaml
- name: Bootstrap Kubernetes CA
  hosts: localhost
  gather_facts: false
  roles:
    - role: bootstrap_kubernetes_ca
      vars:
        bootstrap_kubernetes_ca__use_existing_root_ca: true
        bootstrap_kubernetes_ca__root_ca_cert_path: "/path/to/your/root-ca.pem"
        bootstrap_kubernetes_ca__root_ca_key_path: "/path/to/your/root-ca-key.pem"
        bootstrap_kubernetes_ca__vault_url: "http://127.0.0.1:8200"
        bootstrap_kubernetes_ca__vault_token: "your-vault-token"
```

## Dependencies
- `community.dns`
- `community.hashi_vault`

Ensure these collections are installed in your Ansible environment:
```bash
ansible-galaxy collection install community.dns community.hashi_vault
```

## Tags
This role uses the following tags to allow selective execution of tasks:

| Tag | Description |
|-----|-------------|
| `ca` | Tasks related to CA generation and management. |
| `certificates` | Tasks related to certificate issuance for etcd and Kubernetes API server. |

Example usage with tags:
```bash
ansible-playbook -i inventory playbook.yml --tags "ca,certificates"
```

## Best Practices
- Always ensure that the root CA key is securely stored and backed up.
- Use strong, unique passwords and tokens for HashiCorp Vault.
- Regularly rotate certificates before they expire to maintain security.

## Molecule Tests
This role includes Molecule tests to verify its functionality. To run the tests:
```bash
molecule test
```

Ensure you have Molecule installed in your environment:
```bash
pip install molecule
```

## Backlinks
- [defaults/main.yml](../../roles/bootstrap_kubernetes_ca/defaults/main.yml)
- [tasks/main.new.yml](../../roles/bootstrap_kubernetes_ca/tasks/main.new.yml)
- [tasks/main.yml](../../roles/bootstrap_kubernetes_ca/tasks/main.yml)
- [meta/main.yml](../../roles/bootstrap_kubernetes_ca/meta/main.yml)

---

This documentation provides a comprehensive overview of the `bootstrap_kubernetes_ca` role, including its purpose, configuration options, usage instructions, dependencies, and best practices.