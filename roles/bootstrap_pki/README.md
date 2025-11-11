# Ansible Role: `bootstrap_pki`

An Ansible role to bootstrap a two-tier public key infrastructure (PKI) with a self-signed root certificate authority (CA) created externally and an intermediate CA, which is signed by the root CA and imported into Vault to serve as the root of a PKI secrets engine. This role utilizes `cfssl` for certificate management and integrates with Vault for certificate issuance.

-----

## 🚀 Features

* **Idempotent:** The role checks for existing certificates and only creates or updates them if they are missing or invalid.
* **External Root CA:** The root CA can be generated externally using `cfssl` and remains offline; the role supports generation on-target if needed (with offline key export recommended).
* **Root CA Key Encryption:** The root CA key can be encrypted using Ansible Vault with a role-defined password to enhance security on the target host.
* **Admin Token Management:** Automatically creates an admin token with the "admin" policy if it doesn't exist, using the root token for setup.
* **Intermediate CA Management:** The intermediate CA is generated externally, signed by the root CA, and imported into Vault as the PKI secrets engine root.
* **Highly Configurable:** All certificate and key parameters (common names, key algorithms, key sizes, etc.) are defined via Ansible variables.
* **Vault Integration:** The intermediate CA certificate and key are imported into a Vault/OpenBao PKI secrets engine for certificate issuance.
* **Robust Validation:** Includes comprehensive validation checks to ensure:
    * Certificates are not expired.
    * Common names, key types, and key sizes match the configuration.
    * The intermediate CA's signature is valid and signed by the root CA.
    * The Vault PKI engine's intermediate CA certificate matches the local certificate.
* **Standardized Naming:** All certificate and key files use a configurable `output_basename` for consistent file naming.

-----

## 🛠️ Requirements

* **Ansible:** Version 2.10 or newer.
* **Python Libraries:** The `hvac` and `cryptography` libraries must be installed on the Ansible control node.
    ```shell
    pip install hvac cryptography
    ```
* **CFSSL:** The `cfssl` and `cfssljson` binaries must be available on the target host (e.g., `control01`).
* **Ansible Vault:** The `ansible-vault` command must be available on the target host if `bootstrap_pki__encrypt_root_ca_key` is enabled.
* **Vault:** Tested with Vault 1.12+ and OpenBao 2.0+. Ensure the `pki` secrets engine is available and the "admin" policy exists.
* **Custom Module (Optional):** The `dettonville.utils.x509_certificate_verify` module is used for enhanced certificate validation. If unavailable, the role falls back to `community.crypto.x509_certificate_info` for basic validation.
* **Vault Server:** An accessible Vault/OpenBao server with:
    * A `pki` secrets engine mounted at `pki-intermediate`.
    * A valid root token or a token with `sudo` permissions on the `sys/mounts` and `pki-intermediate` paths.

-----

## ⚙️ Role Variables

The following variables can be configured in your playbook or `vars` files.

