```markdown
---
title: Ansible Role for Bootstrapping PKI
original_path: roles/bootstrap_pki/README.md
category: Ansible Roles
tags: [pki, ansible, cfssl, vault]
---

# Ansible Role: `bootstrap_pki`

An Ansible role to bootstrap a two-tier public key infrastructure (PKI) with a self-signed root certificate authority (CA) created externally and an intermediate CA, which is signed by the root CA and imported into Vault to serve as the root of a PKI secrets engine. This role utilizes `cfssl` for certificate management and integrates with Vault for certificate issuance.

## 🚀 Features

- **Idempotent:** The role checks for existing certificates and only creates or updates them if they are missing or invalid.
- **External Root CA:** The root CA can be generated externally using `cfssl` and remains offline; the role supports generation on-target if needed (with offline key export recommended).
- **Root CA Key Encryption:** The root CA key can be encrypted using Ansible Vault with a role-defined password to enhance security on the target host.
- **Admin Token Management:** Automatically creates an admin token with the "admin" policy if it doesn't exist, using the root token for setup.
- **Intermediate CA Management:** The intermediate CA is generated externally, signed by the root CA, and imported into Vault as the PKI secrets engine root.
- **Highly Configurable:** All certificate and key parameters (common names, key algorithms, key sizes, etc.) are defined via Ansible variables.
- **Vault Integration:** The intermediate CA certificate and key are imported into a Vault/OpenBao PKI secrets engine for certificate issuance.
- **Robust Validation:** Includes comprehensive validation checks to ensure:
  - Certificates are not expired.
  - Common names, key types, and key sizes match the configuration.
  - The intermediate CA's signature is valid and signed by the root CA.
  - The Vault PKI engine's intermediate CA certificate matches the local certificate.
- **Standardized Naming:** All certificate and key files use a configurable `cert_basename` for consistent file naming.

### External CA Integration

The role now supports fetching and storing external CA certificates (e.g., public roots like Let's Encrypt) in `secret/trusted_external` for use by downstream roles like `deploy_pki_certs`.

- **Configuration:** Override `bootstrap_pki__external_cas` with a list of sources (URL, command, or local file).
- **Example:**
  ```yaml
  bootstrap_pki__external_cas:
    - name: "custom-ca"
      fetch_method: "url"
      url: "https://ca.corp.com/root.pem"
  ```

## 🛠️ Requirements

- **Ansible:** Version 2.10 or newer.
- **Python Libraries:** The `hvac` and `cryptography` libraries must be installed on the Ansible control node.
  ```shell
  pip install hvac cryptography
  ```
- **CFSSL:** The `cfssl` and `cfssljson` binaries must be available on the target host (e.g., `control01`).
- **Ansible Vault:** The `ansible-vault` command must be available on the target host if `bootstrap_pki__encrypt_root_ca_key` is enabled.
- **Vault:** Tested with Vault 1.12+ and OpenBao 2.0+. Ensure the `pki` secrets engine is available and the "admin" policy exists.
- **Custom Module (Optional):** The `dettonville.utils.x509_certificate_verify` module is used for enhanced certificate validation. If unavailable, the role falls back to `community.crypto.x509_certificate_info` for basic validation.
- **Vault Server:** An accessible Vault/OpenBao server with:
  - A `pki` secrets engine mounted at `pki-intermediate`.
  - A valid root token or a token with `sudo` permissions on the `sys/mounts` and `pki-intermediate` paths.

## ⚙️ Role Variables

The following variables can be configured in your playbook or `vars` files.

| Variable Name                                    | Default Value                       | Description                                                                                                                                   |
|--------------------------------------------------|-------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_pki__vault_url`                       | `https://vault.example.int`         | The URL of the Vault server.                                                                                                                  |
| `bootstrap_pki__vault_token`                     | `""`                                | The authentication token for Vault (typically root token for bootstrap).                                                                      |
| `bootstrap_pki__vault_mount_path`                | `pki-intermediate`                  | The path in Vault where the PKI secrets engine is mounted.                                                                                    |
| `bootstrap_pki__vault_roles`                     | see defaults                        | A list of dicts with role configuration parameters like `allowed_domains`, `allow_subdomains`.              |
| `bootstrap_pki__ca_dir`                          | `/etc/pki/cacerts`                  | The directory on the target host to store the certificate files.                                                                              |
| `bootstrap_pki__ca_reset_cert`                   | `false`                             | If `true`, forces regeneration of CA certificates even if they exist.                                                                         |
| `bootstrap_pki__backup_retention_maximum_number` | `10`                                | Maximum number of CA backup files to retain (e.g., `ca.backup_*.tar.gz`).                                                                     |
| `bootstrap_pki__encrypt_root_ca_key`             | `false`                             | If `true`, encrypts the root CA key using Ansible Vault after generation.         |

## 🔗 Backlinks

- [Ansible Roles Documentation](/ansible-roles)
- [PKI Management with Ansible](/pki-management)

```

This improved Markdown document includes a standardized YAML frontmatter, clear structure with proper headings, and a "Backlinks" section for better navigation and context.