---
title: "deploy_pki_certs Role Documentation"
role: deploy_pki_certs
category: Ansible Roles
type: PKI Management
tags: pki, tls, certificate, security

## Summary
The `deploy_pki_certs` role automates the deployment of certificates and integrates seamlessly with **Vault** for secure storage and dynamic issuance. This role streamlines the setup and maintenance of various certificate types, making it ideal for environments requiring a self-managed Certificate Authority (CA).

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `deploy_pki_certs__vault_url` | `"https://vault.example.int:8200"` | The URL of the Vault server. |
| `deploy_pki_certs__vault_token` | `""` | The token used to authenticate with Vault. **Sensitive**. |
| `deploy_pki_certs__vault_mount_path` | `"pki-intermediate"` | The mount path for the PKI secrets engine in Vault. |
| `deploy_pki_certs__vault_api_version` | `"v1"` | The API version of Vault to use. |
| `deploy_pki_certs__vault_kv_mount_path` | `"secret"` | The KV mount path in Vault where certificates are stored. |
| `deploy_pki_certs__vault_pki_service_route_role_name` | `"internal-service-route"` | The role name for service route certificates in Vault. |
| `deploy_pki_certs__vault_pki_signing_role_name` | `"internal-signing"` | The role name for signing certificates in Vault. |
| `deploy_pki_certs__vault_pki_host_role_name` | `"internal-host"` | The role name for host certificates in Vault. |
| `deploy_pki_certs__new_cert_verify_fail_fast` | `true` | Fail fast if new certificate verification fails. |
| `deploy_pki_certs__pki_signing_common_name_suffix` | `".sign"` | Suffix to append to signing common names. |
| `deploy_pki_certs__vault_pki_kv_types` | `[ "pki_service_route", "pki_signing", "pki_host" ]` | List of PKI types stored in Vault KV. |
| `deploy_pki_certs__enable_debug_mode` | `true` | Enable debug mode for detailed logging. |
| `deploy_pki_certs__ca_force_deploy` | `false` | Force deployment of CA certificates. |
| `deploy_pki_certs__ca_force_create` | `false` | Force creation of CA certificates. |
| `deploy_pki_certs__ca_reset_local_certs` | `false` | Reset local CA certificates and keys. |
| `deploy_pki_certs__ca_reset_trust_certs` | `false` | Reset trusted CA certificates. |
| `deploy_pki_certs__verify_fail_fast` | `true` | Fail fast if certificate verification fails. |
| `deploy_pki_certs__ca_root_cert_basename` | `"ca-root"` | Base name for the root CA certificate. |
| `deploy_pki_certs__ca_root_cn` | `"ca-root.example.int"` | Common Name (CN) for the root CA certificate. |
| `deploy_pki_certs__ca_host_cn` | `"{{ ansible_facts['fqdn'] }}"` | Common Name (CN) for host certificates, defaults to FQDN of the host. |
| `deploy_pki_certs__ca_placeholder_name` | `"placeholder"` | Placeholder name used in certificate generation. |
| `deploy_pki_certs__ca_cert_duration_root` | `"438000h"` | Duration (in hours) for root CA certificates (50 years). |
| `deploy_pki_certs__ca_cert_duration_intermediate` | `"87600h"` | Duration (in hours) for intermediate CA certificates (10 years). |
| `deploy_pki_certs__ca_cert_renewal_tolerance_days` | `30` | Tolerance in days before certificate renewal is triggered. |
| `deploy_pki_certs__certificate_ttl` | `"8760h"` | Time-to-live (TTL) for certificates (1 year). |
| `deploy_pki_certs__ca_signing_certs_list` | `[]` | List of signing certificates to deploy. |
| `deploy_pki_certs__ca_service_routes_list` | `[]` | List of service route certificates to deploy. |
| `deploy_pki_certs__validation_url` | `"{{ deploy_pki_certs__vault_url }}"` | URL for certificate validation, defaults to Vault URL. |
| `deploy_pki_certs__ca_cert_bundle` | `"/etc/pki/tls/certs/ca-bundle.crt"` | Path to the CA certificate bundle file. |
| `deploy_pki_certs__ca_cert_extension` | `"pem"` | File extension for CA certificates. |
| `deploy_pki_certs__validation_enabled` | `true` | Enable certificate validation. |
| `deploy_pki_certs__validation_fail_fast` | `false` | Fail fast if validation fails. |
| `deploy_pki_certs__validation_args` | `""` | Additional arguments for the validation script. |
| `deploy_pki_certs__pki_cert_key_type` | `"ec"` | Type of key to use for PKI certificates (e.g., ec, rsa). |
| `deploy_pki_certs__pki_cert_key_bits` | `256` | Number of bits for the PKI certificate key. |
| `deploy_pki_certs__pki_cert_ou` | `"Example Internal Unit"` | Organizational Unit (OU) for PKI certificates. |
| `deploy_pki_certs__pki_cert_org` | `"Example Org"` | Organization (O) for PKI certificates. |
| `deploy_pki_certs__vault_cert_configs` | `{ cert_basename: "example-vault-ca", csr_json_filename: "example-vault-ca-csr.json", common_name: "MyOrg Intermediate CA", key_type: "{{ deploy_pki_certs__pki_cert_key_type }}", key_size: "{{ deploy_pki_certs__pki_cert_key_bits }}" }` | Configuration for Vault certificates. |
| `deploy_pki_certs__local_cert_dir` | `"/usr/local/ssl/certs"` | Directory where local certificates are stored. |
| `deploy_pki_certs__local_key_dir` | `"/usr/local/ssl/private"` | Directory where local keys are stored. |
| `deploy_pki_certs__java_keystore_enabled` | `false` | Enable Java keystore updates with new certificates. |
| `deploy_pki_certs__trust_ca_cert_dir` | `"/usr/local/share/ca-certificates"` | Directory for trusted CA certificates. |
| `deploy_pki_certs__trust_ca_update_trust_cmd` | `"update-ca-certificates"` | Command to update the trust store with new CA certificates. |
| `deploy_pki_certs__java_keystore` | `"/etc/ssl/certs/java/cacerts"` | Path to the Java keystore file. |
| `deploy_pki_certs__java_keystore_pass` | `"changeit"` | Password for the Java keystore. |

