---
title: Bootstrap StepCA Role Documentation
role: bootstrap_stepca
category: Infrastructure
type: Ansible Role
tags: stepca, certificate-authority, automation

## Summary
The `bootstrap_stepca` role is designed to automate the installation and configuration of a Step Certificate Authority (StepCA) server on Debian-based systems. It handles the setup of necessary directories, downloads and installs required packages, generates and manages SSL certificates, configures systemd services, sets up databases for storing certificate data, and optionally configures Certificate Transparency (CT) logging services.

## Variables

| Variable Name                           | Default Value                                                                                   | Description                                                                                                                                                                                                 |
|-----------------------------------------|-------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `stepca_local_cert_dir`                 | `/usr/local/ssl/certs`                                                                          | Directory where local certificates will be stored.                                                                                                                                                          |
| `stepca_local_key_dir`                  | `/usr/local/ssl/private`                                                                        | Directory where local private keys will be stored.                                                                                                                                                          |
| `stepca_install_service`                | `true`                                                                                          | Whether to install and configure the StepCA renewal service.                                                                                                                                                |
| `stepca_hostname_full`                  | `{{ ansible_facts['fqdn'] }}`                                                                   | Full hostname of the server, defaults to the FQDN of the host.                                                                                                                                              |
| `stepca__src`                           | `/var/lib/src/stepca`                                                                           | Source directory for downloading and storing StepCA packages.                                                                                                                                             |
| `stepca__cli_package_url`               | `https://github.com/smallstep/cli/releases/download/v0.15.16/step-cli_0.15.16_amd64.deb`       | URL to download the Step CLI package.                                                                                                                                                                       |
| `stepca_cli_bin_dir`                    | `/usr/local/bin`                                                                                | Directory where the Step CLI binary will be installed.                                                                                                                                                    |
| `stepca__deb_url`                       | `https://github.com/smallstep/certificates/releases/download/v0.15.8/step-certificates_0.15.8_amd64.deb` | URL to download the StepCA server package.                                                                                                                                                                  |
| `stepca_host_url`                       | `https://stepca.example.int/`                                                                    | Base URL for the StepCA server.                                                                                                                                                                             |
| `stepca_ca_server`                      | `false`                                                                                         | Whether to install and configure the StepCA server components.                                                                                                                                            |
| `stepca_svc_user`                       | `step`                                                                                            | System user under which StepCA services will run.                                                                                                                                                           |
| `stepca_apps`                           | List of StepCA applications (e.g., stepca-ca, stepca-ra, etc.)                                    | List of StepCA application components to be installed and configured.                                                                                                                                       |
| `stepca_services`                       | List of StepCA systemd service names                                                              | List of systemd services related to StepCA that will be managed by this role.                                                                                                                               |
| `ctfe_server_http`                      | `4011`                                                                                            | Port number for the Certificate Transparency Front End (CTFE) server HTTP interface.                                                                                                                          |
| `app_conf`                              | Configuration details for various StepCA applications                                             | Detailed configuration settings for different StepCA components, including network ports and features.                                                                                                        |

## Usage
To use this role, include it in your playbook and configure the necessary variables as per your environment. Here is an example of how to include this role in a playbook:

```yaml
- name: Bootstrap Step Certificate Authority Server
  hosts: stepca_servers
  become: true
  roles:
    - role: bootstrap_stepca
      vars:
        stepca_ca_server: true
        stepca_host_url: https://your-ca-server.example.com/
```

## Dependencies
This role depends on the following Ansible collections and modules:

- `community.crypto`
- `ansible.builtin` (standard Ansible modules)
- `ansible.mysql` (for database management tasks)

Ensure these are installed in your environment before running this role.

## Best Practices
1. **Security**: Ensure that all sensitive data, such as private keys, are stored securely and access is restricted.
2. **Backup**: Regularly back up configuration files and databases to prevent data loss.
3. **Monitoring**: Implement monitoring for StepCA services to ensure they are running correctly and respond promptly to any issues.

## Molecule Tests
This role includes Molecule tests to verify its functionality. To run the tests, navigate to the role directory and execute:

```bash
molecule test
```

Ensure you have Molecule installed in your environment before running the tests.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_stepca/defaults/main.yml)
- [tasks/fetch-stepca-fingerprint.yml](../../roles/bootstrap_stepca/tasks/fetch-stepca-fingerprint.yml)
- [tasks/install-debian.yml](../../roles/bootstrap_stepca/tasks/install-debian.yml)
- [tasks/main.yml](../../roles/bootstrap_stepca/tasks/main.yml)
- [tasks/02-stepca-server.yml](../../roles/bootstrap_stepca/tasks/server/02-stepca-server.yml)
- [tasks/02-stepcaconfigs.yml](../../roles/bootstrap_stepca/tasks/server/02-stepcaconfigs.yml)
- [tasks/03-stepcasystemd.yml](../../roles/bootstrap_stepca/tasks/server/03-stepcasystemd.yml)
- [tasks/04-cafiles.yml](../../roles/bootstrap_stepca/tasks/server/04-cafiles.yml)
- [tasks/05-grpcpki.yml](../../roles/bootstrap_stepca/tasks/server/05-grpcpki.yml)
- [tasks/06-installdatabase.yml](../../roles/bootstrap_stepca/tasks/server/06-installdatabase.yml)
- [tasks/07-ctlogconfigs.yml](../../roles/bootstrap_stepca/tasks/server/07-ctlogconfigs.yml)
- [tasks/setup-stepca-cli.yml](../../roles/bootstrap_stepca/tasks/setup-stepca-cli.yml)
- [tasks/setup-stepca-renew-service.yml](../../roles/bootstrap_stepca/tasks/setup-stepca-renew-service.yml)
- [tasks/setup-stepca-server.yml](../../roles/bootstrap_stepca/tasks/server/setup-stepca-server.yml)
- [handlers/main.yml](../../roles/bootstrap_stepca/handlers/main.yml)