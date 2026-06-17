---
title: Bootstrap PKI Role Documentation
role: bootstrap_pki
category: Security
type: Ansible Role
tags: pki, tls, certificate, security

## Summary
The `bootstrap_pki` role is designed to automate the setup of a two-tier Public Key Infrastructure (PKI) with a self-signed root Certificate Authority (CA) and an intermediate CA. It integrates with HashiCorp Vault for secure storage and management of the intermediate CA certificates. The role uses `cfssl` for certificate generation and management, ensuring idempotency and ease of use.

## Variables

| Variable Name                                  | Default Value                                                                                     | Description                                                                                                                                                                                                 |
|------------------------------------------------|---------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_pki__vault_url`                   | `"https://vault.example.int"`                                                                     | URL to the Vault server.                                                                                                                                                                                    |
| `bootstrap_pki__vault_token`                 | `""`                                                                                                | Token for authenticating with Vault. Must be provided if `bootstrap_pki__encrypt_root_ca_key` is true.                                                                                                    |
| `bootstrap_pki__vault_verify_token_capabilities` | `{}`                                                                                              | Dictionary to verify token capabilities.                                                                                                                                                                  |
| `bootstrap_pki__vault_api_version`             | `"v1"`                                                                                            | API version of the Vault server.                                                                                                                                                                            |
| `bootstrap_pki__vault_kv_mount_point`          | `"secret"`                                                                                        | Mount point for KV secrets in Vault.                                                                                                                                                                        |
| `bootstrap_pki__vault_mount_path`              | `"pki-intermediate"`                                                                              | Path to the PKI engine mount in Vault.                                                                                                                                                                      |
| `bootstrap_pki__vault_ca_root_path`            | `"{{ bootstrap_pki__vault_mount_path }}/root"`                                                      | Path to the root CA in Vault.                                                                                                                                                                               |
| `bootstrap_pki__vault_ensure_admin_token`      | `false`                                                                                           | Whether to ensure an admin token exists and is configured.                                                                                                                                                |
| `bootstrap_pki__ca_placeholder_name`           | `"placeholder"`                                                                                   | Placeholder name for the CA.                                                                                                                                                                                |
| `bootstrap_pki__ca_cert_duration_root`         | `"438000h"` (50 years)                                                                            | Duration of the root CA certificate.                                                                                                                                                                        |
| `bootstrap_pki__ca_cert_duration_intermediate` | `"87600h"` (10 years)                                                                             | Duration of the intermediate CA certificate.                                                                                                                                                                |
| `bootstrap_pki__ca_cert_duration_server`       | `"87600h"` (10 years)                                                                             | Default duration for server certificates.                                                                                                                                                                   |
| `bootstrap_pki__ca_cert_duration_client`       | `"87600h"` (10 years)                                                                             | Default duration for client certificates.                                                                                                                                                                   |
| `bootstrap_pki__ca_cert_duration_default`      | `"87600h"` (10 years)                                                                             | Default duration for other types of certificates.                                                                                                                                                           |
| `bootstrap_pki__ca_root_cert_info`             | `{ cert_basename: "ca", common_name: "MyOrg Root CA", country: "", state: "", locality: "", organization: "", organizational_unit: "", email_address: "", key_type: "rsa", key_size: 4096, renewal_tolerance_days: 30 }` | Configuration details for the root CA certificate.                                                                                                                                                        |
| `bootstrap_pki__root_ca_crl_expiry`            | `"8760h"` (1 year)                                                                                | Expiry duration for the CRL of the root CA.                                                                                                                                                                 |
| `bootstrap_pki__ca_dir`                        | `"/etc/pki/cacerts"`                                                                              | Directory where CA certificates and keys are stored locally.                                                                                                                                                |
| `bootstrap_pki__ca_reset_cert`                 | `false`                                                                                           | Whether to reset the CA certificate.                                                                                                                                                                        |
| `bootstrap_pki__ca_reset_trusted_kv_external`  | `false`                                                                                           | Whether to reset trusted external KV path in Vault.                                                                                                                                                         |
| `bootstrap_pki__ca_reset_trusted_kv_internal`  | `false`                                                                                           | Whether to reset trusted internal KV path in Vault.                                                                                                                                                         |
| `bootstrap_pki__validation_enabled`            | `true`                                                                                            | Enable certificate validation.                                                                                                                                                                              |
| `bootstrap_pki__validation_fail_fast`          | `false`                                                                                           | Fail fast on validation errors.                                                                                                                                                                             |
| `bootstrap_pki__validation_args`               | `""`                                                                                              | Additional arguments for the validation script.                                                                                                                                                             |
| `bootstrap_pki__backup_retention_maximum_number` | `20`                                                                                             | Maximum number of backups to retain.                                                                                                                                                                        |
| `bootstrap_pki__encrypt_root_ca_key`           | `false`                                                                                           | Whether to encrypt the root CA key using Ansible Vault.                                                                                                                                                     |
| `bootstrap_pki__encrypted_root_ca_key_path`    | `"{{ bootstrap_pki__ca_dir }}/{{ bootstrap_pki__ca_root_cert_info.cert_basename }}-key.pem.vault"` | Path where the encrypted root CA key will be stored.                                                                                                                                                    |
| `bootstrap_pki__vault_password`                | `""`                                                                                                | Password for Ansible Vault encryption. Must be provided if `bootstrap_pki__encrypt_root_ca_key` is true.                                                                                                  |
| `bootstrap_pki__initialize_trusted_internal`   | `true`                                                                                            | Whether to initialize the trusted internal KV path in Vault.                                                                                                                                              |
| `bootstrap_pki__admin_token_display_name`      | `"admin_user_token"`                                                                              | Display name for the admin token.                                                                                                                                                                           |
| `bootstrap_pki__admin_token_policies`          | `["admin"]`                                                                                       | Policies associated with the admin token.                                                                                                                                                                   |
| `bootstrap_pki__admin_token_ttl`               | `"87600h"` (10 years)                                                                             | TTL for the admin token.                                                                                                                                                                                    |
| `bootstrap_pki__vault_cert_configs`            | `{ cert_basename: "example-vault-ca", csr_json_filename: "example-vault-ca-csr.json", common_name: "MyOrg Intermediate CA", country: "", state: "", locality: "", organization: "", organizational_unit: "", email_address: "", key_type: "ecdsa", key_size: 256, ca_signing_profile: intermediate_ca, ca_issuer_path: "{{ bootstrap_pki__ca_dir }}/" }` | Configuration details for the Vault CA certificate.                                                                                                                                                    |

## Usage
To use this role, include it in your playbook and provide necessary variables such as `bootstrap_pki__vault_url`, `bootstrap_pki__vault_token`, and other configuration options as needed. Ensure that the Vault server is accessible and properly configured.

### Example Playbook
```yaml
- name: Bootstrap PKI Infrastructure
  hosts: all
  roles:
    - role: bootstrap_pki
      vars:
        bootstrap_pki__vault_url: "https://vault.example.int"
        bootstrap_pki__vault_token: "{{ vault_token }}"
        bootstrap_pki__ca_root_cert_info:
          cert_basename: "myorg-root-ca"
          common_name: "MyOrg Root CA"
          country: "US"
          state: "California"
          locality: "San Francisco"
          organization: "My Organization"
          organizational_unit: "IT"
          email_address: "it@example.com"
