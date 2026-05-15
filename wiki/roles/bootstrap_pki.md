---
title: "Ansible Role Documentation"
role: bootstrap_pki
category: Security
type: Infrastructure as Code
tags: pki, tls, certificate, security

## Summary

The `bootstrap_pki` Ansible role is designed to automate the setup of a two-tier Public Key Infrastructure (PKI) system. It generates a self-signed Root Certificate Authority (CA) and an Intermediate CA, leveraging `cfssl` for certificate management and integrating with HashiCorp Vault for secure storage and management of the intermediate CA certificates. This role ensures idempotency and provides robust validation mechanisms to ensure the integrity and correctness of the PKI setup.

## Variables

| Variable Name                                      | Default Value                                                                                             | Description                                                                                                                                                                                                 |
|----------------------------------------------------|-----------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_pki__vault_url`                         | `"https://vault.example.int"`                                                                           | The URL for the Vault server.                                                                                                                                                                               |
| `bootstrap_pki__vault_token`                       | `""`                                                                                                        | The token used to authenticate with Vault.                                                                                                                                                                  |
| `bootstrap_pki__vault_verify_token_capabilities`   | `{}`                                                                                                          | A dictionary to verify specific capabilities of the provided Vault token.                                                                                                                                   |
| `bootstrap_pki__vault_api_version`                 | `"v1"`                                                                                                      | The API version of the Vault server.                                                                                                                                                                        |
| `bootstrap_pki__vault_kv_mount_point`              | `"secret"`                                                                                                  | The KV mount point in Vault where certificates will be stored.                                                                                                                                            |
| `bootstrap_pki__vault_mount_path`                  | `"pki-intermediate"`                                                                                        | The path under which the PKI engine is mounted in Vault.                                                                                                                                                  |
| `bootstrap_pki__vault_ca_root_path`                | `"{{ bootstrap_pki__vault_mount_path }}/root"`                                                              | The path for the root CA within the Vault mount.                                                                                                                                                          |
| `bootstrap_pki__vault_ensure_admin_token`          | `false`                                                                                                     | Whether to ensure an admin token is created and managed by this role.                                                                                                                                     |
| `bootstrap_pki__ca_placeholder_name`               | `"placeholder"`                                                                                             | A placeholder name for CA certificates.                                                                                                                                                                   |
| `bootstrap_pki__ca_cert_duration_root`             | `"438000h"` (50 years)                                                                                      | The duration of the root CA certificate.                                                                                                                                                                  |
| `bootstrap_pki__ca_cert_duration_intermediate`     | `"87600h"` (10 years)                                                                                       | The duration of the intermediate CA certificate.                                                                                                                                                          |
| `bootstrap_pki__ca_cert_duration_server`           | `"87600h"` (10 years)                                                                                       | The default duration for server certificates issued by the PKI engine.                                                                                                                                    |
| `bootstrap_pki__ca_cert_duration_client`           | `"87600h"` (10 years)                                                                                       | The default duration for client certificates issued by the PKI engine.                                                                                                                                    |
| `bootstrap_pki__ca_cert_duration_default`          | `"87600h"` (10 years)                                                                                       | The default certificate duration used when not specified otherwise.                                                                                                                                         |
| `bootstrap_pki__ca_root_cert_info`                 | `{ cert_basename: "ca", common_name: "MyOrg Root CA", country: "", state: "", locality: "", organization: "", organizational_unit: "", email_address: "", key_type: "rsa", key_size: 4096, renewal_tolerance_days: 30 }` | Configuration details for the root CA certificate.                                                                                                                                                    |
| `__bootstrap_pki__root_cert_basename_default`      | `"{{ bootstrap_pki__ca_root_cert_info.cert_basename \| d('ca-root') }}"`                                      | Default basename for the root CA certificate if not specified in `bootstrap_pki__ca_root_cert_info`.                                                                                                    |
| `__bootstrap_pki__root_cert_basename`              | `"{{ bootstrap_pki__root_cert_basename \| d(__bootstrap_pki__root_cert_basename_default) }}"`                | The final basename used for the root CA certificate.                                                                                                                                                      |
| `bootstrap_pki__root_ca_crl_expiry`                | `"8760h"` (1 year)                                                                                          | The expiry duration of the CRL for the root CA.                                                                                                                                                           |
| `bootstrap_pki__ca_dir`                            | `"/etc/pki/cacerts"`                                                                                        | Directory where CA certificates and keys will be stored locally.                                                                                                                                          |
| `bootstrap_pki__ca_reset_cert`                     | `false`                                                                                                     | Whether to reset existing CA certificates during the run.                                                                                                                                                 |
| `bootstrap_pki__ca_reset_trusted_kv_external`      | `false`                                                                                                     | Whether to reset trusted external KV contents in Vault.                                                                                                                                                   |
| `bootstrap_pki__ca_reset_trusted_kv_internal`      | `false`                                                                                                     | Whether to reset trusted internal KV contents in Vault.                                                                                                                                                   |
| `bootstrap_pki__validation_enabled`                | `true`                                                                                                      | Enable validation of PKI certificates after setup.                                                                                                                                                        |
| `bootstrap_pki__validation_fail_fast`              | `false`                                                                                                     | Fail immediately if any certificate validation fails.                                                                                                                                                     |
| `bootstrap_pki__validation_args`                   | `""`                                                                                                        | Additional arguments to pass to the validation script.                                                                                                                                                  |
| `bootstrap_pki__backup_retention_maximum_number`   | `20`                                                                                                        | Maximum number of backups to retain.                                                                                                                                                                      |
| `bootstrap_pki__encrypt_root_ca_key`               | `false`                                                                                                     | Whether to encrypt the root CA key using Ansible Vault.                                                                                                                                                   |
| `bootstrap_pki__encrypted_root_ca_key_path`        | `"{{ bootstrap_pki__ca_dir }}/{{ bootstrap_pki__ca_root_cert_info.cert_basename }}-key.pem.vault"`            | Path where the encrypted root CA key will be stored.                                                                                                                                                    |
| `bootstrap_pki__vault_password`                    | `""`                                                                                                        | Password used for Ansible Vault encryption if enabled.                                                                                                                                                  |
| `bootstrap_pki__initialize_trusted_internal`       | `true`                                                                                                      | Whether to initialize trusted internal KV path in Vault.                                                                                                                                                |
| `bootstrap_pki__admin_token_display_name`          | `"admin_user_token"`                                                                                        | Display name for the admin token created by this role.                                                                                                                                                  |
| `bootstrap_pki__admin_token_policies`              | `["admin"]`                                                                                                 | Policies assigned to the admin token.                                                                                                                                                                     |
| `bootstrap_pki__admin_token_ttl`                   | `"87600h"` (10 years)                                                                                       | Time-to-live for the admin token.                                                                                                                                                                         |
| `bootstrap_pki__vault_cert_configs`                | `{ cert_basename: "example-vault-ca", csr_json_filename: "example-vault-ca-csr.json", common_name: "MyOrg Intermediate CA", country: "", state: "", locality: "", organization: "", organizational_unit: "", email_address: "", key_type: "ecdsa", key_size: 256, ca_signing_profile: intermediate_ca, ca_issuer_path: "{{ bootstrap_pki__ca_dir }}/" }` | Configuration details for the Vault intermediate CA certificate.                                                                                                                                        |

## Usage

To use the `bootstrap_pki` role in your Ansible playbook, include it as follows:

```yaml
- name: Bootstrap PKI Infrastructure
  hosts: all
  become: true
  roles:
    - role: bootstrap_pki
      vars:
        bootstrap_pki__vault_url: "https://your-vault-url"
        bootstrap_pki__vault_token: "{{ vault_token }}"
```

Ensure that the `bootstrap_pki__vault_url` and `bootstrap_pki__vault_token` variables are correctly set to point to your Vault server and provide a valid token with appropriate permissions.

## Dependencies

The role depends on the following collections:

- `community.crypto`
- `community.hashi_vault`
- `dettonville.utils`

Additionally, it requires the installation of OpenSSL and CFSSL on the target hosts. The role includes tasks to ensure these dependencies are met.

## Best Practices

1. **Token Management**: Ensure that the Vault token used by this role has sufficient permissions to manage PKI engines and tokens.
2. **Encryption**: Enable encryption for the root CA key using Ansible Vault if sensitive information is a concern.
3. **Validation**: Regularly validate certificates to ensure they are valid and have not expired.

## Molecule Tests

This role includes Molecule tests to verify its functionality. To run the tests, navigate to the role directory and execute:

```bash
molecule test
```

Ensure that all dependencies and required tools are installed before running the tests.

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