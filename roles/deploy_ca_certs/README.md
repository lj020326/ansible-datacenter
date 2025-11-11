
# `deploy_ca_certs` Ansible Role

The `deploy_ca_certs` Ansible role is a comprehensive solution for managing and deploying PKI certificates from a **Vault** (OpenBao or HashiCorp Vault) instance to target hosts. This role automates the entire certificate lifecycle, from initial deployment to validation and renewal, ensuring a secure and self-healing infrastructure.

-----

## Key Features

  * **Centralized Issuance:** All certificates (intermediate CA, service routes, and host identity) are dynamically issued by the Vault PKI secrets engine, serving as a single source of truth.
  * **Zero-Touch Deployment:** The role automatically fetches the CA trust chain, generates a new private key and CSR for the host, and retrieves a signed certificate, deploying them without manual intervention.
  * **Intelligent Validation:** It first checks for existing certificates and their validity. If a certificate is missing or invalid (e.g., expired), the role automatically requests and deploys a new one.
  * **Automated and Secure Renewal:** The role is designed to be executed periodically on the **Ansible control node** (via a systemd timer or cron job), which securely triggers the renewal process without ever exposing the sensitive Vault token on the target host.
  * **OS-Agnostic Trust Store Management:** It automatically determines the correct system trust store location and update command based on the target host's operating system (e.g., RedHat, Debian) and updates it with the new CA certificates.
  * **Validation Testing:** A Python script is deployed and executed on the host to verify the integrity of the new SSL/TLS connections and the entire trust chain.

-----

## Detailed Workflow: A Step-by-Step Guide

The `tasks/main.yml` playbook follows a precise and layered logical flow to ensure every certificate type is handled correctly. Here is a breakdown of the steps:

1.  **Preparation & Dependencies:**

      * **Install Python Packages:** Installs essential Python libraries (`python-hcl2`, `requests`, `hvac`) on the Ansible control node, which are required for interacting with the Vault API.
      * **Ensure Directories Exist:** Creates the necessary local directories on the target host to store certificates (`deploy_ca_certs__cacert_local_cert_dir`) and private keys (`deploy_ca_certs__cacert_local_key_dir`).

2.  **Intermediate CA Certificate Deployment:**

      * **Check Existence:** First, it uses `ansible.builtin.stat` to check if the intermediate CA certificate file (`intermediate_ca.pem`) already exists on the target host.
      * **Validate:** If the file exists, the playbook proceeds to validate its properties using the `dettonville.utils.x509_certificate_verify` module, ensuring it is not expired.
      * **Fetch or Skip:** If the certificate is either missing or has failed validation, the role will retrieve it from the Vault KV store using `community.hashi_vault.vault_kv2_get` and deploy it to the host. If the certificate is valid, this entire step is skipped, saving an API call.

3.  **Service Route Certificates Deployment:**

      * **Loop Through Routes:** The role iterates over the `deploy_ca_certs__ca_service_routes_list` variable, processing each service route individually.
      * **Check and Validate:** For each service, it checks for an existing certificate and validates its expiration date.
      * **Generate & Deploy:** If the certificate is not found or is invalid, the role makes an API call to Vault's PKI secrets engine using `community.hashi_vault.vault_pki_generate_certificate` to issue a new certificate and key. These are then deployed to the host.

4.  **Host Certificate Deployment:**

      * **Check and Validate:** Similar to the intermediate CA, the role checks for the existence of the host's primary certificate (`{{ ansible_fqdn }}.crt`) and validates its expiration.
      * **Create Key & CSR:** If the certificate is missing or invalid, the playbook first creates a new private key and a Certificate Signing Request (CSR) on the target host using `community.crypto.openssl_privatekey` and `community.crypto.openssl_csr`.
      * **Request & Deploy:** It then uses the CSR to request a new certificate from Vault's PKI engine via the `community.hashi_vault.vault_pki_generate_certificate` module, which is subsequently copied to the host.

5.  **External CA Certificates:**

      * **Retrieve from KV:** The role retrieves a list of external CA certificates from a specified Vault KV store.
      * **Loop & Deploy:** It loops through this list, checks for the existence and validity of each certificate on the target host, and deploys any that are missing or invalid.

6.  **Trust Store and Validation:**

      * **Update System Trust:** The role runs a command (`update-ca-trust` or `update-ca-certificates`) to update the system's CA trust store, ensuring that applications on the host trust the newly deployed certificates.
      * **Run Validation Script:** A Python script is deployed and executed to perform a final validation check of the SSL/TLS connections, confirming the entire process was successful.

-----

## Role Variables

| Variable | Description                                                                                                  | Default |
| :--- |:-------------------------------------------------------------------------------------------------------------| :--- |
| `deploy_ca_certs__vault_url` | **(Required)** The URL of the Vault server.                                                         | `https://vault.example.com:8200` |
| `deploy_ca_certs__vault_token` | **(Required)** The authentication token for Vault. **This should be stored securely in Ansible Vault.**      | None |
| `deploy_ca_certs__vault_mount_path` | **(Required)** The mount path of the PKI secrets engine used for issuing certificates (e.g., `pki-intermediate`). | `pki-intermediate` |
| `deploy_ca_certs__pki_cert_role_name` | **(Required)** The name of the PKI role to use for issuing certificates (e.g., `ca_role`).                   | `ca_role` |
| `deploy_ca_certs__vault_kv_path` | **(Required)** The mount path of the KV2 secrets engine where the CA trust chain is stored (e.g., `kv/pki`). | `kv/pki` |
| `deploy_ca_certs__certificate_ttl` | The validity period for issued certificates (e.g., `720h`).                                                  | `720h` |
| `deploy_ca_certs__ca_service_routes_list` | A list of service routes that require certificates on the host.                                              | `[]` |

-----

## Example Playbook Usage

To use this role, create a playbook like the following. Be sure to use Ansible Vault to manage your `deploy_ca_certs__vault_token`.

```yaml
---
- name: Deploy and Manage Certificates with Vault
  hosts: all
  become: yes
  vars:
    # Vault connection details
    deploy_ca_certs__vault_url: "https://vault.example.com:8200"
    deploy_ca_certs__vault_token: "{{ vault_token_from_a_safe_source }}"

    # Vault PKI configuration
    deploy_ca_certs__vault_mount_path: "pki-intermediate"
    deploy_ca_certs__pki_cert_role_name: "ca_role"
    deploy_ca_certs__vault_kv_path: "kv/pki"

    # Example service routes for the host
    deploy_ca_certs__ca_service_routes_list:
      - route: "web.example.com"
      - route: "api.example.com"

  roles:
    - role: deploy_ca_certs
      tags:
        - certs
        - deploy_ca_certs
```

-----

## Secure Certificate Renewal

To automate certificate renewal, **do not** deploy a cron job or systemd timer on the target hosts that contains the Vault token. This is a significant security vulnerability.

Instead, schedule a periodic execution of this Ansible playbook on your **Ansible control node**. The role's existing logic will automatically handle certificate validation and renewal when run.

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
