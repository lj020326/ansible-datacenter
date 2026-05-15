---
title: Bootstrap Certificates Role Documentation
role: bootstrap_certs
category: Security
type: Ansible Role
tags: certificates, ssl, tls, cfssl, openssl, java-keystore
---

## Summary

The `bootstrap_certs` role is designed to automate the creation and management of SSL/TLS certificates using OpenSSL and CFSSL. It handles the generation of root and intermediate Certificate Authorities (CAs), as well as server and service route certificates. The role also manages the trust of these certificates on target nodes, including updating system CA stores and Java keystores.

## Variables

| Variable Name                             | Default Value                                                                                         | Description                                                                                                                                                                                                 |
|-------------------------------------------|-------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_certs__required_pip_libs`      | `['pexpect', 'cryptography', 'pyOpenSSL']`                                                            | List of Python libraries required for the role.                                                                                                                                                               |
| `bootstrap_certs__display_ca_result`      | `true`                                                                                                | Whether to display certificate generation results.                                                                                                                                                            |
| `bootstrap_certs__ca_init`                | `true`                                                                                                | Whether to initialize the CA (create root and intermediate CAs).                                                                                                                                            |
| `bootstrap_certs__ca_certify_nodes`       | `true`                                                                                                | Whether to generate certificates for specified nodes.                                                                                                                                                       |
| `bootstrap_certs__ca_certify_routes`      | `true`                                                                                                | Whether to generate certificates for service routes.                                                                                                                                                        |
| `bootstrap_certs__ca_certify_node_list`   | `[]`                                                                                                  | List of nodes to generate certificates for.                                                                                                                                                                 |
| `bootstrap_certs__ca_force_create`        | `false`                                                                                               | Force creation of CA and certificates even if they already exist.                                                                                                                                         |
| `bootstrap_certs__ca_force_certify_nodes` | `false`                                                                                               | Force certificate generation for nodes even if they already have valid certificates.                                                                                                                      |
| `bootstrap_certs__ca_force_distribute_nodes` | `false`                                                                                            | Force distribution of certificates to nodes even if they are up-to-date.                                                                                                                                   |
| `bootstrap_certs__trust_certs`            | `true`                                                                                                | Whether to trust the generated certificates on target nodes.                                                                                                                                              |
| `bootstrap_certs__ca_fetch_certs`         | `true`                                                                                                | Whether to fetch and distribute certificates from the keystore.                                                                                                                                             |
| `bootstrap_certs__keystore_base_dir`      | `/usr/share/ca-certs`                                                                                 | Base directory for storing CA certificates.                                                                                                                                                                 |
| `bootstrap_certs__ca_key_dir`             | `/etc/ssl/private`                                                                                    | Directory for storing private keys.                                                                                                                                                                         |
| `bootstrap_certs__ca_root_cn`             | `ca-root`                                                                                             | Common name for the root CA.                                                                                                                                                                                |
| `bootstrap_certs__pki_ca_root_key`        | `{{ bootstrap_certs__ca_root_cn }}-key.pem`                                                             | Filename for the root CA private key.                                                                                                                                                                       |
| `bootstrap_certs__ca_reset_local_certs`   | `false`                                                                                               | Whether to reset local certificates by removing existing ones.                                                                                                                                            |
| `bootstrap_certs__ca_local_cert_dir`      | `/usr/local/ssl/certs`                                                                                | Directory for storing local CA certificates.                                                                                                                                                                |
| `bootstrap_certs__ca_local_key_dir`       | `/usr/local/ssl/private`                                                                              | Directory for storing local private keys.                                                                                                                                                                   |
| `bootstrap_certs__ca_java_keystore_enabled` | `true`                                                                                               | Whether to manage Java keystore with generated certificates.                                                                                                                                                |
| `bootstrap_certs__ca_java_keystore_pass`  | `changeit`                                                                                            | Password for the Java keystore.                                                                                                                                                                             |
| `bootstrap_certs__trust_ca_cert_extension`| `pem`                                                                                                 | File extension for trusted CA certificates.                                                                                                                                                                 |
| `bootstrap_certs__admin_user`             | `{{ ansible_local_user \| d(ansible_user) }}`                                                         | User under which the role will run administrative tasks.                                                                                                                                                    |
| `bootstrap_certs__base_dir`               | `~/pki`                                                                                               | Base directory for PKI operations.                                                                                                                                                                          |
| `bootstrap_certs__certs_dir`              | `{{ bootstrap_certs__base_dir }}/certs`                                                                | Directory for storing generated certificates.                                                                                                                                                                 |
| `bootstrap_certs__keys_dir`               | `{{ bootstrap_certs__base_dir }}/keys`                                                                 | Directory for storing generated private keys.                                                                                                                                                               |
| `bootstrap_certs__ca_root`                | `{ domain_name: "ca-root", common_name: "Example LLC", country: "US", state: "New York", locality: "New York", organization: "Example LLC", organizational_unit: "Research", email: "caroot@example.com" }` | Configuration for the root CA.                                                                                                                                                                              |
| `bootstrap_certs__ca_root_subject`        | `/C={{ bootstrap_certs__ca_root.country }}/ST={{ bootstrap_certs__ca_root.state }}/L={{ bootstrap_certs__ca_root.locality }}/O={{ bootstrap_certs__ca_root.organization }}/OU={{ bootstrap_certs__ca_root.organizational_unit }}/CN={{ bootstrap_certs__ca_root.domain_name }}/emailAddress={{ bootstrap_certs__ca_root.email }}` | Subject string for the root CA certificate.                                                                                                                                                                 |
| `bootstrap_certs__ca_root_cert_validity_days` | `3650`                                                                                             | Validity period (in days) for the root CA certificate.                                                                                                                                                    |

## Usage
To use the `bootstrap_certs` role, include it in your playbook and configure the necessary variables as needed. Below is an example of how to include the role in a playbook:

```yaml
- name: Bootstrap certificates on target nodes
  hosts: all
  become: yes
  roles:
    - role: bootstrap_certs
      vars:
        bootstrap_certs__ca_certify_node_list:
          - node1.example.com
          - node2.example.com
