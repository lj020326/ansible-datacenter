---
title: "bootstrap_pki Ansible Role"
role: bootstrap_pki
category: Security
type: Infrastructure Automation
tags: pki, tls, certificate, security

## Summary

The `bootstrap_pki` role is designed to automate the setup of a two-tier Public Key Infrastructure (PKI) system. It generates a self-signed root Certificate Authority (CA) and an intermediate CA, leveraging `cfssl` for certificate management and HashiCorp Vault for secure storage and management of certificates. This role ensures idempotency and robustness in PKI bootstrapping.

## Variables

| Variable Name                             | Default Value                                                                 | Description                                                                                                                                                                                                 |
|---------------------------------------------|-------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_pki__vault_url`                | `"https://vault.example.int"`                                               | The URL of the HashiCorp Vault server.                                                                                                                                                                      |
| `bootstrap_pki__vault_token`              | `""`                                                                          | The token used to authenticate with Vault. Must be provided if `bootstrap_pki__encrypt_root_ca_key` is true.                                                                                              |
| `bootstrap_pki__vault_verify_token_capabilities` | `{}`                                                                       | A dictionary to verify specific capabilities of the Vault token.                                                                                                                                            |
| `bootstrap_pki__vault_api_version`        | `"v1"`                                                                        | The API version of HashiCorp Vault.                                                                                                                                                                         |
| `bootstrap_pki__vault_kv_mount_point`     | `"secret"`                                                                    | The KV mount point in Vault where certificates will be stored.                                                                                                                                            |
| `bootstrap_pki__vault_mount_path`         | `"pki-intermediate"`                                                          | The path under which the PKI engine is mounted in Vault.                                                                                                                                                  |
| `bootstrap_pki__vault_ca_root_path`       | `"{{ bootstrap_pki__vault_mount_path }}/root"`                                | The path to the root CA in Vault.                                                                                                                                                                           |
| `bootstrap_pki__vault_ensure_admin_token` | `false`                                                                       | Whether to ensure an admin token exists in Vault.                                                                                                                                                           |
| `bootstrap_pki__ca_placeholder_name`      | `"placeholder"`                                                               | A placeholder name for the CA.                                                                                                                                                                              |
| `bootstrap_pki__ca_cert_duration_root`    | `"438000h"`                                                                   | The duration of the root CA certificate (50 years).                                                                                                                                                         |
| `bootstrap_pki__ca_cert_duration_intermediate` | `"87600h"`                                                                 | The duration of the intermediate CA certificate (10 years).                                                                                                                                                |
| `bootstrap_pki__ca_cert_duration_server`  | `"87600h"`                                                                    | The default duration for server certificates (10 years).                                                                                                                                                  |
| `bootstrap_pki__ca_cert_duration_client`  | `"87600h"`                                                                    | The default duration for client certificates (10 years).                                                                                                                                                  |
| `bootstrap_pki__ca_cert_duration_default` | `"87600h"`                                                                    | The default duration for other types of certificates (10 years).                                                                                                                                            |
| `bootstrap_pki__ca_root_cert_info`        | `{ cert_basename: "ca", common_name: "MyOrg Root CA", country: "", state: "", locality: "", organization: "", organizational_unit: "", email_address: "", key_type: "rsa", key_size: 4096, renewal_tolerance_days: 30 }` | Information about the root CA certificate.                                                                                                                                                                |
| `__bootstrap_pki__root_cert_basename_default` | `"{{ bootstrap_pki__ca_root_cert_info.cert_basename \| d('ca-root') }}"`   | Default basename for the root certificate if not specified in `bootstrap_pki__ca_root_cert_info`.                                                                                                       |
| `__bootstrap_pki__root_cert_basename`     | `"{{ bootstrap_pki__root_cert_basename \| d(__bootstrap_pki__root_cert_basename_default) }}"` | Basename for the root certificate.                                                                                                                                                                          |
| `bootstrap_pki__root_ca_crl_expiry`       | `"8760h"`                                                                     | The expiry duration of the CRL (1 year).                                                                                                                                                                    |
| `bootstrap_pki__ca_dir`                   | `"/etc/pki/cacerts"`                                                          | Directory where CA certificates and keys are stored.                                                                                                                                                      |
| `bootstrap_pki__ca_reset_cert`            | `false`                                                                       | Whether to reset existing certificates.                                                                                                                                                                     |
| `bootstrap_pki__ca_reset_trusted_kv_external` | `false`                                                                    | Whether to reset trusted external KV contents in Vault.                                                                                                                                                   |
| `bootstrap_pki__ca_reset_trusted_kv_internal` | `false`                                                                    | Whether to reset trusted internal KV contents in Vault.                                                                                                                                                   |
| `bootstrap_pki__validation_enabled`       | `true`                                                                        | Whether to enable certificate validation.                                                                                                                                                                   |
| `bootstrap_pki__validation_fail_fast`     | `false`                                                                       | Whether to fail immediately on validation errors.                                                                                                                                                           |
| `bootstrap_pki__validation_args`          | `""`                                                                          | Additional arguments for the validation script.                                                                                                                                                             |
| `bootstrap_pki__backup_retention_maximum_number` | `20`                                                                      | Maximum number of backups to retain.                                                                                                                                                                        |
| `bootstrap_pki__encrypt_root_ca_key`      | `false`                                                                       | Whether to encrypt the root CA key using Ansible Vault.                                                                                                                                                    |
| `bootstrap_pki__encrypted_root_ca_key_path` | `"{{ bootstrap_pki__ca_dir }}/{{ bootstrap_pki__ca_root_cert_info.cert_basename }}-key.pem.vault"` | Path where the encrypted root CA key will be stored.                                                                                                                                                      |
| `bootstrap_pki__vault_password`           | `""`                                                                          | Password for Ansible Vault encryption. Must be provided if `bootstrap_pki__encrypt_root_ca_key` is true.                                                                                              |
| `bootstrap_pki__initialize_trusted_internal` | `true`                                                                      | Whether to initialize the trusted internal KV path in Vault.                                                                                                                                              |
| `bootstrap_pki__admin_token_display_name` | `"admin_user_token"`                                                          | Display name for the admin token in Vault.                                                                                                                                                                  |
| `bootstrap_pki__admin_token_policies`     | `["admin"]`                                                                   | Policies associated with the admin token in Vault.                                                                                                                                                        |
| `bootstrap_pki__admin_token_ttl`          | `"87600h"`                                                                    | TTL for the admin token (10 years).                                                                                                                                                                         |
| `bootstrap_pki__vault_cert_configs`       | `{ cert_basename: "example-vault-ca", csr_json_filename: "example-vault-ca-csr.json", common_name: "MyOrg Intermediate CA", country: "", state: "", locality: "", organization: "", organizational_unit: "", email_address: "", key_type: "ecdsa", key_size: 256, ca_signing_profile: intermediate_ca, ca_issuer_path: "{{ bootstrap_pki__ca_dir }}/" }` | Configuration for the Vault intermediate CA certificate.                                                                                                                                                |

## Usage

To use the `bootstrap_pki` role, include it in your playbook and provide necessary variables as shown below:

```yaml
- hosts: all
  roles:
    - role: bootstrap_pki
      vars:
        bootstrap_pki__vault_url: "https://vault.example.int"
        bootstrap_pki__vault_token: "{{ vault_token }}"
        bootstrap_pki__ca_root_cert_info:
          cert_basename: "myorg-root-ca"
          common_name: "My Organization Root CA"
          country: "US"
          state: "California"
          locality: "San Francisco"
          organization: "My Organization"
          organizational_unit: "IT"
          email_address: "it@example.com"
          key_type: "rsa"
          key_size: 4096
```

## Dependencies

The `bootstrap_pki` role depends on the following collections:

- `community.crypto`
- `community.hashi_vault`
- `dettonville.utils`

Ensure these collections are installed in your Ansible environment.

```bash
ansible-galaxy collection install community.crypto community.hashi_vault dettonville.utils
```

## Best Practices

1. **Secure Vault Token**: Ensure that the Vault token provided has sufficient permissions and is kept secure.
2. **Encryption**: Enable encryption for sensitive keys using `bootstrap_pki__encrypt_root_ca_key` and provide a strong password via `bootstrap_pki__vault_password`.
3. **Validation**: Regularly validate certificates to ensure they are up-to-date and valid.

## Molecule Tests

This role includes Molecule tests to verify its functionality. To run the tests, navigate to the role directory and execute:

```bash
molecule test
```

Ensure that you have the necessary dependencies installed for Molecule testing.

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