| Variable Name                          | Default Value               | Description                                                                                                                                    |
|----------------------------------------|-----------------------------|------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_pki__vault_url`             | `https://vault.example.int` | The URL of the Vault server.                                                                                                           |
| `bootstrap_pki__vault_token`           | `""`                        | The authentication token for Vault (typically root token for bootstrap).                                                                |
| `bootstrap_pki__vault_mount_path`      | `pki-intermediate`          | The path in Vault where the PKI secrets engine is mounted.                                                                             |
| `bootstrap_pki__ca_dir`                | `/etc/pki/cacerts`          | The directory on the target host to store the certificate files.                                                                               |
| `bootstrap_pki__ca_reset_cert`         | `false`                     | If `true`, forces regeneration of CA certificates even if they exist.                                                                          |
| `bootstrap_pki__backup_retention_maximum_number` | `10`              | Maximum number of CA backup files to retain (e.g., `ca.backup_*.tar.gz`).                                                                      |
| `bootstrap_pki__encrypt_root_ca_key`   | `false`                     | If `true`, encrypts the root CA key using Ansible Vault after generation.                                                                      |
| `bootstrap_pki__encrypted_root_ca_key_path` | `/etc/pki/cacerts/ca-key.pem.vault` | Path to store the encrypted root CA key (used when `bootstrap_pki__encrypt_root_ca_key` is `true`). |
| `bootstrap_pki__vault_password`        | `""`                        | The password used for Ansible Vault encryption/decryption of the root CA key. Must be set if `bootstrap_pki__encrypt_root_ca_key` is `true`.    |
| `bootstrap_pki__admin_token_display_name` | `"admin_user_token"`   | Display name for the admin token to create/check.                                                                                              |
| `bootstrap_pki__admin_token_policies`  | `["admin"]`                 | Policies to attach to the admin token.                                                                                                         |
| `bootstrap_pki__admin_token_ttl`       | `"87600h"`                  | TTL for the admin token (10 years by default).                                                                                                 |
| `bootstrap_pki__root_ca_cert_info`     | `{ ... }`                   | Dictionary for root CA configuration. See details below.                                                                                       |
| `bootstrap_pki__vault_ca_cert_info` | `{ ... }`                | Dictionary for intermediate CA configuration. See details below.                                                                               |
| `bootstrap_pki__ca_cert_duration_root` | `"438000h"`                 | The validity period for the root CA certificate (50 years by default).                                                                         |
| `bootstrap_pki__ca_cert_duration_intermediate` | `"87600h"`          | The validity period for intermediate CA certificates (10 years by default).                                                                    |
| `bootstrap_pki__ca_cert_duration_server` | `"87600h"`                | The validity period for server CA certificates (10 years by default).                                                                          |
| `bootstrap_pki__ca_cert_duration_client` | `"87600h"`                | The validity period for client CA certificates (10 years by default).                                                                          |
| `bootstrap_pki__ca_cfssl_profiles`     | `{ ... }`                   | Dictionary defining CFSSL profiles for certificate signing, including usages, expiry, and CA constraints. See defaults/main.yml for structure. |

Example profiles configuration:
```yaml
bootstrap_pki__ca_cfssl_profiles:
  signing:
    default:
      expiry: "87600h"
    profiles:
      intermediate_ca:
        usages:
          - cert sign
          - crl sign
        is_ca: true
        ca_constraint:
          is_ca: true
          max_path_len: 1
        expiry: "87600h"
```

Example for custom roles:
```yaml
bootstrap_pki__vault_roles:
  - name: "custom-server"
    allowed_domains:
      - "mydomain.com"
    allow_subdomains: true
    key_type: "ecdsa"
    key_bits: 384
    max_ttl: "168h"
    ttl: "24h"
```

### `bootstrap_pki__root_ca_cert_info`

| Key                   | Default Value         | Description                                                    |
|-----------------------|-----------------------|----------------------------------------------------------------|
| `output_basename`     | `"ca"`                | The filename prefix for the root CA certificate and key files. |
| `key_algo`            | `"rsa"`               | The key algorithm.                                             |
| `key_size`            | `4096`                | The key size in bits.                                          |
| `common_name`         | `"MyOrg Root CA"`     | The common name for the root CA.                               |
| `country`             | (none)                | Optional country (C).                                          |
| `state`               | (none)                | Optional state (ST).                                           |
| `locality`            | (none)                | Optional locality (L).                                         |
| `organization`        | (none)                | Optional organization (O).                                     |
| `organizational_unit` | (none)                | Optional organizational unit (OU).                             |
| `email_address`       | (none)                | Optional email address.                                        |

### `bootstrap_pki__vault_ca_cert_info`

| Key                   | Default Value         | Description                                                    |
|-----------------------|-----------------------|----------------------------------------------------------------|
| `output_basename`     | `"intermediate-ca"`   | The filename prefix for the intermediate CA files.             |
| `key_algo`            | `"ecdsa"`             | The key algorithm.                                             |
| `key_size`            | `256`                 | The key size in bits.                                          |
| `common_name`         | `"MyOrg Intermediate CA"` | The common name for the intermediate CA.                   |
| `country`             | (none)                | Optional country (C).                                          |
| `state`               | (none)                | Optional state (ST).                                           |
| `locality`            | (none)                | Optional locality (L).                                         |
| `organization`        | (none)                | Optional organization (O).                                     |
| `organizational_unit` | (none)                | Optional organizational unit (OU).                             |
| `email_address`       | (none)                | Optional email address.                                        |
| `ca_issuer_path`      | `/etc/pki/cacerts/ca.pem` | Path to the root CA certificate for signing the intermediate CA. |
| `ca_issuer_key_path`  | `/etc/pki/cacerts/ca-key.pem` | Path to the root CA private key for signing the intermediate CA. |

