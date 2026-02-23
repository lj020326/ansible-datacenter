
# Ansible Role: `bootstrap_ca_certs`

## Overview & Purpose

The `bootstrap_ca_certs` Ansible role is designed to automate the comprehensive management of Public Key Infrastructure (PKI) certificates, facilitating a robust and secure certificate lifecycle within your infrastructure. It leverages `cfssl` for certificate generation and offers seamless integration with **Vault** for secure storage and dynamic issuance. This role streamlines the setup and maintenance of various certificate types, making it ideal for environments requiring a self-managed Certificate Authority (CA).

Enhancement Note (Nov 2025): The role now ensures all certificates, including the self-signed Root CA, include the Authority Key Identifier (AKID) and Subject Key Identifier (SKI) extensions for compliance with strict TLS validators (e.g., Python 3.13's ssl module). This is achieved by using explicit genkey + sign for the Root CA (leveraging custom profiles) and adding extensions to CFSSL profiles.

This role manages the following CA certificate types:

1.  **Root CA**: The foundational trust anchor for your PKI.

2.  **Intermediate Domain Signing Certificates**: CAs used to sign certificates for specific domains, allowing for hierarchical trust and limiting the exposure of the root CA.

3.  **Service Route Certificates**: Leaf certificates issued for specific services or applications, often with Subject Alternative Names (SANs) for DNS names and IP addresses.

4.  **Host / Lead Node Certificates**: Leaf certificates issued to individual servers or nodes within your infrastructure, enabling secure communication and identification.

---

## Objectives

This role aims to achieve the following:

1.  **Create and Validate Root CA Certificate**: Establish the primary trust anchor for your internal PKI.

2.  **Create and Validate Intermediate Certificates**: Generate intermediate CAs that are signed by the root CA, providing a layered security model.

3.  **Create and Validate Service Route Certificates**: Issue specific certificates for applications and services, including custom `alt_names` (DNS and IP SANs).

4.  **Create and Validate Host Node Certificates**: Generate unique certificates for each specified host in your inventory, derived from their host-specific variables.

5.  **Vault Integration**: Optionally, store all generated certificates and their corresponding private keys securely within **Vault**, enabling centralized secret management.  The KV paths are structured as {{ bootstrap_ca_certs__vault_kv_path }}/root_ca, /intermediate/{{ common_name_safe }} and /leaf/{{ common_name_safe }} for better organization and retrieval.

This setup ensures that the role `bootstrap_ca_certs` is the producer of certificates into Vault's KV store, and the role `deploy_pki_certs` is the consumer of those certificates from the KV store.

---

## How It Works: Reusable Certificate Creation and Validation

At its core, this role employs a modular approach for certificate generation:

* **`tasks/validate_cert.yml`**: Before attempting to create any certificate, this task is executed. It inspects the local filesystem for the existence of the certificate (`.pem`) and its corresponding private key (`-key.pem`). It sets a fact, `__missing_or_invalid_cert`, to `true` if either file is missing or if the `force_create` flag is set (e.g., `bootstrap_ca_certs__ca_force_create`, `bootstrap_ca_certs__ca_force_certify_nodes`).

* **`tasks/create_cert.yml`**: This is the central, reusable task for all certificate types. It takes a dictionary variable (`__bootstrap_ca_certs__cert_configs`) containing all necessary details for a single certificate (e.g., common name, type, signer, paths, CFSSL profile). This task is **only executed if `__missing_or_invalid_cert` is `true`**, ensuring idempotency and preventing unnecessary re-generation. Within this task, it handles:

    * Directory creation for certificate storage.

    * CFSSL CSR and key generation.

    * CFSSL signing using the appropriate CA (root or intermediate) and signing profile.

    * Optional **Vault** integration (enabling PKI engine, tuning TTLs, writing certificates, and configuring URLs).

This modular design ensures that the role is efficient, easy to debug, and maintains a clear separation of concerns.

---

## Vault Integration

The role supports storing all generated certificates and keys in **Vault**. To enable this feature, the `bootstrap_ca_certs__vault_enabled` variable must be set to `true`, and the following variables must be configured in your `inventory/group_vars/ca_pki.yml` (or similar):

```yaml
# inventory/group_vars/ca_pki.yml

# Vault integration
bootstrap_ca_certs__vault_enabled: true
bootstrap_ca_certs__vault_url: "[http://127.0.0.1:8200](http://127.0.0.1:8200)"
bootstrap_ca_certs__vault_token: "{{ vault__openbao_token }}" # Securely manage this token!
bootstrap_ca_certs__vault_kv_path: "secret/{{ bootstrap_ca_certs__ca_root_cn }}/ca"
```

## Certificate Storage Structure

The role creates a structured subdirectory system within {{ bootstrap_ca_certs__base_dir }} to store respective certificates and keys for each domain. For example:
```yaml
# {{ bootstrap_ca_certs__base_dir }}/example.com
# {{ bootstrap_ca_certs__base_dir }}/[example.com/cacsr.json](https://example.com/cacsr.json)             - CFSSL CA config for intermediate CA
# {{ bootstrap_ca_certs__base_dir }}/[example.com/ca_key.pem](https://example.com/ca_key.pem)              - Private key for intermediate CA
# {{ bootstrap_ca_certs__base_dir }}/[example.com/ca.csr](https://example.com/ca.csr)                  - CSR for intermediate CA
# {{ bootstrap_ca_certs__base_dir }}/[example.com/ca.pem](https://example.com/ca.pem)                  - Certificate for intermediate CA
# {{ bootstrap_ca_certs__base_dir }}/[example.com/www-1.example.com.csr](https://example.com/www-1.example.com.csr)   - CSR for a service/host
# {{ bootstrap_ca_certs__base_dir }}/[example.com/www-1.example.com-key.pem](https://example.com/www-1.example.com-key.pem) - Private key for a service/host
# {{ bootstrap_ca_certs__base_dir }}/[example.com/www-1.example.com.pem](https://example.com/www-1.example.com.pem)   - Certificate for a service/host
# ... and so on for other certificates within this domain.
```

The Root CA certificate and key will be stored under `{{ bootstrap_ca_certs__base_dir }}/root_ca`.

## Example Playbooks

The role's behavior is controlled by various flags and lists defined in defaults/main.yml. The tasks/main.yml conditionally executes different parts of the role based on these flags.

```yaml
# Global flags for the role (can be overridden in playbook or inventory)
bootstrap_ca_certs__ca_init: yes              # Install and configure the root CA
bootstrap_ca_certs__ca_certify_nodes: yes     # Generate certs for nodes
bootstrap_ca_certs__ca_force_create: yes      # Force creating even if files exist (for CAs)
bootstrap_ca_certs__ca_force_certify_nodes: yes # Force creating of node certificates
```

1. Setting Up the CA Server (Root CA)

An example playbook for initializing the Root CA:

```yaml
- name: Initialize Root CA
  hosts: localhost # or your designated CA server
  become: true
  vars:
    bootstrap_ca_certs__ca_init: yes
    bootstrap_ca_certs__common_name: myrootca.example.com
    bootstrap_ca_certs__country: US
    bootstrap_ca_certs__state: New York
    bootstrap_ca_certs__locality: NYC
    bootstrap_ca_certs__organization: MyCompany
    bootstrap_ca_certs__organizational_unit: Security
  roles:
    - role: bootstrap_ca_certs
```

2. Setting Up Intermediate Certificates

```yaml
- name: Set up Intermediate Certificates
  hosts: ca_pki # or your designated CA server group
  become: true
  vars:
    bootstrap_ca_certs__ca_intermediate_certs_list:
      - common_name: "ca.dettonville.int"
        domain_name: "dettonville.int"
        issuer_name: "{{ bootstrap_ca_certs__common_name }}" # Signed by the root CA
        country: US
        state: "New York"
        locality: "NYC"
        organization: "Dettonville Internal"
        organizational_unit: "Research & Technology"
        email: "admin@dettonville.int"
    
      - common_name: "ca.johnson.int"
        domain_name: "johnson.int"
        issuer_name: "{{ bootstrap_ca_certs__common_name }}" # Signed by the root CA
        country: US
        state: "North Carolina"
        locality: "Raleigh"
        organization: "Johnsonville Internal"
        organizational_unit: "Mostly Impractical"
        email: "admin@johnson.int"
  roles:
    - role: bootstrap_ca_certs

```

3. Setting Up Service Route Certificates

```yaml
- name: Set up Service Route Certificates
  hosts: ca_pki # or your designated CA server group
  become: true
  vars:
    bootstrap_ca_certs__ca_service_routes_list:
      - route: "admin.dettonville.int"
        issuer_name: "ca.dettonville.int" # Signed by the intermediate CA
        alt_names:
          - "DNS.1 = admin.dettonville.int"
          - "IP.1 = 10.0.0.10"
      - route: "app.dettonville.int"
        issuer_name: "ca.dettonville.int"
        alt_names:
          - "DNS.1 = app.dettonville.int"
          - "DNS.2 = app-alias.dettonville.int"
  roles:
    - role: bootstrap_ca_certs
```

4. Setting Up Host Node Leaf Certificates

This role takes a list of inventory host names for which to generate leaf certificates. The role uses the hostvars of each specified host to derive certificate details such as `common_name`, `domain`, and `fqdn`.

```yaml
- hosts: ca_pki # Or target a specific host group where you want to generate certs
  vars:
    bootstrap_ca_certs__ca_certify_node_list:
      - host01
      - host02
      - host03
  roles:
    - role: bootstrap_ca_certs
```

For the host certificate generation to work correctly, ensure that the `hostvars` for each host listed in `bootstrap_ca_certs__ca_certify_node_list` include the necessary `bootstrap_ca_certs__common_name` (optional, defaults to host name), and `bootstrap_ca_certs__domain`. The role will automatically select the appropriate signer (root or intermediate) based on the `bootstrap_ca_certs__domain` configured for the host.

## Example: `inventory/host_vars/host01.yml` for Host Certificates

To provide the necessary context for the `host01` entry in `bootstrap_ca_certs__ca_certify_node_list`, you would define host-specific variables. These variables tell the role how to generate the certificate for `host01`, including its common name, domain, and any additional Subject Alternative Names (SANs).

```yaml
# inventory/host_vars/host01.yml
---
bootstrap_ca_certs__common_name: "host01.myinfra.example.com" # The primary common name for the host certificate
bootstrap_ca_certs__domain: "myinfra.example.com"          # The domain associated with this host
# You can also specify alternative names if needed, though the role derives FQDN and shortname by default
bootstrap_ca_certs__alt_names:
  - "DNS.1 = custom-alias.myinfra.example.com"
  - "IP.1 = 192.168.1.100"
# Optional: if you need a specific CSR profile for this host (defaults to 'server' profile)
# bootstrap_ca_certs__csr_profile: client
```

When the `bootstrap_ca_certs` role processes `host01` from `bootstrap_ca_certs__ca_certify_node_list`, it will look up these `hostvars` to determine the certificate's details and which intermediate CA (if any) should sign it.

## Variables

For a full list of configurable variables and their default values, please refer to `defaults/main.yml`.
