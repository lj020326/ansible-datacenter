---
title: "Deploy Ca Certs Role"
role: roles/deploy_ca_certs
category: Roles
type: ansible-role
tags: [ansible, role, deploy_ca_certs]
---

# Deploy CA Certs Role Documentation

## Purpose

The `deploy_ca_certs` Ansible role is designed to deploy and manage CA certificates on a system. It provides a comprehensive solution for fetching, distributing, and trusting CA certificates, including root and intermediate certificates. The role supports both traditional CA certificate management and integration with StepCA for automated certificate renewal.

## Variables

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `deploy_ca_certs__ca_domain` | `example.com` | The domain of the CA. |
| `deploy_ca_certs__using_stepca` | `false` | Boolean to indicate if StepCA is being used. |
| `deploy_ca_certs__deploy_intermediate_certs` | `true` | Boolean to indicate if intermediate certificates should be deployed. |
| `deploy_ca_certs__stepca_start_service` | `true` | Boolean to indicate if the StepCA service should be started. |
| `deploy_ca_certs__validate_certs` | `true` | Boolean to indicate if certificates should be validated. |
| `deploy_ca_certs__deploy_host_certs` | `true` | Boolean to indicate if host certificates should be deployed. |
| `deploy_ca_certs__create_cert_bundle` | `true` | Boolean to indicate if a certificate bundle should be created. |
| `deploy_ca_certs__ca_reset_local_certs` | `true` | Boolean to indicate if local certificates should be reset. |
| `deploy_ca_certs__keystore_cert_base_dir` | `/usr/share/ca-certs` | Base directory for keystore certificates. |
| `deploy_ca_certs__keystore_host` | `ca01.example.int` | Hostname of the keystore. |
| `deploy_ca_certs__keystore_inventory_hostname` | `ca01` | Inventory hostname of the keystore. |
| `deploy_ca_certs__keystore_hostusing_stepca` | `false` | Boolean to indicate if the keystore host is using StepCA. |
| `deploy_ca_certs__keystore_python_interpreter` | `/usr/bin/python3` | Python interpreter to use for keystore operations. |
| `deploy_ca_certs__hostname_full` | `{{ inventory_hostname_short }}.{{ deploy_ca_certs__ca_domain }}` | Fully qualified hostname. |
| `deploy_ca_certs__stepca_host_url` | `https://stepca.example.int/` | URL of the StepCA host. |
| `deploy_ca_certs__ca_root_cn` | `ca-root` | Common name of the CA root certificate. |
| `deploy_ca_certs__pki_ca_root_cert` | `{{ deploy_ca_certs__ca_root_cn }}.pem` | Path to the CA root certificate. |
| `deploy_ca_certs__ca_key_dir` | `/etc/ssl/private` | Directory for CA keys. |
| `deploy_ca_certs__local_cert_dir` | `/usr/local/ssl/certs` | Directory for local certificates. |
| `deploy_ca_certs__local_key_dir` | `/usr/local/ssl/private` | Directory for local keys. |
| `deploy_ca_certs__ca_java_keystore_enabled` | `true` | Boolean to indicate if the Java keystore is enabled. |
| `deploy_ca_certs__ca_java_keystore_pass` | `changeit` | Password for the Java keystore. |
| `deploy_ca_certs__trust_ca_cert_extension` | `pem` | Extension for trusted CA certificates. |
| `deploy_ca_certs__keystore_admin_user` | `{{ ansible_ssh_user }}` | Admin user for keystore operations. |
| `deploy_ca_certs__ca_provisioner` | `acme` | Provisioner for the CA. |
| `deploy_ca_certs__ca_intermediate_certs_list` | `[{"domain_name": "example.com", "common_name": "ca.example.com"}]` | List of intermediate certificates. |
| `deploy_ca_certs__ca_service_routes_list` | `[{"route": "route-1.example.com"}, {"route": "route-2.example.com"}]` | List of service routes. |
| `deploy_ca_certs__external_ca_cert_list` | `[]` | List of external CA certificates. |

## Usage

To use the `deploy_ca_certs` role, include it in your playbook and define the necessary variables. Here is an example playbook:

```yaml
---
- hosts: all
  roles:
    - role: deploy_ca_certs
      vars:
        deploy_ca_certs__ca_domain: "example.com"
        deploy_ca_certs__using_stepca: false
        deploy_ca_certs__deploy_intermediate_certs: true
        deploy_ca_certs__stepca_start_service: true
        deploy_ca_certs__validate_certs: true
        deploy_ca_certs__deploy_host_certs: true
        deploy_ca_certs__create_cert_bundle: true
        deploy_ca_certs__ca_reset_local_certs: true
```

## Dependencies

This role does not have any external dependencies. However, it assumes that the necessary directories and files exist on the target system.

## Best Practices

1. **Use StepCA for Automated Renewal**: If you are using StepCA, ensure that the StepCA service is properly configured and running.
2. **Validate Certificates**: Always validate certificates to ensure they are correctly deployed and trusted.
3. **Reset Local Certificates**: Reset local certificates if you are deploying new certificates to avoid conflicts.
4. **Secure Keystore**: Ensure that the keystore is secured and that the password is kept confidential.

## Backlinks

- [defaults/main.yml](../../roles/deploy_ca_certs/defaults/main.yml)
- [tasks/fetch_certs.yml](../../roles/deploy_ca_certs/tasks/fetch_certs.yml)
- [tasks/fetch_certs_stepca.yml](../../roles/deploy_ca_certs/tasks/fetch_certs_stepca.yml)
- [tasks/get_cert_facts.yml](../../roles/deploy_ca_certs/tasks/get_cert_facts.yml)
- [tasks/main.yml](../../roles/deploy_ca_certs/tasks/main.yml)
- [tasks/slurp_from_to.yml](../../roles/deploy_ca_certs/tasks/slurp_from_to.yml)
- [tasks/stepca_renewal_service.yml](../../roles/deploy_ca_certs/tasks/stepca_renewal_service.yml)
- [tasks/trust_cert.yml](../../roles/deploy_ca_certs/tasks/trust_cert.yml)
- [tasks/trust_external_certs.yml](../../roles/deploy_ca_certs/tasks/trust_external_certs.yml)
- [handlers/main.yml](../../roles/deploy_ca_certs/handlers/main.yml)