### Key Algorithm Choice (RSA vs ECDSA)
For the Intermediate CA (`bootstrap_pki__vault_ca_cert_info.key_algo`), ECDSA ("ecdsa") with a 256-bit key (secp256r1 curve) is the default and recommended for most modern setups. It provides equivalent security to RSA 3072-4096 bits but with better performance, smaller keys, and lower computational overhead. RSA is still secure and compatible but is bulkier and slower. Use RSA if you need broad legacy compatibility; otherwise, stick with ECDSA for efficiency and future-proofing. To enforce the default, avoid overriding in playbooks/inventory.

-----

## 🏃 Usage

### Example Playbook

Create a playbook file, for example, `main.yml`:

```yaml
- name: "Bootstrap PKI"
  hosts: control01
  gather_facts: false
  vars:
    bootstrap_pki__encrypt_root_ca_key: true
    bootstrap_pki__vault_password: "secure-vault-password"
  roles:
    - role: bootstrap_pki
```

**Note**: Store `bootstrap_pki__vault_password` in an encrypted variables file (e.g., using Ansible Vault) to avoid exposing it in plain text. Example:

```shell
ansible-vault encrypt_string 'secure-vault-password' --name 'bootstrap_pki__vault_password'
```

### Running the Playbook

1. Place the `bootstrap_pki` role in your Ansible roles path.
2. Ensure you have the required Python libraries installed.
3. Ensure the `cfssl` and `cfssljson` binaries are on the target host.
4. If `bootstrap_pki__encrypt_root_ca_key` is `true`, ensure `ansible-vault` is installed on the target host and `bootstrap_pki__vault_password` is set.
5. Ensure your `vault.example.int` server is running and accessible with the required secrets engines and token.
6. Run the playbook from your Ansible control node:
    ```shell
    ansible-playbook -i inventory.ini main.yml
    ```

### Verification

After running the playbook:
- Verify the root CA certificate at `/etc/pki/cacerts/ca.pem`.
- If `bootstrap_pki__encrypt_root_ca_key` is `true`, verify the encrypted root CA key at `/etc/pki/cacerts/ca-key.pem.vault` and ensure the unencrypted key (`/etc/pki/cacerts/ca-key.pem`) is removed.
- Verify the intermediate CA certificate at `/etc/pki/cacerts/intermediate-ca.pem`.
- Check that the number of backup files (`/etc/pki/cacerts/ca.backup_*.tar.gz` or `/etc/pki/cacerts/intermediate-ca.backup_*.tar.gz`) does not exceed `bootstrap_pki__backup_retention_maximum_number`.
- Verify the admin token was created or fetched:
  ```shell
  bao token lookup <admin_token_id>  # Use bootstrap_pki__admin_token fact
  ```
- Check the OpenBao PKI secrets engine:
  ```shell
  openbao read pki-intermediate/ca
  openbao read pki-intermediate/config/urls
  ```
- Test certificate issuance (assumes `web-server` role from defaults):
  ```shell
  openbao write pki-intermediate/issue/web-server common_name=test.example.com
  ```
- To decrypt the root CA key for use (e.g., signing additional intermediate CAs):
  ```shell
  ansible-vault decrypt /etc/pki/cacerts/ca-key.pem.vault --output /etc/pki/cacerts/ca-key.pem --vault-password-file=/path/to/vault_password
  ```
- To test certificate regeneration, set `bootstrap_pki__ca_reset_cert: true` in your playbook or vars file and re-run to force recreation of certificates.

---

## 🛡️ Security Considerations

