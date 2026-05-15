---
title: Bootstrap CA Certs Role Documentation
role: bootstrap_ca_certs
category: Security
type: Ansible Role
tags: tls, certificate, security, kubernetes
---

## Summary

The `bootstrap_ca_certs` role automates the generation of certificates and offers seamless integration with **Vault** for secure storage and dynamic issuance. This role streamlines the setup and maintenance of various certificate types, making it ideal for environments requiring a self-managed Certificate Authority (CA).

## Variables

| Variable Name                              | Default Value                                                                                         | Description                                                                                                                                                                                                 |
|--------------------------------------------|-------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_ca_certs__base_dir`             | `/etc/ansible/cacerts`                                                                                | Base directory for storing certificates and keys.                                                                                                                                                           |
| `bootstrap_ca_certs__ca_init`              | `"no"`                                                                                                | Initialize the Root CA if set to `"yes"`.                                                                                                                                                                   |
| `bootstrap_ca_certs__ca_certify_nodes`     | `"no"`                                                                                                | Certify nodes if set to `"yes"`.                                                                                                                                                                            |
| `bootstrap_ca_certs__ca_force_create`      | `"no"`                                                                                                | Force creation of the Root CA even if it already exists.                                                                                                                                                    |
| `bootstrap_ca_certs__ca_force_certify_nodes` | `"no"`                                                                                              | Force certification of nodes even if they are already certified.                                                                                                                                          |
| `bootstrap_ca_certs__clean_up`             | `"yes"`                                                                                               | Clean up temporary files after certificate generation.                                                                                                                                                      |
| `bootstrap_ca_certs__common_name`          | `"ca.example.com"`                                                                                    | Common Name (CN) for the Root CA.                                                                                                                                                                           |
| `bootstrap_ca_certs__country`              | `"US"`                                                                                                | Country code for the Root CA.                                                                                                                                                                               |
| `bootstrap_ca_certs__state`                | `"California"`                                                                                        | State or province for the Root CA.                                                                                                                                                                          |
| `bootstrap_ca_certs__locality`             | `"San Francisco"`                                                                                     | Locality (city) for the Root CA.                                                                                                                                                                            |
| `bootstrap_ca_certs__organization`         | `"Your Company"`                                                                                      | Organization name for the Root CA.                                                                                                                                                                          |
| `bootstrap_ca_certs__organizational_unit`  | `"IT"`                                                                                                | Organizational unit for the Root CA.                                                                                                                                                                        |
| `bootstrap_ca_certs__email`                | `"admin@example.com"`                                                                                 | Email address for the Root CA.                                                                                                                                                                              |
| `bootstrap_ca_certs__keystore_password`    | `"change_me_unsecure_password"`                                                                       | Password for the keystore (if applicable).                                                                                                                                                                  |
| `bootstrap_ca_certs__trusted_ca_path`      | `""`                                                                                                  | Path to a trusted CA certificate bundle.                                                                                                                                                                    |
| `bootstrap_ca_certs__ca_intermediate_certs_list` | `[]`                                                                                              | List of intermediate certificates configurations.                                                                                                                                                           |
| `bootstrap_ca_certs__ca_service_routes_list` | `[]`                                                                                              | List of service routes for which certificates need to be generated.                                                                                                                                       |
| `bootstrap_ca_certs__ca_certify_node_list` | `[]`                                                                                              | List of nodes that require certification.                                                                                                                                                                   |
| `bootstrap_ca_certs__cfssl_profile_root`   | `{ usages: ["signing", "key encipherment", "cert sign", "crl sign"], expiry: "438000h", ca_constraint: { is_ca: true, max_path_len: 5 } }` | CFSSL profile for the Root CA.                                                                                                                                                                            |
| `bootstrap_ca_certs__cfssl_profile_intermediate` | `{ usages: ["signing", "key encipherment", "cert sign", "crl sign"], expiry: "87600h", ca_constraint: { is_ca: true, max_path_len: 0 } }` | CFSSL profile for intermediate CAs.                                                                                                                                                                         |
| `bootstrap_ca_certs__cfssl_profile_server` | `{ usages: ["signing", "key encipherment", "server auth"], expiry: "8760h" }`                         | CFSSL profile for server certificates.                                                                                                                                                                      |
| `bootstrap_ca_certs__cfssl_profile_client` | `{ usages: ["signing", "key encipherment", "client auth"], expiry: "8760h" }`                         | CFSSL profile for client certificates.                                                                                                                                                                      |
| `bootstrap_ca_certs__vault_enabled`        | `false`                                                                                               | Enable integration with HashiCorp Vault for secure storage of certificates.                                                                                                                               |
| `bootstrap_ca_certs__vault_url`            | `"http://127.0.0.1:8200"`                                                                             | URL of the HashiCorp Vault server.                                                                                                                                                                          |
| `bootstrap_ca_certs__vault_token`          | `""`                                                                                                  | Token for authenticating with HashiCorp Vault.                                                                                                                                                              |
| `bootstrap_ca_certs__vault_kv_mount_point` | `"secret"`                                                                                            | Mount point for the KV secrets engine in HashiCorp Vault.                                                                                                                                                 |
| `bootstrap_ca_certs__vault_kv_path`        | `"secret/{{ bootstrap_ca_certs__common_name }}/certs"`                                                 | Path within the KV secrets engine to store certificates.                                                                                                                                                    |
| `bootstrap_ca_certs__vault_api_version`    | `"v1"`                                                                                                | API version of HashiCorp Vault.                                                                                                                                                                             |
| `bootstrap_ca_certs__key_algo`             | `rsa`                                                                                                 | Algorithm for generating keys (e.g., rsa, ecdsa).                                                                                                                                                         |
| `bootstrap_ca_certs__key_size`             | `2048`                                                                                                | Size of the generated key in bits.                                                                                                                                                                          |
| `bootstrap_ca_certs__ca_cert_expiration_panic_threshold` | `2592000`                                                                                   | Threshold (in seconds) before certificate expiration to trigger a panic or alert.                                                                                                                         |
| `bootstrap_ca_certs__display_ca_result`    | `true`                                                                                                | Display the result of CA operations in the Ansible output.                                                                                                                                                |

## Usage

To use this role, include it in your playbook and set the necessary variables as required. Here is an example playbook:

```yaml
---
- name: Bootstrap Certificate Authority Certificates
  hosts: all
  become: true
  roles:
    - role: bootstrap_ca_certs
      vars:
        bootstrap_ca_certs__ca_init: "yes"
        bootstrap_ca_certs__common_name: "my-ca.example.com"
        bootstrap_ca_certs__country: "US"
        bootstrap_ca_certs__state: "California"
        bootstrap_ca_certs__locality: "San Francisco"
        bootstrap_ca_certs__organization: "My Company"
        bootstrap_ca_certs__organizational_unit: "IT"
        bootstrap_ca_certs__email: "admin@mycompany.com"
        bootstrap_ca_certs__vault_enabled: true
        bootstrap_ca_certs__vault_url: "http://vault.mycompany.com:8200"
        bootstrap_ca_certs__vault_token: "{{ vault_token }}"
