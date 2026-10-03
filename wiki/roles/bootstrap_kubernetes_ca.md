---
title: "Bootstrap Kubernetes CA Role"
role: bootstrap_kubernetes_ca
category: Kubernetes
type: Role
tags: [ansible, role, bootstrap_kubernetes_ca]
---

# Bootstrap Kubernetes CA Role

The `bootstrap_kubernetes_ca` role is designed to generate the necessary CA certificates for a Kubernetes cluster, including certificates for etcd and the Kubernetes API server. This role automates the process of creating and managing TLS certificates, ensuring secure communication within the cluster.

## Variables

The following table lists the variables that can be configured for this role:

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_kubernetes_ca__use_existing_root_ca` | `false` | Whether to use an existing root CA certificate and key. |
| `bootstrap_kubernetes_ca__root_ca_cert_path` | `/path/to/your/root-ca.pem` | Path to the existing root CA certificate. |
| `bootstrap_kubernetes_ca__root_ca_key_path` | `/path/to/your/root-ca-key.pem` | Path to the existing root CA key. |
| `bootstrap_kubernetes_ca__vault_url` | `http://127.0.0.1:8200` | URL of the HashiCorp Vault server. |
| `bootstrap_kubernetes_ca__vault_token` | `""` | Token for authenticating with HashiCorp Vault. |
| `bootstrap_kubernetes_ca__vault_kv_path` | `secret/kubernetes/ca` | Path in Vault where the CA certificates are stored. |
| `bootstrap_kubernetes_ca__ca_conf_directory` | `~/k8s/certs` | Directory where CA configuration files will be stored. |
| `bootstrap_kubernetes_ca__ca_conf_directory_perm` | `0770` | Permissions for the CA configuration directory. |
| `bootstrap_kubernetes_ca__ca_file_perm` | `0660` | Permissions for CA files. |
| `bootstrap_kubernetes_ca__ca_certificate_owner` | `root` | Owner of the CA certificate files. |
| `bootstrap_kubernetes_ca__ca_certificate_group` | `root` | Group of the CA certificate files. |
| `bootstrap_kubernetes_ca__ca_controller_nodes_group` | `kubernetes_controller` | Ansible group for Kubernetes controller nodes. |
| `bootstrap_kubernetes_ca__ca_etcd_nodes_group` | `kubernetes_etcd` | Ansible group for etcd nodes. |
| `bootstrap_kubernetes_ca__ca_worker_nodes_group` | `kubernetes_worker` | Ansible group for worker nodes. |
| `bootstrap_kubernetes_ca__offline_nodes_group` | `host_offline` | Ansible group for offline nodes. |
| `bootstrap_kubernetes_ca__interface` | `eth0` | Network interface to use for gathering IP addresses. |
| `bootstrap_kubernetes_ca__etcd_expiry` | `87600h` | Expiry time for etcd certificates. |
| `bootstrap_kubernetes_ca__ca_etcd_csr_cn` | `etcd` | Common Name for etcd CSR. |
| `bootstrap_kubernetes_ca__ca_etcd_csr_key_algo` | `rsa` | Key algorithm for etcd CSR. |
| `bootstrap_kubernetes_ca__ca_etcd_csr_key_size` | `2048` | Key size for etcd CSR. |
| `bootstrap_kubernetes_ca__ca_etcd_csr_names_c` | `DE` | Country for etcd CSR names. |
| `bootstrap_kubernetes_ca__ca_etcd_csr_names_l` | `The_Internet` | Locality for etcd CSR names. |
| `bootstrap_kubernetes_ca__ca_etcd_csr_names_o` | `Kubernetes` | Organization for etcd CSR names. |
| `bootstrap_kubernetes_ca__ca_etcd_csr_names_ou` | `BY` | Organizational Unit for etcd CSR names. |
| `bootstrap_kubernetes_ca__ca_etcd_csr_names_st` | `Bayern` | State for etcd CSR names. |
| `bootstrap_kubernetes_ca__ca_apiserver_expiry` | `87600h` | Expiry time for API server certificates. |
| `bootstrap_kubernetes_ca__ca_apiserver_csr_cn` | `Kubernetes` | Common Name for API server CSR. |
| `bootstrap_kubernetes_ca__ca_apiserver_csr_key_algo` | `rsa` | Key algorithm for API server CSR. |
| `bootstrap_kubernetes_ca__ca_apiserver_csr_key_size` | `2048` | Key size for API server CSR. |
| `bootstrap_kubernetes_ca__ca_apiserver_csr_names_c` | `DE` | Country for API server CSR names. |
| `bootstrap_kubernetes_ca__ca_apiserver_csr_names_l` | `The_Internet` | Locality for API server CSR names. |
| `bootstrap_kubernetes_ca__ca_apiserver_csr_names_o` | `Kubernetes` | Organization for API server CSR names. |
| `bootstrap_kubernetes_ca__ca_apiserver_csr_names_ou` | `BY` | Organizational Unit for API server CSR names. |
| `bootstrap_kubernetes_ca__ca_apiserver_csr_names_st` | `Bayern` | State for API server CSR names. |
| `bootstrap_kubernetes_ca__etcd_server_csr_cn` | `etcd-server` | Common Name for etcd server CSR. |
| `bootstrap_kubernetes_ca__etcd_server_csr_key_algo` | `rsa` | Key algorithm for etcd server CSR. |
| `bootstrap_kubernetes_ca__etcd_server_csr_key_size` | `2048` | Key size for etcd server CSR. |
| `bootstrap_kubernetes_ca__etcd_server_csr_names_c` | `DE` | Country for etcd server CSR names. |
| `bootstrap_kubernetes_ca__etcd_server_csr_names_l` | `The_Internet` | Locality for etcd server CSR names. |
| `bootstrap_kubernetes_ca__etcd_server_csr_names_o` | `Kubernetes` | Organization for etcd server CSR names. |
| `bootstrap_kubernetes_ca__etcd_server_csr_names_ou` | `BY` | Organizational Unit for etcd server CSR names. |
| `bootstrap_kubernetes_ca__etcd_server_csr_names_st` | `Bayern` | State for etcd server CSR names. |

## Usage

To use this role, include it in your playbook and configure the necessary variables:

```yaml
- hosts: kubernetes
  roles:
    - role: bootstrap_kubernetes_ca
      vars:
        bootstrap_kubernetes_ca__use_existing_root_ca: true
        bootstrap_kubernetes_ca__root_ca_cert_path: "/path/to/your/root-ca.pem"
        bootstrap_kubernetes_ca__root_ca_key_path: "/path/to/your/root-ca-key.pem"
```

## Dependencies

This role requires the following Ansible collections:

- `community.dns`
- `community.hashi_vault`

## Best Practices

- Ensure that the network interface specified in `bootstrap_kubernetes_ca__interface` is correct for your environment.
- Use a secure method for storing and managing your root CA certificate and key.
- Regularly rotate your certificates to maintain security.
- Keep your Ansible collections up to date to benefit from the latest features and security fixes.
- Test the role in a development environment before applying it to production.
- Document any customizations made to the role for future reference.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_kubernetes_ca/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_kubernetes_ca/tasks/main.yml)
- [meta/main.yml](../../roles/bootstrap_kubernetes_ca/meta/main.yml)

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributors

- Your Name (https://github.com/yourusername)

## Changelog

- 2023-01-01: Initial release
- 2023-02-01: Added support for Vault integration