---
title: "Bootstrap Certs Role"
role: bootstrap_certs
category: roles
type: ansible-role
tags: [ansible, role, bootstrap_certs]
---

```yaml
---
title: Bootstrap Certs Role
role: bootstrap_certs
category: Roles
type: Role
summary: |
  The `bootstrap_certs` role is designed to automate the creation, management, and distribution of SSL/TLS certificates for a variety of use cases, including root and intermediate certificate authorities, service routes, and host nodes. This role leverages Ansible's powerful automation capabilities to ensure that certificates are properly generated, validated, and trusted across the infrastructure.

# Variables
## Main Configuration

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `__bootstrap_certs__trust_ca_cert_dir` | `{{ bootstrap_certs__trust_ca_cert_dir | d(__bootstrap_certs__trust_ca_cert_dir_default) }}` | Directory where trusted CA certificates are stored. |
| `__bootstrap_certs__trust_ca_update_trust_cmd` | `{{ bootstrap_certs__trust_ca_update_trust_cmd | d(__bootstrap_certs__trust_ca_update_trust_cmd_default) }}` | Command to update the CA trust store. |
| `__bootstrap_certs__ca_java_keystore` | `{{ bootstrap_certs__ca_java_keystore | d(__bootstrap_certs__ca_java_keystore_default) }}` | Path to the Java keystore. |
| `bootstrap_certs__required_pip_libs` | `['pexpect', 'cryptography', 'pyOpenSSL']` | List of required Python libraries for the role. |
| `bootstrap_certs__display_ca_result` | `true` | Whether to display CA result information. |
| `bootstrap_certs__ca_init` | `true` | Whether to initialize the CA. |
| `bootstrap_certs__ca_certify_nodes` | `true` | Whether to certify nodes. |
| `bootstrap_certs__ca_certify_routes` | `true` | Whether to certify service routes. |
| `bootstrap_certs__ca_certify_node_list` | `[]` | List of nodes to certify. |
| `bootstrap_certs__ca_force_create` | `false` | Whether to force the creation of certificates. |
| `bootstrap_certs__ca_force_certify_nodes` | `false` | Whether to force the certification of nodes. |
| `bootstrap_certs__ca_force_distribute_nodes` | `false` | Whether to force the distribution of certificates to nodes. |
| `bootstrap_certs__trust_certs` | `true` | Whether to trust the certificates. |
| `bootstrap_certs__ca_fetch_certs` | `true` | Whether to fetch certificates from the keystore. |
| `bootstrap_certs__keystore_base_dir` | `/usr/share/ca-certs` | Base directory for the keystore. |
| `bootstrap_certs__ca_key_dir` | `/etc/ssl/private` | Directory where CA private keys are stored. |
| `bootstrap_certs__ca_root_cn` | `ca-root` | Common name for the root CA. |
| `bootstrap_certs__pki_ca_root_key` | `{{ bootstrap_certs__ca_root_cn }}-key.pem` | Path to the root CA private key. |
| `bootstrap_certs__ca_reset_local_certs` | `false` | Whether to reset local certificates. |
| `bootstrap_certs__ca_local_cert_dir` | `/usr/local/ssl/certs` | Directory where local certificates are stored. |
| `bootstrap_certs__ca_local_key_dir` | `/usr/local/ssl/private` | Directory where local private keys are stored. |
| `bootstrap_certs__ca_java_keystore_enabled` | `true` | Whether the Java keystore is enabled. |
| `bootstrap_certs__ca_java_keystore_pass` | `changeit` | Password for the Java keystore. |
| `bootstrap_certs__trust_ca_cert_extension` | `pem` | File extension for trusted CA certificates. |
| `bootstrap_certs__admin_user` | `{{ ansible_local_user | d(ansible_user) }}` | Admin user for the role. |
| `bootstrap_certs__base_dir` | `{{ '~/pki' | expanduser }}` | Base directory for the role. |
| `bootstrap_certs__certs_dir` | `{{ bootstrap_certs__base_dir }}/certs` | Directory where certificates are stored. |
| `bootstrap_certs__keys_dir` | `{{ bootstrap_certs__base_dir }}/keys` | Directory where private keys are stored. |
| `__bootstrap_certs__ca_cert_expiration_panic_threshold` | `604800` (1 week) | Threshold for certificate expiration warnings. |
| `bootstrap_certs__ca_domains_hosted` | `[]` | List of domains hosted by the CA. |
| `bootstrap_certs__ca_root` | `{"domain_name": "{{ bootstrap_certs__ca_root_cn }}", "common_name": "Example LLC", "country": "US", "state": "New York", "locality": "New York", "organization": "Example LLC", "organizational_unit": "Research", "email": "caroot@example.com"}` | Root CA configuration. |
| `bootstrap_certs__ca_root_subject` | `/C={{ bootstrap_certs__ca_root.country }}/ST={{ bootstrap_certs__ca_root.state }}/L={{ bootstrap_certs__ca_root.locality }}/O={{ bootstrap_certs__ca_root.organization }}/OU={{ bootstrap_certs__ca_root.organizational_unit }}/CN={{ bootstrap_certs__ca_root.domain_name }}/emailAddress={{ bootstrap_certs__ca_root.email }}` | Subject for the root CA certificate. |
| `bootstrap_certs__ca_root_cert_validity_days` | `3650` | Validity period for the root CA certificate in days. |
| `bootstrap_certs__ca_root_cert_digest` | `sha` | Digest algorithm for the root CA certificate. |

# Usage
To use the `bootstrap_certs` role, include it in your playbook and configure the necessary variables. Here is an example playbook:

```yaml
---
- hosts: all
  roles:
    - role: bootstrap_certs
      vars:
        bootstrap_certs__ca_root_cn: "my-ca-root"
        bootstrap_certs__ca_root:
          domain_name: "my-ca-root"
          common_name: "My Company LLC"
          country: "US"
          state: "California"
          locality: "San Francisco"
          organization: "My Company LLC"
          organizational_unit: "IT"
          email: "admin@mycompany.com"
