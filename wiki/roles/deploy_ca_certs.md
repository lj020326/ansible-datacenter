---
title: Deploy CA Certs Role Documentation
role: deploy_ca_certs
category: Security
type: Ansible Role
tags: ca-certs, ssl, certificates, step-ca, truststore
---

## Summary

The `deploy_ca_certs` role is designed to automate the deployment and management of Certificate Authority (CA) certificates on target hosts. It supports fetching CA certificates from a keystore or using Step CA for certificate issuance, deploying intermediate certificates, validating certificates, and updating system truststores and Java keystores as needed.

## Variables

| Variable Name                                            | Default Value                                                                                                   | Description                                                                               |
|----------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|
| `deploy_ca_certs__ca_domain`                             | `example.com`                                                                                                   | The domain name for the CA certificates.                                                  |
| `deploy_ca_certs__using_stepca`                          | `false`                                                                                                         | Boolean flag to indicate if Step CA should be used for certificate issuance.              |
| `deploy_ca_certs__deploy_intermediate_certs`             | `true`                                                                                                          | Boolean flag to determine whether intermediate certificates should be deployed.           |
| `deploy_ca_certs__stepca_start_service`                  | `true`                                                                                                          | Boolean flag to start the Step CA renewal service if using Step CA.                       |
| `deploy_ca_certs__validate_certs`                        | `true`                                                                                                          | Boolean flag to validate certificates after deployment.                                   |
| `deploy_ca_certs__deploy_host_certs`                     | `true`                                                                                                          | Boolean flag to deploy host-specific certificates.                                        |
| `deploy_ca_certs__create_cert_bundle`                    | `true`                                                                                                          | Boolean flag to create a certificate bundle file.                                         |
| `deploy_ca_certs__ca_reset_local_certs`                  | `true`                                                                                                          | Boolean flag to reset local certificates by removing existing ones before deployment.     |
| `deploy_ca_certs__trust_ca_cert_dir`                     | (default value defined in role)                                                                                 | Directory where trusted CA certificates will be stored.                                   |
| `deploy_ca_certs__trust_ca_update_trust_cmd`             | (default value defined in role)                                                                                 | Command to update the system's CA truststore after new certificates are added.            |
| `deploy_ca_certs__ca_java_keystore`                      | (default value defined in role)                                                                                 | Path to the Java keystore file where certificates will be imported.                       |
| `deploy_ca_certs__script_dir`                            | `/opt/scripts`                                                                                                  | Directory where utility scripts for certificate management will be stored.                |
| `deploy_ca_certs__keystore_cert_base_dir`                | `/usr/share/ca-certs`                                                                                           | Base directory on the keystore host where certificates are stored.                        |
| `deploy_ca_certs__keystore_host`                         | `ca01.example.int`                                                                                              | Hostname of the CA keystore server.                                                       |
| `deploy_ca_certs__keystore_inventory_hostname`           | `ca01`                                                                                                          | Inventory hostname for the CA keystore server.                                            |
| `deploy_ca_certs__keystore_hostusing_stepca`             | `false`                                                                                                         | Boolean flag indicating if the keystore host uses Step CA.                                |
| `deploy_ca_certs__keystore_python_interpreter`           | `/usr/bin/python3`                                                                                              | Path to the Python interpreter on the keystore host used for slurping certificates.       |
| `deploy_ca_certs__hostname_full`                         | `"{{ inventory_hostname_short }}.{{ deploy_ca_certs__ca_domain }}"`                                             | Full hostname of the target node, constructed from inventory data and domain variable.    |
| `deploy_ca_certs__stepca_host_url`                       | `https://stepca.example.int/`                                                                                   | URL for the Step CA server.                                                               |
| `deploy_ca_certs__stepca_acme_http_challenge_proxy_port` | `6980`                                                                                                          | Port used for ACME HTTP challenge proxy when using Step CA.                               |
| `deploy_ca_certs__ca_root_cn`                            | `ca-root`                                                                                                       | Common Name (CN) of the root certificate.                                                 |
| `deploy_ca_certs__pki_ca_root_cert`                      | `"{{ deploy_ca_certs__ca_root_cn }}.pem"`                                                                       | Filename for the root CA certificate in PEM format.                                       |
| `deploy_ca_certs__ca_key_dir`                            | `/etc/ssl/private`                                                                                              | Directory where private keys are stored.                                                  |
| `deploy_ca_certs__local_cert_dir`                        | `/usr/local/ssl/certs`                                                                                          | Local directory on target nodes where certificates will be deployed.                      |
| `deploy_ca_certs__local_key_dir`                         | `/usr/local/ssl/private`                                                                                        | Local directory on target nodes where private keys will be stored.                        |
| `deploy_ca_certs__ca_java_keystore_enabled`              | `true`                                                                                                          | Boolean flag to enable importing certificates into the Java keystore.                     |
| `deploy_ca_certs__ca_java_keystore_pass`                 | `changeit`                                                                                                      | Password for the Java keystore.                                                           |
| `deploy_ca_certs__trust_ca_cert_extension`               | `pem`                                                                                                           | File extension for trusted CA certificates.                                               |
| `deploy_ca_certs__keystore_admin_user`                   | `"{{ ansible_ssh_user }}"`                                                                                      | Username used to access the keystore host.                                                |
| `deploy_ca_certs__ca_provisioner`                        | `acme`                                                                                                          | Provisioning method for CA certificates (e.g., ACME).                                     |
| `deploy_ca_certs__ca_intermediate_certs_list`            | List of intermediate certificate details, e.g., `[ { domain_name: example.com, common_name: ca.example.com } ]` | List of intermediate certificates to be deployed.                                         |
| `deploy_ca_certs__ca_service_routes_list`                | List of service routes, e.g., `[ { route: route-1.example.com }, { route: route-2.example.com } ]`              | List of service routes for which certificates will be managed.                            |
| `deploy_ca_certs__external_ca_cert_list`                 | `[]`                                                                                                            | List of external CA certificates to trust, e.g., `[ "https://external-ca.example.com" ]`. |

## Usage

To use the `deploy_ca_certs` role, include it in your playbook and configure the necessary variables as needed. Here is an example playbook snippet:

```yaml
- name: Deploy CA Certificates
  hosts: all
  roles:
    - role: deploy_ca_certs
      vars:
        deploy_ca_certs__ca_domain: mydomain.com
        deploy_ca_certs__using_stepca: true
        deploy_ca_certs__stepca_host_url: https://my-step-ca.example.int/
```

## Dependencies

- `bootstrap_systemd_service` role (used for setting up the Step CA renewal service).

## Best Practices

1. **Backup Existing Certificates**: Ensure that existing certificates are backed up before deploying new ones.
2. **Use Strong Passwords**: Use strong and unique passwords for Java keystores.
3. **Validate Certificates**: Always validate certificates after deployment to ensure they are correctly installed and trusted.

## Molecule Tests

This role does not currently include Molecule tests, but it is recommended to set up tests to verify the functionality of certificate deployment and truststore updates.

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