## Usage
To use the `deploy_pki_certs` role, include it in your playbook and provide necessary variables as needed. Here is an example:

```yaml
- name: Deploy PKI Certificates
  hosts: all
  roles:
    - role: deploy_pki_certs
      vars:
        deploy_pki_certs__vault_token: "{{ vault_token }}"
        deploy_pki_certs__ca_signing_certs_list:
          - common_name: "example-signing-cert"
            type: "pki_signing"
```

## Dependencies
The `deploy_pki_certs` role depends on the following Ansible collections:

- `community.crypto`
- `community.hashi_vault`
- `dettonville.utils`

Ensure these collections are installed before running the role. You can install them using the following command:

```bash
ansible-galaxy collection install community.crypto community.hashi_vault dettonville.utils
```

## Best Practices
- **Security**: Ensure that sensitive variables like `deploy_pki_certs__vault_token` are stored securely, such as in Ansible Vault.
- **Backup**: Use the `deploy_pki_certs__ca_reset_local_certs` and `deploy_pki_certs__ca_reset_trust_certs` options with caution to avoid data loss. Always ensure backups are in place before resetting certificates.
- **Validation**: Enable validation (`deploy_pki_certs__validation_enabled`) to ensure that deployed certificates meet the required standards.

## Molecule Tests
This role includes Molecule tests to verify its functionality. To run the tests, navigate to the role directory and execute:

```bash
molecule test
```

Ensure you have Molecule installed along with any necessary dependencies for your testing environment.

## Backlinks
- [defaults/main.yml](../../roles/deploy_pki_certs/defaults/main.yml)
- [tasks/fetch_dynamic_cert.yml](../../roles/deploy_pki_certs/tasks/fetch_dynamic_cert.yml)
- [tasks/fetch_static_cert.yml](../../roles/deploy_pki_certs/tasks/fetch_static_cert.yml)
- [tasks/main.yml](../../roles/deploy_pki_certs/tasks/main.yml)
- [tasks/validate_pki_certs.yml](../../roles/deploy_pki_certs/tasks/validate_pki_certs.yml)
- [tasks/validate_vault_pki.yml](../../roles/deploy_pki_certs/tasks/validate_vault_pki.yml)
- [meta/main.yml](../../roles/deploy_pki_certs/meta/main.yml)
- [handlers/main.yml](../../roles/deploy_pki_certs/handlers/main.yml)