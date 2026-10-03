---
title: deploy_pki_certs Ansible Role
harvested_date: '2023-10-07T18:07:09.514023+00:00'
category: Ansible
tags:
  - Certificates
  - HashiCorp Vault
  - OpenBao
  - PKI
  - Security
---

# `deploy_pki_certs` Ansible Role

The `deploy_pki_certs` Ansible role is a comprehensive solution for managing and deploying PKI certificates from a **HashiCorp Vault** or **OpenBao** instance to target hosts. This role automates the entire certificate lifecycle, from initial deployment to validation and renewal, ensuring a secure and self-healing infrastructure.

## Table of Contents
- [Features](#features)
- [Requirements](#requirements)
- [Role Variables](#role-variables)
- [Usage Examples](#usage-examples)
- [Default Behavior](#default-behavior)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## Features

- **Static Certificates**: Pre-existing x509 certificates fetched from Vault PKI CA endpoint (`/ca/pem`) or KV paths (e.g., root CA, external CAs, trusted internal certificates).
- **Dynamic Certificates**: On-the-fly issuance for hosts/service routes via Vault PKI (`/issue/`), with caching for idempotency.
- **OS Support**: Debian/Ubuntu (default) and RedHat/CentOS (via OS-specific vars).
- **Idempotent Deploys**: Using SHA256 fingerprint comparisons (avoids unnecessary KV version bumps or file overwrites).
- **Local Validation**: With [`x509_certificate_verify`](https://github.com/dettonville/ansible-utils/blob/main/docs/readme.x509_certificate_verify.md) (expiry, CN, key match, signature chain, is_ca).
- **Host OS Trust Store Updates**: (`update-ca-certificates` or `update-ca-trust`).
- **Optional Java Keystore Integration**.
- **PKI CA Live Checks**: With local certificate fingerprint vs. Vault KV (`/ca/pem` for the vault PKI certificate).
- **Pre/Post-Deploy SSL Validation Script**.

The role is split into focused tasks files for maintainability:

- `fetch_static_cert.yml`: Handles static fetches ('pki_ca', 'kv').
- `fetch_dynamic_cert.yml`: Handles dynamic issuance ('pki_service_route', 'pki_host').

## Requirements

- Ansible 2.10+ (uses `community.crypto`, `community.hashi_vault` collections).
- Vault server with:
  - PKI mount (e.g., `pki-intermediate`) and role (e.g., `internal-api`).
  - KV v2 mount (e.g., `secret`) for trusted cert storage.
  - Token with `read`/`list`/`write`/`delete` on relevant paths (e.g., `trusted_internal` for dynamic certificate storage).
- Target hosts: Debian/Ubuntu or RedHat/CentOS (trust store cmds auto-detected).
- Python dependencies: `requests`, `hvac`, `python-hcl2` (installed via role).

## Role Variables

| Variable                                           | Default                        | Description                                                                                                       |
|----------------------------------------------------|--------------------------------|------------------------------------------------------------------------------------------------------------------|
| `deploy_pki_certs__vault_url`                      | `https://vault.example.int:8200` | **(Required)** The URL of the Vault server.                                                                       |
| `deploy_pki_certs__vault_token`                    | None                           | **(Required)** The authentication token for Vault. **This should be stored securely in Ansible Vault.**           |
| `deploy_pki_certs__vault_mount_path`               | `pki-intermediate`             | **(Required)** The mount path of the PKI secrets engine used for issuing certificates (e.g., `pki-intermediate`). |
| `deploy_pki_certs__vault_kv_mount_path`            | `kv/pki`                       | **(Required)** The mount path of the KV secrets engine used for storing certificates.                              |

## Usage Examples

### Basic Usage
```yaml
- hosts: all
  roles:
    - role: deploy_pki_certs
      vars:
        deploy_pki_certs__vault_url: "https://vault.example.int:8200"
        deploy_pki_certs__vault_token: "your-vault-token"
        deploy_pki_certs__vault_mount_path: "pki-intermediate"
        deploy_pki_certs__vault_kv_mount_path: "kv/pki"
```

### Custom Configuration
```yaml
- hosts: all
  roles:
    - role: deploy_pki_certs
      vars:
        deploy_pki_certs__vault_url: "https://vault.example.int:8200"
        deploy_pki_certs__vault_token: "your-vault-token"
        deploy_pki_certs__vault_mount_path: "pki-custom"
        deploy_pki_certs__vault_kv_mount_path: "kv/custom"
```

## Default Behavior

The role by default:
- Uses Debian/Ubuntu commands for trust store updates
- Performs idempotent certificate deployments using SHA256 fingerprint comparisons
- Validates certificates locally before deployment
- Updates the host OS trust store with new CA certificates
- Runs validation scripts pre and post-deployment

## Troubleshooting

- Ensure Vault server is accessible from the Ansible control node
- Verify Vault token has the necessary permissions
- Check Python dependencies are installed
- Review Ansible logs for specific error messages

## Contributing

Contributions are welcome! Please submit pull requests or open issues for any bugs or feature requests.