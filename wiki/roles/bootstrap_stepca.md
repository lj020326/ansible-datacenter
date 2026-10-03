---
title: "StepCA Bootstrap Role"
role: roles/bootstrap_stepca
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_stepca]
---

```yaml
---
title: "StepCA Bootstrap Role"
role: "bootstrap_stepca"
category: "Security"
type: "Role"
summary: |
  The StepCA Bootstrap Role installs and configures StepCA, a certificate authority (CA) and related services, on a Debian-based system. It handles the installation of the Step CLI, StepCA server, and related dependencies, as well as the configuration of systemd services and database setup.

variables:
  - name: "stepca_local_cert_dir"
    default: "/usr/local/ssl/certs"
    description: "Directory to store local certificates."
  - name: "stepca_local_key_dir"
    default: "/usr/local/ssl/private"
    description: "Directory to store local private keys."
  - name: "stepca_install_service"
    default: "true"
    description: "Whether to install the StepCA renewal service."
  - name: "stepca_hostname_full"
    default: "{{ ansible_facts['fqdn'] }}"
    description: "Fully qualified domain name of the host."
  - name: "stepca_src"
    default: "/var/lib/src/stepca"
    description: "Source directory for StepCA installation files."
  - name: "stepca_cli_package_url"
    default: "https://github.com/smallstep/cli/releases/download/v0.15.16/step-cli_0.15.16_amd64.deb"
    description: "URL to download the Step CLI package."
  - name: "stepca_cli_bin_dir"
    default: "/usr/local/bin"
    description: "Directory to install the Step CLI binary."
  - name: "stepca_deb_url"
    default: "https://github.com/smallstep/certificates/releases/download/v0.15.8/step-certificates_0.15.8_amd64.deb"
    description: "URL to download the StepCA server package."
  - name: "stepca_host_url"
    default: "https://stepca.example.int/"
    description: "URL of the StepCA host."
  - name: "stepca_ca_server"
    default: "false"
    description: "Whether to configure the system as a StepCA server."
  - name: "stepca_svc_user"
    default: "step"
    description: "User for StepCA services."
  - name: "stepca_apps"
    default: |
      - stepca-ca
      - stepca-ra
      - stepca-va
      - stepca-sa
      - stepca-publisher
      - nonce-service
      - stepca-wfe2
      - ocsp-updater
      - ocsp-responder
      - orphan-finder
      - admin-revoker
      - stepca-janitor
      - expired-authz-purger2
    description: "List of StepCA applications to install."
  - name: "stepca_services"
    default: |
      - stepca-ca
      - stepca-ra
      - stepca-sa
      - stepca-va
      - stepca-wfe2
      - stepca-eap2
      - stepca-janitor
      - stepca-nonce-provider
      - stepca-ocsp-responder
      - stepca-ocsp-updater
      - stepca-publisher
    description: "List of StepCA services to manage."
  - name: "ctfe_server_http"
    default: "4011"
    description: "HTTP port for the CTFE server."
  - name: "app_conf"
    default: |
      ca:
        network:
          grpc:
            ca: 3501
            ocsp: 3502
        features:
          StoreIssuerInfo: true
          BlockedKeyTable: true
      ra:
        network:
          grpc: 3511
        features:
          V1DisableNewValidations: true
          BlockedKeyTable: true
          StoreRevokerInfo: false
          RestrictRSAKeySizes: true
          FasterNewOrdersRateLimit: true
      va:
        network:
          grpc: 3531
          dns_resolvers: "{{ va_resolvers }}"
        features:
          CAAAccountURI: true
          CAAValidationMethods: true
          MultiVAFullResults: false
          EnforceMultiVA: false
      sa:
        network:
          grpc: 3521
        db_user: stepca_sasvc
        features:
          StoreIssuerInfo: true
          StoreRevokerInfo: false
          StoreKeyHashes: true
          FasterNewOrdersRateLimit: true
      publisher:
        network:
          grpc: 3512
      nonce:
        network:
          grpc: 3541
      wfe2:
        network:
          http: 3601
          https: 0
        features:
          StripDefaultSchemePort: true
          MandatoryPOSTAsGET: true
          PrecertificateRevocation: true
          BlockedKeyTable: true
      ocsp_updater:
        features:
          StoreIssuerInfo: true
        db_user: stepca_ocspupd
      ocsp_responder:
        network:
          http: 3602
        db_user: stepca_ocspresp
      admin_revoker:
        db_user: stepca_revoker
      janitor:
        db_user: stepca_janitor
      expired_authz_purger2:
        db_user: stepca_purger
    description: "Configuration for StepCA applications."

usage: |
  To use this role, include it in your playbook and set the necessary variables. For example:

  ```yaml
  - hosts: all
    roles:
      - role: bootstrap_stepca
        vars:
          stepca_ca_server: true
          stepca_host_url: "https://stepca.example.com/"
          stepca_local_cert_dir: "/custom/cert/dir"
          stepca_local_key_dir: "/custom/key/dir"
          stepca_install_service: false
          stepca_svc_user: "customuser"
  ```

dependencies: |
  - This role requires a Debian-based system.
  - The role uses the `community.crypto` collection for OpenSSL tasks (version 2.0.0 or later).

best_practices: |
  - Ensure that the system has internet access to download the necessary packages.
  - Make sure that the StepCA server URL is accessible from the system.
  - Regularly update the StepCA packages to the latest versions by monitoring the official repository.
  - Monitor the StepCA services and logs for any issues using a centralized logging solution.
  - Implement proper firewall rules to restrict access to StepCA services.
  - Backup StepCA configuration and databases regularly.

backlinks:
  - "../../roles/bootstrap_stepca/defaults/main.yml"
  - "../../roles/bootstrap_stepca/tasks/fetch-stepca-fingerprint.yml"
  - "../../roles/bootstrap_stepca/tasks/install-debian.yml"
  - "../../roles/bootstrap_stepca/tasks/main.yml"
  - "../../roles/bootstrap_stepca/tasks/02-stepca-server.yml"
  - "../../roles/bootstrap_stepca/tasks/02-stepcaconfigs.yml"
  - "../../roles/bootstrap_stepca/tasks/03-stepcasystemd.yml"
  - "../../roles/bootstrap_stepca/tasks/04-cafiles.yml"
  - "../../roles/bootstrap_stepca/tasks/05-1-grpcpki-leaf.yml"
  - "../../roles/bootstrap_stepca/tasks/05-grpcpki.yml"
  - "../../roles/bootstrap_stepca/tasks/06-installdatabase.yml"
  - "../../roles/bootstrap_stepca/tasks/07-1-fullctsrv.yml"
  - "../../roles/bootstrap_stepca/tasks/07-2-testctsrv.yml"
  - "../../roles/bootstrap_stepca/tasks/07-ctlogconfigs.yml"
  - "../../roles/bootstrap_stepca/tasks/setup-stepca-cli.yml"
  - "../../roles/bootstrap_stepca/tasks/setup-stepca-renew-service.yml"
  - "../../roles/bootstrap_stepca/tasks/setup-stepca-server.yml"
  - "../../roles/bootstrap_stepca/handlers/main.yml"
```