```

## Dependencies

- `bootstrap_cfssl` role (for installing CFSSL, cfssljson, and OpenSSL)
- `community.crypto` collection
- `community.hashi_vault` collection

Ensure these dependencies are installed before running the playbook:

```bash
ansible-galaxy install bootstrap_cfssl
ansible-galaxy collection install community.crypto community.hashi_vault
```

## Tags

This role uses tags to allow selective execution of tasks. The available tags are:

- `ca_init`: Tasks related to initializing the Root CA.
- `certify_nodes`: Tasks related to certifying nodes.

Example usage with tags:

```bash
ansible-playbook -t ca_init playbook.yml
```

## Best Practices

1. **Secure Passwords**: Ensure that passwords and tokens (e.g., `keystore_password`, `vault_token`) are stored securely, preferably using Ansible Vault.
2. **Regular Updates**: Regularly update the certificates before they expire to avoid service disruptions.
3. **Backup Certificates**: Maintain backups of all generated certificates and keys in a secure location.

## Molecule Tests

This role includes Molecule tests to verify its functionality. To run the tests, ensure you have Molecule installed:

```bash
pip install molecule
```

Then execute the tests using:

```bash
molecule test
```

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_ca_certs/defaults/main.yml)
- [tasks/create_cert.202508.yml](../../roles/bootstrap_ca_certs/tasks/create_cert.202508.yml)
- [tasks/create_cert.new.yml](../../roles/bootstrap_ca_certs/tasks/create_cert.new.yml)
- [tasks/main.yml](../../roles/bootstrap_ca_certs/tasks/main.yml)
- [tasks/validate_cert.new.yml](../../roles/bootstrap_ca_certs/tasks/validate_cert.new.yml)
- [tasks/validate_cert.orig.yml](../../roles/bootstrap_ca_certs/tasks/validate_cert.orig.yml)
- [tasks/create_cert.yml](../../roles/bootstrap_ca_certs/tasks/create_cert.yml)
- [tasks/validate_cert.yml](../../roles/bootstrap_ca_certs/tasks/validate_cert.yml)
- [meta/main.yml](../../roles/bootstrap_ca_certs/meta/main.yml)
- [handlers/main.yml](../../roles/bootstrap_ca_certs/handlers/main.yml)