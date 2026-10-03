---
title: "Deploy PKI Certs Role"
role: "deploy_pki_certs"
category: "Security"
type: "Role Documentation"
tags: [ansible, role, deploy_pki_certs]
---

```yaml
---
# Documentation for deploy_pki_certs Ansible Role

---
title: "Deploy PKI Certs Role"
role: "deploy_pki_certs"
category: "Security"
type: "Role Documentation"
---

## Overview

The `deploy_pki_certs` Ansible role automates the deployment of certificates and integrates seamlessly with **Vault** for secure storage and dynamic issuance. This role streamlines the setup and maintenance of various certificate types, making it ideal for environments requiring a self-managed Certificate Authority (CA).

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `deploy_pki_certs__vault_url` | `"https://vault.example.int:8200"` | URL of the Vault server |
| `deploy_pki_certs__vault_token` | `""` | Token for Vault authentication |
| `deploy_pki_certs__vault_mount_path` | `"pki-intermediate"` | Mount path for PKI secrets engine in Vault |
| `deploy_pki_certs__vault_api_version` | `"v1"` | API version for Vault |
| `deploy_pki_certs__vault_kv_mount_path` | `"secret"` | Mount path for KV secrets engine in Vault |
| `deploy_pki_certs__vault_pki_service_route_role_name` | `"internal-service-route"` | Role name for service route in Vault PKI |
| `deploy_pki_certs__vault_pki_signing_role_name` | `"internal-signing"` | Role name for signing in Vault PKI |
| `deploy_pki_certs__vault_pki_host_role_name` | `"internal-host"` | Role name for host in Vault PKI |
| `deploy_pki_certs__new_cert_verify_fail_fast` | `true` | Fail fast when verifying new certificates |
| `deploy_pki_certs__pki_signing_common_name_suffix` | `".sign"` | Common name suffix for PKI signing |
| `deploy_pki_certs__vault_pki_kv_types` | `["pki_service_route", "pki_signing", "pki_host"]` | List of PKI KV types |
| `__deploy_pki_certs__vault_pki_type_to_role_mappings` | `{"pki_service_route": "{{ deploy_pki_certs__vault_pki_service_route_role_name }}", "pki_signing": "{{ deploy_pki_certs__vault_pki_signing_role_name }}", "pki_host": "{{ deploy_pki_certs__vault_pki_host_role_name }}"}` | Mapping of PKI types to role names |
| `__deploy_pki_certs__validation_pip_libs` | `["requests", "truststore"]` | Python libraries required for validation |
| `deploy_pki_certs__enable_debug_mode` | `true` | Enable debug mode |
| `deploy_pki_certs__ca_force_deploy` | `false` | Force deployment of CA certificates |
| `deploy_pki_certs__ca_force_create` | `false` | Force creation of CA certificates |
| `deploy_pki_certs__ca_reset_local_certs` | `false` | Reset local CA certificates |
| `deploy_pki_certs__ca_reset_trust_certs` | `false` | Reset trust CA certificates |
| `deploy_pki_certs__verify_fail_fast` | `true` | Fail fast when verifying certificates |
| `deploy_pki_certs__ca_root_cert_basename` | `"ca-root"` | Basename for CA root certificate |
| `deploy_pki_certs__ca_root_cn` | `"ca-root.example.int"` | Common name for CA root |
| `deploy_pki_certs__ca_host_cn` | `{{ ansible_facts['fqdn'] }}` | Common name for CA host |
| `deploy_pki_certs__ca_placeholder_name` | `"placeholder"` | Placeholder name for CA |
| `deploy_pki_certs__ca_cert_duration_root` | `"438000h"` | Duration for CA root certificate (50 years) |
| `deploy_pki_certs__ca_cert_duration_intermediate` | `"87600h"` | Duration for CA intermediate certificate (10 years) |
| `deploy_pki_certs__ca_cert_renewal_tolerance_days` | `30` | Tolerance days for CA certificate renewal |
| `__deploy_pki_certs__tolerance_seconds` | `{{ deploy_pki_certs__ca_cert_renewal_tolerance_days | int * 86400 }}` | Tolerance seconds for CA certificate renewal |
| `__deploy_pki_certs__ca_root_cert_name_default` | `{{ deploy_pki_certs__ca_root_cert_basename }}.{{ deploy_pki_certs__ca_cert_extension }}` | Default name for CA root certificate |
| `__deploy_pki_certs__ca_root_cert_name` | `{{ deploy_pki_certs__ca_root_cert_name | d(__deploy_pki_certs__ca_root_cert_name_default) }}` | Name for CA root certificate |
| `deploy_pki_certs__certificate_ttl` | `"8760h"` | Time-to-live for certificates (1 year) |
| `deploy_pki_certs__ca_signing_certs_list` | `[]` | List of CA signing certificates |
| `deploy_pki_certs__ca_service_routes_list` | `[]` | List of CA service routes |
| `deploy_pki_certs__validation_url` | `{{ deploy_pki_certs__vault_url }}` | URL for validation |
| `__deploy_pki_certs__ca_cert_bundle_default` | `/etc/pki/tls/certs/ca-bundle.crt` | Default path for CA certificate bundle |
| `__deploy_pki_certs__ca_cert_bundle` | `{{ deploy_pki_certs__ca_cert_bundle | d(__deploy_pki_certs__ca_cert_bundle_default) }}` | Path for CA certificate bundle |
| `deploy_pki_certs__ca_cert_extension` | `"pem"` | Extension for CA certificates |
| `__deploy_pki_certs__trust_cert_extension` | `{{ deploy_pki_certs__trust_cert_extension | d(__deploy_pki_certs__trust_cert_extension_default) }}` | Extension for trust certificates |
| `deploy_pki_certs__validation_enabled` | `true` | Enable validation |
| `deploy_pki_certs__validation_fail_fast` | `false` | Fail fast when validating |
| `deploy_pki_certs__validation_args` | `""` | Arguments for validation |
| `deploy_pki_certs__pki_cert_key_type` | `"ec"` | Type of key for PKI certificates |
| `deploy_pki_certs__pki_cert_key_bits` | `256` | Size of key for PKI certificates |
| `deploy_pki_certs__pki_cert_ou` | `"Example Internal Unit"` | Organizational unit for PKI certificates |
| `deploy_pki_certs__pki_cert_org` | `"Example Org"` | Organization for PKI certificates |
| `deploy_pki_certs__vault_cert_configs` | `{"cert_basename": "example-vault-ca", "csr_json_filename": "example-vault-ca-csr.json", "common_name": "MyOrg Intermediate CA", "key_type": "{{ deploy_pki_certs__pki_cert_key_type }}", "key_size": "{{ deploy_pki_certs__pki_cert_key_bits }}"} ` | Configuration for Vault certificates |
| `__deploy_pki_certs__vault_cert_name_default` | `{{ deploy_pki_certs__vault_cert_configs.cert_base
...
---