---
title: Bootstrap PKI Role
role: bootstrap_pki
category: Security
type: Role Documentation
tags: [ansible, role, bootstrap_pki]
---

# Bootstrap PKI Role

The `bootstrap_pki` role is designed to bootstrap a two-tier public key infrastructure (PKI) with a self-signed root certificate authority (CA) and an intermediate CA. This role utilizes `cfssl` for certificate management and integrates with HashiCorp Vault to store and manage the intermediate CA. The role ensures idempotence and automation in setting up the PKI infrastructure.

## Table of Contents

- [Variables](#variables)
- [Usage](#usage)
- [Dependencies](#dependencies)
- [Best Practices](#best-practices)
- [References](#references)

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `bootstrap_pki__vault_url` | `"https://vault.example.int"` | The URL of the Vault server. |
| `bootstrap_pki__vault_token` | `""` | The Vault token to authenticate API requests. |
| `bootstrap_pki__vault_verify_token_capabilities` | `{}` | Dictionary to verify token capabilities. |
| `bootstrap_pki__vault_api_version` | `"v1"` | The API version of the Vault server. |
| `bootstrap_pki__vault_kv_mount_point` | `"secret"` | The mount point for the KV secrets engine in Vault. |
| `bootstrap_pki__vault_mount_path` | `"pki-intermediate"` | The mount path for the PKI engine in Vault. |
| `bootstrap_pki__vault_ca_root_path` | `{{ bootstrap_pki__vault_mount_path }}/root` | The path to the root CA in Vault. |
| `bootstrap_pki__vault_ensure_admin_token` | `false` | Whether to ensure an admin token exists in Vault. |
| `bootstrap_pki__ca_placeholder_name` | `"placeholder"` | Placeholder name for CA certificates. |
| `bootstrap_pki__ca_cert_duration_root` | `"438000h"` | Duration of the root CA certificate (50 years). |
| `bootstrap_pki__ca_cert_duration_intermediate` | `"87600h"` | Duration of the intermediate CA certificate (10 years). |
| `bootstrap_pki__ca_cert_duration_server` | `"87600h"` | Duration of the server certificates (10 years). |
| `bootstrap_pki__ca_cert_duration_client` | `"87600h"` | Duration of the client certificates (10 years). |
| `bootstrap_pki__ca_cert_duration_default` | `"87600h"` | Default duration for certificates (10 years). |
| `bootstrap_pki__ca_root_cert_info` | `{}` | Dictionary containing information about the root CA certificate. |
| `bootstrap_pki__root_ca_crl_expiry` | `"8760h"` | Expiry duration for the root CA CRL (1 year). |
| `bootstrap_pki__ca_dir` | `"/etc/pki/cacerts"` | Directory to store CA certificates. |
| `bootstrap_pki__ca_reset_cert` | `false` | Whether to reset the CA certificate. |
| `bootstrap_pki__ca_reset_trusted_kv_external` | `false` | Whether to reset the trusted KV external. |
| `bootstrap_pki__ca_reset_trusted_kv_internal` | `false` | Whether to reset the trusted KV internal. |
| `bootstrap_pki__validation_enabled` | `true` | Whether to enable validation of PKI certificates. |
| `bootstrap_pki__validation_fail_fast` | `false` | Whether to fail fast during validation. |
| `bootstrap_pki__validation_args` | `""` | Additional arguments for validation. |
| `bootstrap_pki__backup_retention_maximum_number` | `20` | Maximum number of backups to retain. |
| `bootstrap_pki__encrypt_root_ca_key` | `false` | Whether to encrypt the root CA key. |
| `bootstrap_pki__encrypted_root_ca_key_path` | `{{ bootstrap_pki__ca_dir }}/{{ bootstrap_pki__ca_root_cert_info.cert_basename }}-key.pem.vault` | Path to the encrypted root CA key. |
| `bootstrap_pki__vault_password` | `""` | Password for encrypting the root CA key. |
| `bootstrap_pki__initialize_trusted_internal` | `true` | Whether to initialize the trusted internal KV path. |
| `bootstrap_pki__admin_token_display_name` | `"admin_user_token"` | Display name for the admin token. |
| `bootstrap_pki__admin_token_policies` | `["admin"]` | Policies assigned to the admin token. |
| `bootstrap_pki__admin_token_ttl` | `"87600h"` | Time-to-live for the admin token (10 years). |
| `bootstrap_pki__vault_cert_configs` | `{}` | Dictionary containing configuration for Vault certificates. |

## Usage

To use the `bootstrap_pki` role, include it in your playbook as follows:

```yaml
- hosts: all
  roles:
    - role: bootstrap_pki
      vars:
        bootstrap_pki__vault_url: "https://your-vault-server.com"
        bootstrap_pki__vault_token: "your-vault-token"
        bootstrap_pki__vault_kv_mount_point: "your-kv-mount-point"
        bootstrap_pki__vault_mount_path: "your-pki-mount-path"
```

## Dependencies

The `bootstrap_pki` role has the following dependencies:

- `cfssl` and `cfssljson` must be installed on the target system.
- The `community.hashi_vault` collection must be installed for Ansible.

You can install the required dependencies using the following commands:

```bash
# Install cfssl and cfssljson
sudo apt-get install cfssl cfssljson

# Install the community.hashi_vault collection
ansible-galaxy collection install community.hashi_vault

# Verify installations
cfssl version
cfssljson version
ansible-galaxy collection list | grep community.hashi_vault
```

## Best Practices

- Ensure that the Vault server is properly configured and unsealed before running the role.
- Use a secure method to store and manage the Vault token.
- Regularly back up the CA certificates and keys.
- Monitor the expiration dates of the certificates and renew them as needed.
- Implement monitoring and alerting for certificate expiration.
- Regularly audit access to the PKI infrastructure.
- Limit access to the PKI infrastructure to only trusted administrators.
- Use separate environments for development, testing, and production.

## References

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
- [handlers/main.yml](../../roles/bootstrap_pki/handlers/main.yml)