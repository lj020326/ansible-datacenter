
# `deploy_pki_certs` Ansible Role

The `deploy_pki_certs` Ansible role is a comprehensive solution for managing and deploying PKI certificates from a **HashCorp Vault** or **OpenBao** instance to target hosts. This role automates the entire certificate host certificate lifecycle, from initial deployment to validation and renewal, ensuring a secure and self-healing infrastructure.

It supports:

- **Static Certificates**: Pre-existing x509 certificates fetched from Vault PKI CA endpoint (`/ca/pem`) or KV paths (e.g., root CA, external CAs, trusted internal certificates).
- **Dynamic Certificates**: On-the-fly issuance for hosts/service routes via Vault PKI (`/issue/`), with caching for idempotency.
- **OS Support**: Debian/Ubuntu (default) and RedHat/CentOS (via OS-specific vars).
- **Features**:
  - Idempotent deploys using SHA256 fingerprint comparisons (avoids unnecessary KV version bumps or file overwrites).
  - Local validation with [`x509_certificate_verify`](https://github.com/dettonville/ansible-utils/blob/main/docs/readme.x509_certificate_verify.md) (expiry, CN, key match, signature chain, is_ca).
  - Host OS Trust store updates (`update-ca-certificates` or `update-ca-trust`).
  - Optional Java keystore integration.
  - PKI CA live checks with local certificate fingerprint vs. Vault KV (`/ca/pem` for the vault PKI certificate).
  - Pre/post-deploy SSL validation script.

The role is split into focused tasks files for maintainability:

- `fetch_static_cert.yml`: Handles static fetches ('pki_ca', 'kv').
- `fetch_dynamic_cert.yml`: Handles dynamic issuance ('pki_service_route', 'pki_host').

-----

## Key Features

  * **Tiered PKI Lifecycle:** For internal certificates, the role first validates local files, then checks a Vault KV cache for an existing valid cert/key pair, and only issues a new pair from the PKI engine if both checks fail.
  * **Persistent Key Caching:** Since Vault’s PKI engine does not store private keys after issuance, this role automatically caches generated keys in a secure KV path to allow for retrieval during host rebuilds or multi-node deployments.
  * **Unified Multi-Use Case Handling:** A single DRY (Don't Repeat Yourself) workflow handles Intermediate CAs, Service Route certificates, Host Identity certificates, and External CA certificates.
  * **Atomic Validation:** Uses the [`dettonville.utils.x509_certificate_verify`](https://github.com/dettonville/ansible-utils/blob/main/docs/readme.x509_certificate_verify.md) module to perform cryptographic matching between certificates and private keys before and after deployment.
  * **Secure and Automated Renewal:** Designed to run on the Ansible control node to prevent exposing sensitive Vault tokens on target hosts.
  * **Centralized Issuance:** All certificates (intermediate CA, service routes, and host identity) are dynamically issued by the Vault PKI secrets engine, serving as a single source of truth.
  * **Zero-Touch Deployment:** The role automatically fetches the CA trust chain, generates a new private key and CSR for the host, and retrieves a signed certificate, deploying them without manual intervention.
  * **Intelligent Validation:** It first checks for existing certificates and their validity using the [`dettonville.utils.x509_certificate_verify`](https://github.com/dettonville/ansible-utils/blob/main/docs/readme.x509_certificate_verify.md) module. If a certificate is missing or invalid (e.g., expired), the role automatically requests and deploys a new one.
  * **Automated and Secure Renewal:** The role is designed to be executed periodically on the **Ansible control node** (via a systemd timer or cron job), which securely triggers the renewal process without ever exposing the sensitive Vault token on the target host.
  * **OS-Agnostic Trust Store Management:** It automatically determines the correct system trust store location and update command based on the target host's operating system (e.g., RedHat, Debian) and updates it with the new CA certificates.
  * **Validation Testing:** A Python script is deployed and executed on the host to verify the integrity of the new SSL/TLS connections and the entire trust chain.

## Requirements

- Ansible 2.10+ (uses `community.crypto`, `community.hashi_vault` collections).
- Vault server with:
  - PKI mount (e.g., `pki-intermediate`) and role (e.g., `internal-api`).
  - KV v2 mount (e.g., `secret`) for trusted cert storage.
  - Token with `read`/`list`/`write`/`delete` on relevant paths (e.g., `trusted_internal` for dynamic certificate storage).
- Target hosts: Debian/Ubuntu or RedHat/CentOS (trust store cmds auto-detected).
- Python deps: `requests`, `hvac`, `python-hcl2` (installed via role).


## Role Variables

| Variable                                           | <br/> Default                    | Description                                                                                                       |
|:---------------------------------------------------|:---------------------------------|:------------------------------------------------------------------------------------------------------------------|
| `deploy_pki_certs__vault_url`                      | `https://vault.example.int:8200` | **(Required)** The URL of the Vault server.                                                                       |
| `deploy_pki_certs__vault_token`                    | None                             | **(Required)** The authentication token for Vault. **This should be stored securely in Ansible Vault.**           |
| `deploy_pki_certs__vault_mount_path`               | `pki-intermediate`               | **(Required)** The mount path of the PKI secrets engine used for issuing certificates (e.g., `pki-intermediate`). |
| `deploy_pki_certs__vault_kv_mount_path`            | `kv/pki`                         | **(Required)** The mount path of the KV2 secrets engine where the CA trust chain is stored (e.g., `kv/pki`).      |
| `deploy_pki_certs__vault_pki_cert_role_name`       | `internal-api`                   | **(Required)** The name of the PKI role to use for issuing certificates (e.g., `ca_role`).                        |
| `deploy_pki_certs__certificate_ttl`                | `720h`                           | The validity period for issued certificates (e.g., `720h`).                                                       |
| `deploy_pki_certs__ca_service_routes_list`         | `[]`                             | A list of service routes that require certificates on the host (e.g., ['admin.example.int']).                     |
| `deploy_pki_certs__local_cert_dir`                 | `/usr/local/ssl/certs`           | Local cert destination.                                                                                           |
| `deploy_pki_certs__local_key_dir`                  | `/usr/local/ssl/private`         | Local key destination.                                                                                            |
| `deploy_pki_certs__ca_force_deploy`                | `false`                          | Force re-fetch/deploy (ignores fingerprints).                                                                     |
| `deploy_pki_certs__ca_reset_local_certs`           | `false`                          | Backup and reset local dirs (dangerous).                                                                          |
| `deploy_pki_certs__java_keystore_enabled`          | `false`                          | Add to Java cacerts.                                                                                              |
| `deploy_pki_certs__ca_cert_renewal_tolerance_days` | 30                               | Fail if expiry < this days.                                                                                       |

### OS-Specific Overrides:

- Loaded via `include_vars` in `main.yml` (Debian default; RedHat via `redhat.yml`).
- Examples: `__deploy_pki_certs__trust_ca_update_trust_cmd` = `update-ca-certificates` (Debian) or `update-ca-trust extract` (RedHat).

## Dependencies

- `community.crypto` (for `x509_certificate_info`, `java_cert`).
- `community.hashi_vault` (for `vault_kv2_get`, `vault_kv2_write`).
- `dettonville.utils` (for `x509_certificate_verify`).

Install: `ansible-galaxy collection install community.crypto community.hashi_vault dettonville.utils`.

## Example Use Cases

1. Intermediate CA (Trust Chain)
Deploys the root/intermediate certificate used by the system to trust all internally signed traffic.

2. Service Route Certificates
Deploys a shared certificate (often a wildcard like *.apps.example.int) to multiple nodes. The first node generates it and saves it to the KV cache; subsequent nodes simply pull the valid pair from the cache.

3. Host-Specific Identity
Deploys a certificate unique to the host's FQDN, including its private key.

4. External Certificates
Deploys third-party or partner CA certificates stored in Vault KV to the local system trust store.

## Example Playbooks

To use this role, create a playbook similar to the following. 

Prior to running `deploy_pki_certs`, make sure to properly set-up and configure the PKI vault using the `bootstrap_pki` role in this repository.

```yaml
---
- name: Deploy and Manage PKI Certificates
  hosts: servers
  become: true
  roles:
    - role: dettonville.utils.deploy_pki_certs
      vars:
        deploy_pki_certs__vault_url: "https://vault.example.com:8200"
        deploy_pki_certs__vault_token: "{{ vault_token | b64decode }}"  # Encrypted
        deploy_pki_certs__ca_service_routes_list:
          - "admin.example.com"
          - "api.example.com"
  tags: [deploy-pki-certs]

```

Example using reset
```yaml
---
- name: Deploy and Manage Certificates
  hosts: ca_domain
  become: yes
  vars:
    # Vault connection details
    deploy_pki_certs__vault_url: "https://vault.example.com:8200"
    deploy_pki_certs__vault_token: "{{ vault_token_from_a_safe_source }}"
    # Example service routes for the host
    deploy_pki_certs__ca_service_routes_list:
      - route: "web.example.com"
      - route: "api.example.com"
    deploy_pki_certs__ca_force_deploy: true  # For initial run
    deploy_pki_certs__ca_reset_local_certs: true  # Careful!
  roles:
    - role: deploy_pki_certs
      tags:
        - certs
        - deploy_pki_certs
```

### Force Modes

- `deploy_pki_certs__ca_force_deploy: true`: Ignores fingerprints/local checks—re-fetches/deploys all.
- `deploy_pki_certs__ca_reset_local_certs: true`: Backs up and wipes local dirs (use with force).

-----


## Testing

### Certificate Chain Verification
- Root CA fetched from Vault KV (`trusted_internal/ca-root`) and deployed to `/usr/local/ssl/certs/ca-root.pem`.
- PKI Vault Intermediate certificate from `/pki-intermediate/ca/pem` to `/usr/local/ssl/certs/intermediate-ca.pem`.
- Leaf certificates verified against intermediate; full chain: `openssl verify -CAfile /usr/local/ssl/certs/ca-root.pem /usr/local/ssl/certs/intermediate-ca.pem /usr/local/ssl/certs/<leaf>.pem`.
- System trust updated for CAs (root + intermediate).

### Manual Validation on Host (post-run)
```bash
# Root self-signed
openssl verify -CAfile /usr/local/ssl/certs/ca-root.pem /usr/local/ssl/certs/ca-root.pem  # OK
# Intermediate → Root
openssl verify -CAfile /usr/local/ssl/certs/ca-root.pem /usr/local/ssl/certs/intermediate-ca.pem  # OK
# Leaf → Intermediate
openssl verify -CAfile /usr/local/ssl/certs/intermediate-ca.pem /usr/local/ssl/certs/admin.example.int.pem  # OK (add -partial_chain if strict)
# Full Chain
openssl verify -CAfile /etc/ssl/certs/ca-certificates.crt /usr/local/ssl/certs/admin.example.int.pem  # OK (after trust update)
# No leaf certificates in trust
ls /usr/local/share/ca-certificates/ | grep '\.johnson\.int\.crt'  # Empty
# verify certificate-key pair
ls -Fla /usr/local/ssl/{certs,private}/admin.example.int*  # Timestamps synced
openssl x509 -in ... -pubkey -noout > cert_pub.key
openssl ec -in ... -pubout > key_pub.key
sdiff -s cert_pub.key key_pub.key  # Identical
openssl x509 -in ... -pubkey -noout | sha256sum  # Hashes match
```

Edge Case: Rotate intermediate in role **bootstrap_pki** (force renew), re-run **deploy_pki_certs** — fingerprint mismatch should trigger update.

-----

## Detailed Workflow: A Step-by-Step Guide

The `tasks/main.yml` playbook follows a precise and layered logical flow to ensure every certificate type is handled correctly. The role now separates **static** (pre-existing and managed by the **bootstrap_pki** role) and **dynamic** (on-the-fly issuance) certificates into dedicated tasks files (`fetch_static_cert.yml` and `fetch_dynamic_cert.yml`) for better maintainability. Here is a breakdown of the steps:

1. **Preparation & Dependencies**

- **Gather Facts & Include OS Vars:** Collects `date_time` facts and loads OS-specific variables (e.g., Debian vs. RedHat trust commands via include_vars). 
- **Install Python Packages:** Installs essential/required Python libraries (`python-hcl2`, `requests`, `hvac`) on the Ansible control node for Vault API interactions and validation scripts. 
- **Optional Reset:** If `deploy_pki_certs__ca_reset_local_certs: true`, backs up and wipes local cert/key dirs (with timestamped archives). 
- **Ensure Directories Exist:** Creates secure local directories on the target host for certificates (`deploy_pki_certs__local_cert_dir`, e.g., `/usr/local/ssl/certs`) and private keys (`deploy_pki_certs__local_key_dir`, e.g., `/usr/local/ssl/private`). 
- **Vault Connectivity:** Validates Vault token permissions for PKI reads, KV access, and issuance via `validate_vault_pki.yml`. 
- **Local Audit:** For each cert type, checks file existence (stat) and cryptographic validity (e.g., expiry, CN match) using [`dettonville.utils.x509_certificate_verify`](https://github.com/dettonville/ansible-utils/blob/main/docs/readme.x509_certificate_verify.md).

2. **Content Gathering Phase (The Source of Truth)**

Certificates are fetched or issued based on type, with idempotency via SHA256 fingerprint comparisons (local vs. fetched/cached). Changes trigger `__ca_cert_has_changed: true` for trust updates.

**Static Certificates** (`fetch_static_cert.yml`)
Handles pre-existing certs from Vault PKI CA or KV stores (types: 'pki_ca', 'kv' for root/internal/external CAs).

- **Check Local:** Stat cert file; if exists, extract fingerprint and validate (e.g., not expired, key match if applicable). 
- **Fetch from Source:**
  - 'pki_ca': Direct GET to Vault `/ca/pem` endpoint; compare live fingerprint.
  - 'kv': `vault_kv2_get` from KV path (e.g., `secret/trusted_internal/root-ca.pem`); extract stored fingerprint.

- **Compare & Skip:** If local fingerprint matches fetched, set `__needs_content_fetch: false` (no deploy). 
- **Set Content:** If mismatch/missing, store raw PEM in `__cert_content` (no issuance/caching needed).

**Dynamic Certificates** (`fetch_dynamic_cert.yml`)
Handles on-the-fly issuance for hosts/routes (types: 'pki_service_route', 'pki_host').

- **Check Local:** Stat cert/key files; if exists, extract fingerprint and validate pair (pubkey DER match, expiry). 
- **Vault Cache Check:** Load from Vault cache (<Vault URL>/pki_cache/<slug>); validate TTL (issued_at + deploy_pki_certs__certificate_ttl > now). 
  - If cache valid and fingerprints match, skip issuance. 
- **Issue New (if needed):** `vault_kv2_write` to PKI /issue/<role> (e.g., `common_name: admin.example.int`, TTL: 8760h); unescape PEM (replace \\n → \n). 
  - Cache fresh response (cert, key, chain) as JSON.
  - Extract fingerprints; compare local—if match, skip deploy.

- **Set Content:** Store cert (`__pki_cert_content`), key (`__pki_key_content`, unescaped), chain (`__pki_chain_content`, joined with \n).

**Idempotency Across Both:**

- Force modes: `deploy_pki_certs__ca_force_deploy: true` ignores compares.
- Validation: Pre-fetch and verify using [`dettonville.utils.x509_certificate_verify`](https://github.com/dettonville/ansible-utils/blob/main/docs/readme.x509_certificate_verify.md) (content-based for dynamic; file-based for static).

3. **Deployment & Final Verification**

- **Conditional Deploy:** Only if `__needs_content_fetch` or force (writes cert/key/chain with backups; keys at '0600').
  - Trust Store: Copies CA certs to OS dir (e.g., `/usr/local/share/ca-certificates`) and notifies handler (`reload ca certificates`).
  - Java Keystore: Optional `java_cert` add if enabled.

- **Post-Deployment Validation:** Re-validate written files (signature, expiry, pair match); fails fast if `deploy_pki_certs__pre_deploy_verify_fail_fast: true`.
- **System Integration:** Runs trust update command (OS-specific); deploys/runs Python SSL validation script (`/usr/local/bin/verify_ssl_connection.py`) against `deploy_pki_certs__validation_url`.
- **Global Trigger:** Sets `__ca_cert_has_changed`: true for any update, propagating to final trust refresh.

**Handlers** (`handlers/main.yml`): Trigger systemd reload and CA trust update on notifies.
This workflow ensures minimal API calls, cryptographic safety, and cross-OS compatibility. For full idempotency, re-runs skip unchanged certs (fingerprint match).

-----

## Vault Policy Requirements

To support the certificate creation and caching functionality, the deploy-ca Vault token must have a policy granting access to the following vault paths:

```terraform
path "pki-intermediate/*" {
  capabilities = ["read", "list"]
}
# issue/sign for deploys
path "pki-intermediate/issue/*" {
  capabilities = ["create", "update"]
}
path "pki-intermediate/issue/internal-api" {
  capabilities = ["create", "update"]
}
path "pki-intermediate/sign/*" {
  capabilities = ["create", "update"]
}
path "pki-intermediate/config/*" {
  capabilities = ["read", "list"]
}
path "pki-intermediate/roles/*" {
  capabilities = ["read", "list"]
}
# Allow full access to the PKI KV Cache
path "secret/data/pki_cache/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
# If using KV version 1, or for listing metadata in KV version 2
path "secret/metadata/pki_cache/*" {
  capabilities = ["list", "read"]
}
# Allow full access to the PKI KV to dynamically store created service route and host certificates
path "secret/data/trusted_internal/*" {
  capabilities = ["create", "read", "update", "list"]
}
path "secret/metadata/trusted_internal" {
  capabilities = ["list", "read"]
}
path "secret/data/trusted_external/*" {
  capabilities = ["list", "read"]
}
path "secret/metadata/trusted_external" {
  capabilities = ["list", "read"]
}
path "auth/token/lookup*" {
  capabilities = ["read"]
}
path "sys/mounts" {
  capabilities = ["read", "list"]
}
path "sys/mounts/*" {
  capabilities = ["read", "list"]
}
path "sys/seal-status" {
  capabilities = ["read"]
}

```

-----

## Secure Certificate Renewal

To automate certificate renewal, **do not** deploy a cron job or systemd timer on the target hosts that contains the Vault token. This is a significant security vulnerability.

Instead, schedule a periodic execution of this Ansible playbook on your **Ansible controller** (e.g., `Ansible Tower` or `CICD scheduled job(s)`). The role's existing logic will automatically handle certificate validation and renewal when run.


### Basic example using systemd timer service on controller node

A safe and effective way to achieve this is to use a `systemd.timer` and `systemd.service` unit on your control node.

**Example: `ansible-ca-renewal.service` (on control node)**

```
[Unit]
Description=Run Ansible playbook for Vault certificate renewal
Requires=ansible-ca-renewal.timer

[Service]
Type=oneshot
ExecStart=/usr/bin/ansible-playbook -i /path/to/your/inventory /path/to/your/playbook.yml
User=ansibleuser
```

**Example: `ansible-ca-renewal.timer` (on control node)**

```
[Unit]
Description=Periodically run Ansible playbook for Vault certificate renewal

[Timer]
# Run the playbook every 12 hours
OnCalendar=*:0/12
RandomizedDelaySec=3600
Persistent=true

[Install]
WantedBy=timers.target
```

**Example: `ansible-ca-renewal.timer` (on control node)**

```
[Unit]
Description=Periodically run Ansible playbook for Vault certificate renewal

[Timer]
# Run daily at 2 AM, but only if TTL <30 days (custom logic in playbook)
OnCalendar=--* 02:00:00
RandomizedDelaySec=3600
# Stagger in cluster
Persistent=true

[Install]
WantedBy=timers.target
```

Enable timer service:
```shell
systemctl enable --now ansible-ca-renewal.timer
```

## Post Cert Deployment Manual Verifications

- Test deployed cert bundle
  ```shell
  # For ca-root (RSA private key)
  $ openssl x509 -in /usr/local/ssl/certs/ca-root.pem -pubkey -noout > cert_pub_rsa.key
  $ openssl rsa -in /usr/local/ssl/private/ca-root-key.pem -pubout > key_pub_rsa.key
  writing RSA key
  $ diff cert_pub_rsa.key key_pub_rsa.key
  $ 
  # For example-vault-ca (ECDSA private key)
  $ openssl x509 -in /usr/local/ssl/certs/example-vault-ca.pem -pubkey -noout > cert_pub_ec.key
  $ openssl ec -in /usr/local/ssl/private/example-vault-ca-key.pem -pubout > key_pub_ec.key
  $ diff cert_pub_ec.key key_pub_ec.key  # Should be empty (match)
  $ 
  ```
- Validation test script
  The role deploys the `validate_certs.sh` script which performs the same test as above for the root and vault certs.