```

## Dependencies
- `community.hashi_vault` collection for interacting with Vault.
- `community.crypto` collection for fetching certificates from hosts.
- OpenSSL and CFSSL must be installed on the target hosts.

### Installation of Collections
```bash
ansible-galaxy collection install community.hashi_vault
ansible-galaxy collection install community.crypto
```

## Best Practices
1. **Secure Vault Token**: Ensure that the Vault token used has the necessary permissions and is kept secure.
2. **Backup Configuration**: Regularly back up your PKI configuration and certificates to prevent data loss.
3. **Validation**: Enable certificate validation to ensure the integrity of your PKI setup.

## Molecule Tests
This role includes Molecule tests for verifying its functionality. To run the tests, navigate to the role directory and execute:
```bash
molecule test
```

## Backlinks
- [defaults/main.yml](../../roles/bootstrap_pki/defaults/main.yml)
- [tasks/encrypt_root_ca_key.yml](../../roles/bootstrap_pki/tasks/encrypt_root_ca_key.yml)
- [tasks/ensure_admin_token.yml](../../roles/bootstrap_pki/tasks/ensure_admin_token.yml)
- [tasks/ensure_ca_cert.yml](../../roles/bootstrap_pki/tasks/ensure_ca_cert.yml)
- [tasks/ensure_dependencies.yml](../../roles/bootstrap_pki/tasks/ensure_dependencies.yml)
- [tasks/ensure_deploy_token_policy.yml](../../roles/bootstrap_pki/tasks/ensure_deploy_token_policy.yml)
- [tasks/ensure_external_ca_cert.yml](../../roles/bootstrap_pki/tasks/ensure_external_ca_cert.yml)
- [tasks/ensure_trusted_external.yml](../../roles/bootstrap_pki/tasks/ensure_trusted_external.yml)
- [tasks/ensure_trusted_internal.yml](../../roles/bootstrap_pki/tasks/ensure_trusted_internal.yml)
- [tasks/ensure_vault_pki_engine.yml](../../roles/bootstrap_pki/tasks/ensure_vault_pki_engine.yml)
- [tasks/ensure_vault_pki_roles.yml](../../roles/bootstrap_pki/tasks/ensure_vault_pki_roles.yml)
- [tasks/main.yml](../../roles/bootstrap_pki/tasks/main.yml)
- [tasks/validate_pki_certs.yml](../../roles/bootstrap_pki/tasks/validate_pki_certs.yml)
- [tasks/validate_vault_pki.yml](../../roles/bootstrap_pki/tasks/validate_vault_pki.yml)
- [meta/main.yml](../../roles/bootstrap_pki/meta/main.yml)