```

# Dependencies
This role requires the following Python libraries to be installed:
- pexpect
- cryptography
- pyOpenSSL

These dependencies will be automatically installed if they are not already present on the system.

# Best Practices
- Ensure that the `bootstrap_certs__ca_root` variable is properly configured with the correct information for your organization.
- Regularly review and update the certificate expiration threshold (`__bootstrap_certs__ca_cert_expiration_panic_threshold`) to ensure that certificates are renewed before they expire.
- Use the `bootstrap_certs__ca_force_create` variable to force the creation of new certificates when necessary.
- Keep the Java keystore password (`bootstrap_certs__ca_java_keystore_pass`) secure and consider using a more secure password than the default `changeit`.

# Backlinks
- [roles/bootstrap_certs/defaults/main.yml](../../roles/bootstrap_certs/defaults/main.yml)
- [roles/bootstrap_certs/handlers/main.yml](../../roles/bootstrap_certs/handlers/main.yml)
- [roles/bootstrap_certs/tasks/create_caroot.yml](../../roles/bootstrap_certs/tasks/create_caroot.yml)
- [roles/bootstrap_certs/tasks/create_cert.yml](../../roles/bootstrap_certs/tasks/create_cert.yml)
- [roles/bootstrap_certs/tasks/fetch_certs.yml](../../roles/bootstrap_certs/tasks/fetch_certs.yml)
- [roles/bootstrap_certs/tasks/get_ca_common_facts.yml](../../roles/bootstrap_certs/tasks/get_ca_common_facts.yml)
- [roles/bootstrap_certs/tasks/get_cert_facts.yml](../../roles/bootstrap_certs/tasks/get_cert_facts.yml)
- [roles/bootstrap_certs/tasks/main.yml](../../roles/bootstrap_certs/tasks/main.yml)
- [roles/bootstrap_certs/tasks/trust_cert.yml](../../roles/bootstrap_certs/tasks/trust_cert.yml)
- [roles/bootstrap_certs/tasks/validate_cacerts.yml](../../roles/bootstrap_certs/tasks/validate_cacerts.yml)