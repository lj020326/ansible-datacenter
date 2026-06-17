---
title: "deploy_pki_certs Role Documentation"
role: deploy_pki_certs
category: Ansible Roles
type: Infrastructure as Code (IaC)
tags: pki, tls, certificate, security

## Summary
The `deploy_pki_certs` role automates the deployment of certificates and integrates seamlessly with **Vault** for secure storage and dynamic issuance. This role streamlines the setup and maintenance of various certificate types, making it ideal for environments requiring a self-managed Certificate Authority (CA).

## Variables

| Variable Name                                    | Default Value                                                                                       | Description                                                                                                                                                                                                 |
|--------------------------------------------------|-----------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `deploy_pki_certs__vault_url`                    | `"https://vault.example.int:8200"`                                                                  | The URL of the Vault server.                                                                                                                                                                                |
| `deploy_pki_certs__vault_token`                  | `""`                                                                                                | The token used to authenticate with Vault. It is recommended to use a variable or vault-encrypted value for this.                                                                                         |
| `deploy_pki_certs__vault_mount_path`             | `"pki-intermediate"`                                                                                | The mount path of the PKI secrets engine in Vault.                                                                                                                                                            |
| `deploy_pki_certs__vault_api_version`            | `"v1"`                                                                                            | The API version of Vault to use.                                                                                                                                                                            |
| `deploy_pki_certs__vault_kv_mount_path`          | `"secret"`                                                                                          | The mount path for the KV secrets engine in Vault.                                                                                                                                                            |
| `deploy_pki_certs__vault_pki_service_route_role_name` | `"internal-service-route"`                                                                         | The role name used for service route certificates in Vault.                                                                                                                                                 |
| `deploy_pki_certs__vault_pki_signing_role_name`  | `"internal-signing"`                                                                                | The role name used for signing certificates in Vault.                                                                                                                                                         |
| `deploy_pki_certs__vault_pki_host_role_name`     | `"internal-host"`                                                                                   | The role name used for host certificates in Vault.                                                                                                                                                            |
| `deploy_pki_certs__new_cert_verify_fail_fast`    | `true`                                                                                            | Whether to fail fast when verifying new certificates.                                                                                                                                                       |
| `deploy_pki_certs__pki_signing_common_name_suffix` | `".sign"`                                                                                           | The common name suffix for signing certificates.                                                                                                                                                              |
| `deploy_pki_certs__vault_pki_kv_types`           | `[ "pki_service_route", "pki_signing", "pki_host" ]`                                                | List of PKI types managed by the role.                                                                                                                                                                      |
| `deploy_pki_certs__enable_debug_mode`            | `true`                                                                                            | Enable debug mode for verbose logging.                                                                                                                                                                        |
| `deploy_pki_certs__ca_force_deploy`              | `false`                                                                                           | Force deployment of CA certificates even if they exist.                                                                                                                                                      |
| `deploy_pki_certs__ca_force_create`              | `false`                                                                                           | Force creation of new CA certificates.                                                                                                                                                                      |
| `deploy_pki_certs__ca_reset_local_certs`         | `false`                                                                                           | Reset local CA certificates by removing them.                                                                                                                                                               |
| `deploy_pki_certs__ca_reset_trust_certs`         | `false`                                                                                           | Reset trust certificates by removing them.                                                                                                                                                                  |
| `deploy_pki_certs__verify_fail_fast`             | `true`                                                                                            | Fail fast on certificate verification errors.                                                                                                                                                                 |
| `deploy_pki_certs__ca_root_cert_basename`        | `"ca-root"`                                                                                         | The base name for the root CA certificate.                                                                                                                                                                    |
| `deploy_pki_certs__ca_root_cn`                   | `"ca-root.example.int"`                                                                             | The common name for the root CA certificate.                                                                                                                                                                  |
| `deploy_pki_certs__ca_host_cn`                   | `"{{ ansible_facts['fqdn'] }}"`                                                                      | The common name for host certificates, defaults to the FQDN of the target host.                                                                                                                               |
| `deploy_pki_certs__ca_placeholder_name`          | `"placeholder"`                                                                                     | Placeholder name used in certificate generation.                                                                                                                                                              |
| `deploy_pki_certs__ca_cert_duration_root`        | `"438000h"` (50 years)                                                                              | The duration of the root CA certificate.                                                                                                                                                                      |
| `deploy_pki_certs__ca_cert_duration_intermediate`  | `"87600h"` (10 years)                                                                               | The duration of intermediate CA certificates.                                                                                                                                                                 |
| `deploy_pki_certs__ca_cert_renewal_tolerance_days` | `30`                                                                                              | The number of days before certificate renewal is considered necessary.                                                                                                                                        |
| `deploy_pki_certs__certificate_ttl`              | `"8760h"` (1 year)                                                                                  | The time-to-live for issued certificates.                                                                                                                                                                     |
| `deploy_pki_certs__ca_signing_certs_list`        | `[]`                                                                                                | List of signing certificates to manage.                                                                                                                                                                       |
| `deploy_pki_certs__ca_service_routes_list`       | `[]`                                                                                                | List of service route certificates to manage.                                                                                                                                                                 |
| `deploy_pki_certs__validation_url`               | `"{{ deploy_pki_certs__vault_url }}"`                                                                 | The URL used for certificate validation, defaults to the Vault URL.                                                                                                                                           |
| `deploy_pki_certs__ca_cert_bundle`               | `/etc/pki/tls/certs/ca-bundle.crt`                                                                    | Path to the CA certificate bundle file.                                                                                                                                                                       |
| `deploy_pki_certs__ca_cert_extension`            | `"pem"`                                                                                             | The file extension for CA certificates.                                                                                                                                                                     |
| `deploy_pki_certs__validation_enabled`           | `true`                                                                                            | Enable certificate validation.                                                                                                                                                                                |
| `deploy_pki_certs__validation_fail_fast`         | `false`                                                                                           | Fail fast on validation errors.                                                                                                                                                                               |
| `deploy_pki_certs__pki_cert_key_type`            | `"ec"`                                                                                            | The type of key for PKI certificates (e.g., `rsa`, `ec`).                                                                                                                                                   |
| `deploy_pki_certs__pki_cert_key_bits`            | `256`                                                                                             | The number of bits for the PKI certificate keys.                                                                                                                                                              |
| `deploy_pki_certs__pki_cert_ou`                  | `"Example Internal Unit"`                                                                           | Organizational unit for PKI certificates.                                                                                                                                                                     |
| `deploy_pki_certs__pki_cert_org`                 | `"Example Org"`                                                                                     | Organization name for PKI certificates.                                                                                                                                                                       |
| `deploy_pki_certs__vault_cert_configs`           | `{ cert_basename: "example-vault-ca", csr_json_filename: "example-vault-ca-csr.json", common_name: "MyOrg Intermediate CA", key_type: "{{ deploy_pki_certs__pki_cert_key_type }}", key_size: "{{ deploy_pki_certs__pki_cert_key_bits }}" }` | Configuration for Vault certificates.                                                                                                                                                                       |
| `deploy_pki_certs__local_cert_dir`               | `"/usr/local/ssl/certs"`                                                                            | Directory where local certificates are stored.                                                                                                                                                                |
| `deploy_pki_certs__local_key_dir`                | `"/usr/local/ssl/private"`                                                                          | Directory where local private keys are stored.                                                                                                                                                                |
| `deploy_pki_certs__java_keystore_enabled`        | `false`                                                                                           | Enable Java keystore management.                                                                                                                                                                              |
| `deploy_pki_certs__trust_ca_cert_dir`            | `/usr/local/share/ca-certificates`                                                                    | Directory where trusted CA certificates are stored.                                                                                                                                                           |
| `deploy_pki_certs__trust_ca_update_trust_cmd`    | `update-ca-certificates`                                                                            | Command to update the trust store.                                                                                                                                                                            |
| `deploy_pki_certs__java_keystore`                | `/etc/ssl/certs/java/cacerts`                                                                       | Path to the Java keystore file.                                                                                                                                                                               |
| `deploy_pki_certs__java_keystore_pass`           | `"changeit"`                                                                                        | Password for the Java keystore.                                                                                                                                                                               |

