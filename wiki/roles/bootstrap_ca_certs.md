---
title: Bootstrap CA Certs Role
role: bootstrap_ca_certs
category: Security
type: Role
tags: [ansible, role, bootstrap_ca_certs]
---

# Bootstrap CA Certs Role

The `bootstrap_ca_certs` role automates the generation and management of certificates, offering seamless integration with **Vault** for secure storage and dynamic issuance. This role streamlines the setup and maintenance of various certificate types, making it ideal for environments requiring a self-managed Certificate Authority (CA).

## Table of Contents

- [Variables](#variables)
- [Usage](#usage)
- [Dependencies](#dependencies)
- [Best Practices](#best-practices)

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_ca_certs__base_dir` | `/etc/ansible/cacerts` | Base directory for storing certificates. |
| `bootstrap_ca_certs__ca_init` | `no` | Flag to initialize CA. |
| `bootstrap_ca_certs__ca_certify_nodes` | `no` | Flag to certify nodes. |
| `bootstrap_ca_certs__ca_force_create` | `no` | Force creation of CA. |
| `bootstrap_ca_certs__ca_force_certify_nodes` | `no` | Force certification of nodes. |
| `bootstrap_ca_certs__clean_up` | `yes` | Clean up old certificates. |
| `bootstrap_ca_certs__common_name` | `your-root-ca.example.com` | Common name for the CA. |
| `bootstrap_ca_certs__country` | `US` | Country for the CA. |
| `bootstrap_ca_certs__state` | `California` | State for the CA. |
| `bootstrap_ca_certs__locality` | `San Francisco` | Locality for the CA. |
| `bootstrap_ca_certs__organization` | `Your Company` | Organization for the CA. |
| `bootstrap_ca_certs__organizational_unit` | `IT` | Organizational unit for the CA. |
| `bootstrap_ca_certs__email` | `admin@example.com` | Email for the CA. |
| `bootstrap_ca_certs__keystore_password` | `change_me_unsecure_password` | Password for the keystore. |
| `bootstrap_ca_certs__trusted_ca_path` | `""` | Path to trusted CA certificates. |
| `bootstrap_ca_certs__ca_intermediate_certs_list` | `[]` | List of intermediate CA certificates. |
| `bootstrap_ca_certs__ca_service_routes_list` | `[]` | List of service routes for CA. |
| `bootstrap_ca_certs__ca_certify_node_list` | `[]` | List of nodes to certify. |
| `bootstrap_ca_certs__cfssl_profile_root` | `{"usages": ["signing", "key encipherment", "cert sign", "crl sign"], "expiry": "438000h", "ca_constraint": {"is_ca": true, "max_path_len": 1}}` | CFSSL profile for root CA. |
| `bootstrap_ca_certs__cfssl_profile_intermediate` | `{"usages": ["signing", "key encipherment", "cert sign", "crl sign"], "expiry": "87600h", "ca_constraint": {"is_ca": true, "max_path_len": 0}}` | CFSSL profile for intermediate CA. |
| `bootstrap_ca_certs__cfssl_profile_server` | `{"usages": ["signing", "key encipherment", "server auth"], "expiry": "8760h"}` | CFSSL profile for server certificates. |
| `bootstrap_ca_certs__cfssl_profile_client` | `{"usages": ["signing", "key encipherment", "client auth"], "expiry": "8760h"}` | CFSSL profile for client certificates. |
| `bootstrap_ca_certs__vault_enabled` | `false` | Enable Vault integration. |
| `bootstrap_ca_certs__vault_url` | `http://127.0.0.1:8200` | Vault URL. |
| `bootstrap_ca_certs__vault_token` | `""` | Vault token. |
| `bootstrap_ca_certs__vault_kv_mount_point` | `secret` | Vault KV mount point. |
| `bootstrap_ca_certs__vault_kv_path` | `secret/{{ bootstrap_ca_certs__common_name | d('default-ca') }}/certs` | Vault KV path. |
| `bootstrap_ca_certs__vault_api_version` | `v1` | Vault API version. |
| `bootstrap_ca_certs__ca_cert_expiration_panic_threshold` | `2592000` | Threshold for certificate expiration panic. |
| `bootstrap_ca_certs__display_ca_result` | `true` | Display CA result. |

## Usage

To use this role, include it in your playbook and set the necessary variables:

```yaml
- hosts: all
  roles:
    - role: bootstrap_ca_certs
      vars:
        bootstrap_ca_certs__common_name: "my-ca.example.com"
        bootstrap_ca_certs__country: "US"
        bootstrap_ca_certs__state: "California"
        bootstrap_ca_certs__locality: "San Francisco"
        bootstrap_ca_certs__organization: "My Company"
        bootstrap_ca_certs__organizational_unit: "IT"
        bootstrap_ca_certs__email: "admin@my-company.com"
        bootstrap_ca_certs__keystore_password: "secure_password"
        bootstrap_ca_certs__vault_enabled: true
        bootstrap_ca_certs__vault_url: "https://vault.example.com"
        bootstrap_ca_certs__vault_token: "your-vault-token"
```

## Dependencies

This role depends on the `bootstrap_cfssl` role to ensure CFSSL, cfssljson, and OpenSSL are installed. To install the dependent role, you can add it to your playbook like this:

```yaml
- hosts: all
  roles:
    - role: bootstrap_cfssl
```

## Best Practices

- Always use secure passwords for keystores.
- Regularly rotate certificates to maintain security.
- Enable Vault integration for secure storage and dynamic issuance of certificates.
- Test the role in a development environment before deploying to production.
- Monitor certificate expiration dates and set up alerts for upcoming expirations.
- Keep the role and its dependencies up to date with the latest security patches.