- **Root CA Key Security**: The root CA private key (`/etc/pki/cacerts/ca-key.pem`) is generated on the target host. If `bootstrap_pki__encrypt_root_ca_key` is `true`, it is encrypted using Ansible Vault with `bootstrap_pki__vault_password` and stored at `bootstrap_pki__encrypted_root_ca_key_path`, with the unencrypted key removed. Ensure `bootstrap_pki__vault_password` is stored securely (e.g., in an encrypted variables file) and `ansible-vault` is installed on the target host.
- **Admin Token Security**: The admin token is created with the "admin" policy and a long TTL. Store the token securely (e.g., in `bootstrap_pki__admin_token` fact) and revoke it when no longer needed: `openbao token revoke <admin_token_id>`.
- **Vault Password Security**: The `bootstrap_pki__vault_password` is sensitive and should be treated as a secret. Use Ansible Vault to encrypt the variable in your playbook or vars file.
- **Vault Token**: The `bootstrap_pki__vault_token` should have minimal permissions, ideally limited to create and update on `sys/mounts/{{ bootstrap_pki__vault_mount_path }}`, `{{ bootstrap_pki__vault_mount_path }}/roles/*`, and `{{ bootstrap_pki__vault_mount_path }}/config/*`.
- **File Permissions**: Ensure the `bootstrap_pki__ca_dir` directory (`/etc/pki/cacerts`) has restrictive permissions (e.g., 0700) to protect sensitive files.
- **Certificate Validation**: Always validate the chain of trust for issued certificates using the root CA certificate.
- **Backup Management**: The `bootstrap_pki__backup_retention_maximum_number` variable limits the number of CA backup files to prevent excessive disk usage and reduce the risk of retaining old sensitive key material.

## 🐛 Debugging

### Common Issues
- **Error: "Vault token lacks permissions"**
  - Ensure the token has `create` and `update` capabilities on `sys/mounts/{{ bootstrap_pki__vault_mount_path }}` and `{{ bootstrap_pki__vault_mount_path }}/*`.
  - Run: `openbao token capabilities <token> sys/mounts/{{ bootstrap_pki__vault_mount_path }}`
- **Error: "cfssl command not found"**
  - Verify that `cfssl` and `cfssljson` are installed on the target host.
  - Check the `bootstrap_cfssl` role logs for installation errors.
- **Error: "CA certificate verification failed"**
  - Ensure the root CA certificate and key are valid and accessible at the specified paths.
  - Validate the certificate: `openssl x509 -in /etc/pki/cacerts/ca.pem -text -noout`
- **Error: "ansible-vault command not found"**
  - Ensure `ansible-vault` is installed on the target host if `bootstrap_pki__encrypt_root_ca_key` is `true`.
  - Install Ansible on the target: `pip install ansible`
- **Error: "bootstrap_pki__vault_password must be provided"**
  - Ensure `bootstrap_pki__vault_password` is set in your playbook or vars file when `bootstrap_pki__encrypt_root_ca_key` is `true`.
  - Store the password securely using Ansible Vault:
    ```shell
    ansible-vault encrypt_string 'your-secure-password' --name 'bootstrap_pki__vault_password'
    ```
- **Error: "Admin token not found or creation failed"**
  - Ensure the root token (`bootstrap_pki__vault_token`) has `sudo` capabilities for token creation.
  - Verify the "admin" policy exists: `openbao policy read admin`.
  - Check OpenBao logs for token creation errors.

If you encounter issues:

- **Verbose Output**: Run the playbook with `-vvv` to inspect API requests and task results.
- **Check OpenBao Logs**: Review OpenBao server logs for errors during mount creation, role configuration, or certificate import.
- **Validate Certificates**:
  ```shell
  openssl x509 -in /etc/pki/cacerts/intermediate-ca.pem -text -noout
  openssl verify -CAfile /etc/pki/cacerts/ca.pem /etc/pki/cacerts/intermediate-ca.pem
  ```
- **Backup File Naming**: Backup files are named with a timestamp in the format `YYYYMMDDTHHMMSS` (e.g., `ca.backup_20250929T123456.tar.gz`).
- **Check Backup Files**:
  ```shell
  ls -l /etc/pki/cacerts/*.backup_*.tar.gz
  ```
- **Check Encrypted Root CA Key**:
  ```shell
  ls -l /etc/pki/cacerts/ca-key.pem.vault
  file /etc/pki/cacerts/ca-key.pem.vault  # Should show Ansible Vault encrypted data
  ```
- **Check Mount Existence**: If the `pki-intermediate` mount exists but is misconfigured, delete it (with caution, as it removes all data):
  ```shell
  openbao write -force sys/mounts/{{ bootstrap_pki__vault_mount_path }}
  ```
- **Token Permissions**: Verify the token's capabilities:
  ```shell
  openbao token capabilities <token> sys/mounts/{{ bootstrap_pki__vault_mount_path }}
  openbao token capabilities <token> {{ bootstrap_pki__vault_mount_path }}/roles/intermediate_ca
  ```
