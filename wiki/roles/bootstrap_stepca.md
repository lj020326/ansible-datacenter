---
title: "Bootstrap Stepca Role"
role: roles/bootstrap_stepca
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_stepca]
---

# Role Documentation: `bootstrap_stepca`

## Overview

The `bootstrap_stepca` Ansible role is designed to automate the installation and configuration of Smallstep CA (StepCA) on a Debian-based system. This role handles the setup of both the Step CLI and the Step CA server, including generating necessary certificates, configuring services, and setting up databases.

## Role Variables

### Default Variables (`defaults/main.yml`)

| Variable Name                          | Description                                                                                           | Default Value                                                                 |
|----------------------------------------|-------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------|
| `stepca_local_cert_dir`                | Directory where local certificates will be stored.                                                  | `/usr/local/ssl/certs`                                                        |
| `stepca_local_key_dir`                 | Directory where local keys will be stored.                                                            | `/usr/local/ssl/private`                                                      |
| `stepca_install_service`               | Whether to install the Step CA renewal service.                                                     | `true`                                                                        |
| `stepca_hostname_full`                 | Full hostname of the server, defaults to the system's FQDN.                                         | `{{ ansible_facts['fqdn'] }}`                                                  |
| `stepca__src`                          | Source directory for downloading packages and other files.                                          | `/var/lib/src/stepca`                                                         |
| `stepca__cli_package_url`              | URL to download the Step CLI package.                                                               | `https://github.com/smallstep/cli/releases/download/v0.15.16/step-cli_0.15.16_amd64.deb` |
| `stepca_cli_bin_dir`                   | Directory where the Step CLI binary will be installed.                                              | `/usr/local/bin`                                                              |
| `stepca__deb_url`                      | URL to download the Step CA package.                                                                | `https://github.com/smallstep/certificates/releases/download/v0.15.8/step-certificates_0.15.8_amd64.deb` |
| `stepca_host_url`                      | Base URL for the Step CA server.                                                                    | `https://stepca.example.int/`                                                  |
| `stepca_ca_server`                     | Whether to install and configure the Step CA server.                                                | `false`                                                                       |
| `stepca_svc_user`                      | User under which the Step CA services will run.                                                     | `step`                                                                        |
| `stepca_apps`                          | List of applications that make up the Step CA server.                                               | See `defaults/main.yml`                                                       |
| `stepca_services`                      | List of systemd services to be managed by Ansible.                                                  | See `defaults/main.yml`                                                       |
| `ctfe_server_http`                     | HTTP port for the CTFE (Certificate Transparency Front End) server.                                 | `4011`                                                                        |
| `app_conf`                             | Configuration settings for various Step CA components.                                              | See `defaults/main.yml`                                                       |

## Tasks

### `fetch-stepca-fingerprint.yml`

- **Purpose**: Fetches the root CA fingerprint from the Step CA server.
- **Tasks**:
  - Display the `stepca_host_url`.
  - Use `uri` module to fetch the root CA certificate.
  - Decode and store the root CA fingerprint.

### `install-debian.yml`

- **Purpose**: Installs the Step CLI and optionally the Step CA server on Debian-based systems.
- **Tasks**:
  - Include OS-specific variables.
  - Setup Step CLI.
  - Conditionally setup Step CA server if `stepca_ca_server` is true.

### `main.yml`

- **Purpose**: Main entry point for the role, which includes tasks to install and configure both the Step CLI and optionally the Step CA server.
- **Tasks**:
  - Include OS-specific variables.
  - Setup Step CLI.
  - Conditionally setup Step CA server if `stepca_ca_server` is true.

### `02-stepca-server.yml`

- **Purpose**: Installs and configures the Step CA server.
- **Tasks**:
  - Ensure directories for secret materials exist.
  - Check if issuing CA materials exist.
  - Install Golang.
  - Stop running services that could interfere.
  - Download, verify, and install the Step CA package.
  - Create service account and installation directories.
  - Move Step CA binaries to appropriate locations.

### `02-stepcaconfigs.yml`

- **Purpose**: Creates configuration files for the Step CA server from templates.
- **Tasks**:
  - Create configuration files using Jinja2 templates.
  - Copy policy files.
  - Update `/etc/hosts` with internal GRPC names.

### `03-stepcasystemd.yml`

- **Purpose**: Installs systemd service units for the Step CA components.
- **Tasks**:
  - Install systemd services from templates.

### `04-cafiles.yml`

- **Purpose**: Copies issuing CA certificates and keys to the installation directory.
- **Tasks**:
  - Copy issuing CA certificate.
  - Copy issuing CA private key with appropriate permissions.

### `05-grpcpki.yml`

- **Purpose**: Generates gRPC root and leaf certificates if they do not exist or are expired.
- **Tasks**:
  - Check for existing gRPC root CA.
  - Generate new gRPC root CA if necessary.
  - Copy gRPC root CA certificate.
  - Check for existing gRPC leaf certificates.
  - Generate new gRPC leaf certificates if necessary.

### `06-installdatabase.yml`

- **Purpose**: Installs and configures MariaDB databases required by the Step CA server.
- **Tasks**:
  - Install MariaDB server and Python MySQL package.
  - Configure MariaDB settings.
  - Initialize and upgrade databases using Goose migration tool.
  - Create database users and assign privileges.

### `07-ctlogconfigs.yml`

- **Purpose**: Configures Certificate Transparency (CT) log services.
- **Tasks**:
  - Include tasks for full-fledged CT services if `stepca_ca_server` is true.
  - Include tasks for minimal CT service otherwise.

### `setup-stepca-cli.yml`

- **Purpose**: Installs and configures the Step CLI.
- **Tasks**:
  - Create source directory.
  - Download and install Step CLI package based on OS family.
  - Fetch and bootstrap Step CA fingerprint.
  - Install Step CA renewal service if enabled.

### `setup-stepca-renew-service.yml`

- **Purpose**: Sets up a systemd service to handle certificate renewals for the Step CA server.
- **Tasks**:
  - Create systemd service file from template.
  - Start and enable the service.

### `setup-stepca-server.yml`

- **Purpose**: Orchestrates the installation and configuration of the Step CA server.
- **Tasks**:
  - Include tasks to setup Step CA server, configure it, install systemd services, organize CA files, generate gRPC PKI, install databases, fix permissions, and start services.

## Handlers

### `main.yml`

| Handler Name       | Description                                                                 |
|--------------------|-----------------------------------------------------------------------------|
| `reload systemctl` | Reloads the systemd daemon to apply changes made by the role.               |

## Notes

- **Double-underscore variables**: These are internal variables used within the role and should not be modified externally.
- **OS-specific variables**: The role includes OS-specific variable files that can be overridden if necessary.

This documentation provides a comprehensive overview of the `bootstrap_stepca` Ansible role, detailing its purpose, variables, tasks, and handlers. For more detailed information on each task or handler, refer to the corresponding YAML files in the role directory.