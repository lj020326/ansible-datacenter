```markdown
---
title: deploy_pki_certs Ansible Role Documentation
original_path: roles/deploy_pki_certs/README.md
category: Ansible Roles
tags: [ansible, pki, certificates, hashicorp-vault, openbao]
---

# `deploy_pki_certs` Ansible Role

The `deploy_pki_certs` Ansible role is a comprehensive solution for managing and deploying PKI certificates from a **HashCorp Vault** or **OpenBao** instance to target hosts. This role automates the entire certificate host certificate lifecycle, from initial deployment to validation and renewal, ensuring a secure and self-healing infrastructure.

## Supported Features

- **Static Certificates**: Pre-existing x509 certificates fetched from Vault PKI CA endpoint (`/ca/pem`) or KV paths (e.g., root CA, external CAs, trusted internal certificates).
- **Dynamic Certificates**: On-the-fly issuance for hosts/service routes via Vault PKI (`/issue/`), with caching for idempotency.
- **OS Support**: Debian/Ubuntu (default) and RedHat/CentOS (via OS-specific vars).

### Key Features

- **Idempotent Deploys**: Uses SHA256 fingerprint comparisons to avoid unnecessary KV version bumps or file overwrites.
- **Local Validation**: Utilizes [`x509_certificate_verify`](https://github.com/dettonville/ansible-utils/blob/main/docs/readme.x509_certificate_verify.md) for expiry, CN, key match, signature chain, and is_ca checks.
- **Host OS Trust Store Updates**: Automatically updates the trust store using `update-ca-certificates` or `update-ca-trust`.
- **Optional Java Keystore Integration**.
- **PKI CA Live Checks**: Compares local certificate fingerprints with Vault KV (`/ca/pem` for the vault PKI certificate).
- **Pre/Post-Deploy SSL Validation Script**.

## Role Structure

The role is organized into focused task files for maintainability:

- `fetch_static_cert.yml`: Handles static fetches ('pki_ca', 'kv').
- `fetch_dynamic_cert.yml`: Handles dynamic issuance ('pki_service_route', 'pki_host').

## Tiered PKI Lifecycle Management

- **Internal Certificates**: Validates local files, checks Vault KV cache for existing valid cert/key pairs, and issues new pairs from the PKI engine if necessary.
- **Persistent Key Caching**: Automatically caches generated keys in a secure KV path to allow retrieval during host rebuilds or multi-node deployments.
- **Unified Multi-Use Case Handling**: A single DRY (Don't Repeat Yourself) workflow handles Intermediate CAs, Service Route certificates, Host Identity certificates, and External CA certificates.
- **Atomic Validation**: Uses the [`dettonville.utils.x509_certificate_verify`](https://github.com/dettonville/ansible-utils/blob/main/docs/readme.x509_certificate_verify.md) module to perform cryptographic matching between certificates and private keys before and after deployment.
- **Secure and Automated Renewal**: Designed to run on the Ansible control node to prevent exposing sensitive Vault tokens on target hosts.
- **Centralized Issuance**: All certificates are dynamically issued by the Vault PKI secrets engine, serving as a single source of truth.
- **Zero-Touch Deployment**: Automatically fetches the CA trust chain, generates a new private key and CSR for the host, retrieves a signed certificate, and deploys them without manual intervention.
- **Intelligent Validation**: Checks for existing certificates and their validity using the [`dettonville.utils.x509_certificate_verify`](https://github.com/dettonville/ansible-utils/blob/main/docs/readme.x509_certificate_verify.md) module. If a certificate is missing or invalid, it automatically requests and deploys a new one.
- **Automated and Secure Renewal**: Executed periodically on the Ansible control node (via systemd timer or cron job), securely triggering the renewal process without exposing sensitive Vault tokens on target hosts.
- **OS-Agnostic Trust Store Management**: Automatically determines the correct system trust store location and update command based on the target host's operating system and updates it with new CA certificates.
- **Validation Testing**: Deploys and executes a Python script on the host to verify SSL/TLS connections and the entire trust chain.

## Requirements

- **Ansible Version**: 2.10+ (uses `community.crypto`, `community.hashi_vault` collections).
- **Vault Server**:
  - PKI mount (e.g., `pki-intermediate`) and role (e.g., `internal-api`).
  - KV v2 mount (e.g., `secret`) for trusted cert storage.
  - Token with `read`, `list`, `write`, `delete` permissions on relevant paths (e.g., `trusted_internal` for dynamic certificate storage).
- **Target Hosts**: Debian/Ubuntu or RedHat/CentOS (trust store commands auto-detected).
- **Python Dependencies**: `requests`, `hvac`, `python-hcl2` (installed via role).

## Role Variables

| Variable                                           | Default                          | Description                                                                                                       |
|:---------------------------------------------------|:---------------------------------|:------------------------------------------------------------------------------------------------------------------|
| `deploy_pki_certs__vault_url`                      | `https://vault.example.int:8200` | **(Required)** The URL of the Vault server.                                                                       |
| `deploy_pki_certs__vault_token`                    | None                             | **(Required)** The authentication token for Vault. **This should be stored securely in Ansible Vault.**           |
| `deploy_pki_certs__vault_mount_path`               | `pki-intermediate`               | **(Required)** The mount path of the PKI secrets engine used for issuing certificates (e.g., `pki-intermediate`). |
| `deploy_pki_certs__vault_kv_mount_path`            | `kv/pki`                         | **(Required)** The KV v2 mount path where trusted certificates are stored.                                        |

... [truncated - large file] ...

## Backlinks

- [Ansible Roles](../ansible_roles.md)
- [PKI Management](../pki_management.md)

```

This improved version includes a structured layout with clear headings, an enhanced YAML frontmatter, and a "Backlinks" section for better navigation.