```

## Dependencies
The `bootstrap_certs` role depends on the following:

- Ansible modules: `community.crypto.openssl_privatekey`, `community.crypto.openssl_csr`
- Python libraries: `pexpect`, `cryptography`, `pyOpenSSL`
- System packages: `openssl`

Ensure these dependencies are installed before running the role.

## Tags
The `bootstrap_certs` role uses tags to allow selective execution of tasks. The available tags are:

- `ca_init`: Initialize CA (create root and intermediate CAs).
- `certify_nodes`: Generate certificates for specified nodes.
- `certify_routes`: Generate certificates for service routes.
- `fetch_certs`: Fetch and distribute certificates from the keystore.
- `trust_certs`: Trust generated certificates on target nodes.

Example of running tasks with a specific tag:

```bash
ansible-playbook -i inventory playbook.yml --tags ca_init
```

## Best Practices
- **Backup Existing Certificates**: Before running the role, ensure you have backups of any existing certificates and keys.
- **Secure Passwords**: Use secure passwords for Java keystores and other sensitive data. Consider using Ansible Vault to manage secrets.
- **Review Configurations**: Review and customize the CA configurations (`bootstrap_certs__ca_root`) as per your organization's requirements.

## Molecule Tests
This role does not include Molecule tests at this time. However, it is recommended to write and run tests to ensure the role behaves as expected in different environments.

## Backlinks
- [defaults/main.yml](../../roles/bootstrap_certs/defaults/main.yml)
- [tasks/create_caroot.yml](../../roles/bootstrap_certs/tasks/create_caroot.yml)
- [tasks/create_cert.yml](../../roles/bootstrap_certs/tasks/create_cert.yml)
- [tasks/fetch_certs.yml](../../roles/bootstrap_certs/tasks/fetch_certs.yml)
- [tasks/get_ca_common_facts.yml](../../roles/bootstrap_certs/tasks/get_ca_common_facts.yml)
- [tasks/get_cert_facts.yml](../../roles/bootstrap_certs/tasks/get_cert_facts.yml)
- [tasks/main.yml](../../roles/bootstrap_certs/tasks/main.yml)
- [tasks/trust_cert.yml](../../roles/bootstrap_certs/tasks/trust_cert.yml)
- [tasks/validate_cacerts.yml](../../roles/bootstrap_certs/tasks/validate_cacerts.yml)
- [handlers/main.yml](../../roles/bootstrap_certs/handlers/main.yml)