## Usage
To use this role, include it in your playbook and provide the necessary variables as shown below:

```yaml
- name: Deploy PKI Certificates
  hosts: all
  roles:
    - role: deploy_pki_certs
      vars:
        deploy_pki_certs__vault_url: "https://your-vault-url.com"
        deploy_pki_certs__vault_token: "{{ vault_token }}"
```

Ensure that the `deploy_pki_certs__vault_token` is securely managed, for example by using Ansible Vault.

## Dependencies
This role depends on the following Python libraries and modules:

- `python-hcl2`
- `requests`
- `truststore`
- `hvac`
- `pycurl`
- `pyopenssl`
- `cryptography`

These dependencies are installed automatically as part of the role execution.

## Best Practices
- **Security**: Always use a secure method to manage and store Vault tokens. Avoid hardcoding sensitive information in playbooks.
- **Backup**: Enable backup options (`deploy_pki_certs__ca_reset_local_certs`) when resetting certificates to prevent data loss.
- **Validation**: Regularly validate certificates using the provided validation scripts to ensure they are valid and trusted.

## Molecule Tests
This role includes Molecule tests to verify its functionality. To run the tests, navigate to the role directory and execute:

```bash
molecule test
```

Ensure that you have Molecule installed and configured on your system before running the tests.

## Backlinks

- [defaults/main.yml](../../roles/deploy_pki_certs/defaults/main.yml)
- [tasks/fetch_dynamic_cert.yml](../../roles/deploy_pki_certs/tasks/fetch_dynamic_cert.yml)
- [tasks/fetch_static_cert.yml](../../roles/deploy_pki_certs/tasks/fetch_static_cert.yml)
- [tasks/main.yml](../../roles/deploy_pki_certs/tasks/main.yml)
- [tasks/validate_pki_certs.yml](../../roles/deploy_pki_certs/tasks/validate_pki_certs.yml)
- [tasks/validate_vault_pki.yml](../../roles/deploy_pki_certs/tasks/validate_vault_pki.yml)
- [meta/main.yml](../../roles/deploy_pki_certs/meta/main.yml)
- [handlers/main.yml](../../roles/deploy_pki_certs/handlers/main.yml)