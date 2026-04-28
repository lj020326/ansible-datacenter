# Ansible Datacenter Wiki

This repository provides a `site.yml` playbook to configure a multi-OS datacenter (Ubuntu/CentOS/Debian and Windows).

## Table of Contents
* [CI Status](#ci-status)
* [Linux OS Platform Molecule Tests](#linux-os-platform-molecule-tests)
* [Ansible Developer Environment](#ansible-developer-environment)
* [Summary](#summary)
* [Prerequisites](#prerequisites)
* [Running Ansible Site Plays](#running-ansible-site-plays)
* [Jenkins Ansible Jobs](#jenkins-ansible-jobs)
* [Image Build & Deployment Workflow](#image-build--deployment-workflow)
* [Contributing & Support](#contributing--support)

## CI Status

[![CI](https://github.com/lj020326/ansible-datacenter/actions/workflows/verify_all_green.yml/badge.svg?branch=main)](https://github.com/lj020326/ansible-datacenter/actions/workflows/verify_all_green.yml)
> **Note:** The badge above tracks the `main` branch. To track a feature branch, update the URL to `.../verify_all_green.yml/badge.svg?branch=<your-branch-name>`.

---

## Linux OS Platform Molecule Tests

### What is Molecule?
**Molecule** is a testing framework designed to aid in the development and testing of Ansible roles. It allows you to automatically spin up instances (containers or VMs), run your playbooks against them, and verify that the system state is correct.

In this repo, Molecule is used to:
* Define multi-platform test scenarios in `molecule.yml`.
* Perform isolated testing of key orchestration roles like `bootstrap_linux`.
* Utilize systemd-enabled Docker images for realistic service testing.

For execution details, see the [Molecule README](molecule/README.md).

---

## Ansible Developer Environment

To bootstrap a local development environment, use the provided installer script. This prepares your system to run playbooks and execute Molecule tests.

### Automated Setup
The installer performs the following:
1. Creates `$HOME/repos/ansible`.
2. Clones the `ansible-developer` repository.
3. Synchronizes your bash environment with pre-configured scripts.

```shell
# Install from public GitHub
INSTALL_REMOTE_SCRIPT="https://raw.githubusercontent.com/lj020326/ansible-developer/main/install.sh"
bash -c "$(curl -fsSL ${INSTALL_REMOTE_SCRIPT})"
```

---

## Summary

* **Automation Architectures:** Collection of roles, playbooks, and modules.
* **Image Build Systems:** Integration with Packer and vSphere.
* **Lifecycle Management:** From OS hardening to application deployment and maintenance.

---

## Priority Roles

- **[apply_common_groups](wiki/roles/apply_common_groups.md)** — Core role
- **[apply_ping_test](wiki/roles/apply_ping_test.md)** — Core role
- **[bootstrap_ansible_controller](wiki/roles/bootstrap_ansible_controller.md)** — Core role
- **[bootstrap_docker](wiki/roles/bootstrap_docker.md)** — Core role
- **[bootstrap_docker_stack](wiki/roles/bootstrap_docker_stack.md)** — Core role
- **[bootstrap_gpu_drivers](wiki/roles/bootstrap_gpu_drivers.md)** — Core role
- **[bootstrap_jenkins_agent](wiki/roles/bootstrap_jenkins_agent.md)** — Core role
- **[bootstrap_kubernetes](wiki/roles/bootstrap_kubernetes.md)** — Core role
- **[bootstrap_linux](wiki/roles/bootstrap_linux.md)** — Core role
- **[bootstrap_linux_core](wiki/roles/bootstrap_linux_core.md)** — Core role

## All Roles by Category


### Bootstrap & Foundation Roles

- [bootstrap_aibrix](wiki/roles/bootstrap_aibrix.md)
- [bootstrap_ansible](wiki/roles/bootstrap_ansible.md)
- [bootstrap_ansible_controller](wiki/roles/bootstrap_ansible_controller.md)
- [bootstrap_ansible_user](wiki/roles/bootstrap_ansible_user.md)
- [bootstrap_awstats](wiki/roles/bootstrap_awstats.md)
- [bootstrap_awx](wiki/roles/bootstrap_awx.md)
- [bootstrap_awx_config](wiki/roles/bootstrap_awx_config.md)
- [bootstrap_awx_docker](wiki/roles/bootstrap_awx_docker.md)
- [bootstrap_awx_resources](wiki/roles/bootstrap_awx_resources.md)
- [bootstrap_bind](wiki/roles/bootstrap_bind.md)
- [bootstrap_ca_certs](wiki/roles/bootstrap_ca_certs.md)
- [bootstrap_caddy2](wiki/roles/bootstrap_caddy2.md)
- [bootstrap_certs](wiki/roles/bootstrap_certs.md)
- [bootstrap_cfssl](wiki/roles/bootstrap_cfssl.md)
- [bootstrap_chronyclient](wiki/roles/bootstrap_chronyclient.md)
- [bootstrap_chronyserver](wiki/roles/bootstrap_chronyserver.md)
- [bootstrap_cloud_init](wiki/roles/bootstrap_cloud_init.md)
- [bootstrap_cni](wiki/roles/bootstrap_cni.md)
- [bootstrap_dell_opscenter](wiki/roles/bootstrap_dell_opscenter.md)
- [bootstrap_dell_racadm_host](wiki/roles/bootstrap_dell_racadm_host.md)
- [bootstrap_dhcp](wiki/roles/bootstrap_dhcp.md)
- [bootstrap_docker](wiki/roles/bootstrap_docker.md)
- [bootstrap_docker_stack](wiki/roles/bootstrap_docker_stack.md)
- [bootstrap_epel_repo](wiki/roles/bootstrap_epel_repo.md)
- [bootstrap_etcd](wiki/roles/bootstrap_etcd.md)
- [bootstrap_fog](wiki/roles/bootstrap_fog.md)
- [bootstrap_git](wiki/roles/bootstrap_git.md)
- [bootstrap_gitea_runner](wiki/roles/bootstrap_gitea_runner.md)
- [bootstrap_govc](wiki/roles/bootstrap_govc.md)
- [bootstrap_gpu_drivers](wiki/roles/bootstrap_gpu_drivers.md)
- [bootstrap_hddtemp](wiki/roles/bootstrap_hddtemp.md)
- [bootstrap_inspec](wiki/roles/bootstrap_inspec.md)
- [bootstrap_ipa_client](wiki/roles/bootstrap_ipa_client.md)
- [bootstrap_ipa_config](wiki/roles/bootstrap_ipa_config.md)
- [bootstrap_ipa_krb5](wiki/roles/bootstrap_ipa_krb5.md)
- [bootstrap_ipa_replica](wiki/roles/bootstrap_ipa_replica.md)
- [bootstrap_ipa_server](wiki/roles/bootstrap_ipa_server.md)
- [bootstrap_ipa_sssd](wiki/roles/bootstrap_ipa_sssd.md)
- [bootstrap_iscsi_client](wiki/roles/bootstrap_iscsi_client.md)
- [bootstrap_java](wiki/roles/bootstrap_java.md)
- [bootstrap_jenkins](wiki/roles/bootstrap_jenkins.md)
- [bootstrap_jenkins_agent](wiki/roles/bootstrap_jenkins_agent.md)
- [bootstrap_jenkins_swarm_agent](wiki/roles/bootstrap_jenkins_swarm_agent.md)
- [bootstrap_kubernetes](wiki/roles/bootstrap_kubernetes.md)
- [bootstrap_kubernetes_ca](wiki/roles/bootstrap_kubernetes_ca.md)
- [bootstrap_kubernetes_controller](wiki/roles/bootstrap_kubernetes_controller.md)
- [bootstrap_kubernetes_worker](wiki/roles/bootstrap_kubernetes_worker.md)
- [bootstrap_kvm](wiki/roles/bootstrap_kvm.md)
- [bootstrap_kvm_infra](wiki/roles/bootstrap_kvm_infra.md)
- [bootstrap_ldap_client](wiki/roles/bootstrap_ldap_client.md)
- [bootstrap_linux](wiki/roles/bootstrap_linux.md)
- [bootstrap_linux_core](wiki/roles/bootstrap_linux_core.md)
- [bootstrap_linux_cron](wiki/roles/bootstrap_linux_cron.md)


### Networking & Security

- [apply_ping_test](wiki/roles/apply_ping_test.md)


### Utility

- [apply_common_groups](wiki/roles/apply_common_groups.md)
- [apply_ping_test](wiki/roles/apply_ping_test.md)

---

## Prerequisites

1. **Clone the repository:**
   ```shell
   git clone https://github.com/lj020326/ansible-datacenter.git
   ```
2. **Install requirements:**
   ```shell
   ansible-galaxy collection install -r ./collections/requirements.yml
   ansible-galaxy install -r ./roles/requirements.yml
   ```
3.  **Configure Ansible Vault:**
    This repository uses a `vars/vault.yml` file to store sensitive credentials and configuration data. 

    ### Variable Convention
    To maintain clarity and prevent accidental exposure of plain-text variables, all variables stored within the vault **MUST** be prefixed with `vault__`.

    ### Required Vault Content
    Your `vars/vault.yml` should include, but is not limited to, the following categories of data:
    * **Infrastructure Credentials:** SSH passwords for Linux, Administrator passwords for Windows, and iDRAC/IPMI credentials.
    * **Hypervisor Access:** vCenter/ESXi passwords and associated license keys.
    * **Network Secrets:** RNDC keys for DNS updates and OMAPI keys for DHCP failover.
    * **Cloud & API Integration:** Cloudflare API keys and Google App passwords for SMTP relay.
    * **Service Authentication:** MySQL root passwords, LDAP admin credentials, and Docker Registry authentication.
    * **Security Keys:** Private RSA keys for admin access and JWT/OAuth secrets for application stacks (e.g., Gitea, Authelia).

    ### Creation Command
    ```shell
    # Create and encrypt the private variables file
    ansible-vault create vars/vault.yml
    ```
    *Refer to [vars/README.md](vars/README.md) for a comprehensive list of required variables and an example schema.*

4. **Configure Inventory:** Add host(s) to inventory hosts.yml and ping the host(s)
   ```shell
   ansible -i inventory/hosts.yml all -m ping -b -vvvv
   ```

---

## Running Ansible Site Plays

Detailed instructions on how to run and test the `ansible-datacenter` site plays can be found in the documentation link below:

* **[Running Ansible Site Plays](./docs/ansible-site-plays.md)**

---

## Jenkins Ansible Jobs

The orchestration and execution of the datacenter site playbook tags can be managed via Jenkins pipelines. Detailed instructions on job configuration, parameter initialization, and command-line wrappers for Jenkins-led execution can be found in the documentation link below:

* **[Jenkins Operations & Job Control](./docs/jenkins-ansible-jobs.md)**

---

## Image Build Workflow

## Image Build & Deployment Workflow

The infrastructure utilizes a standardized pipeline to move from code to a running virtual machine or container. This process is divided into two primary phases: **Template Generation** and **Instance Deployment**.

### 1. Image Template Generation (The "Baking" Phase)
This phase creates a gold image or container base that is hardened and pre-configured.

* **Orchestration:** **Packer** initiates the build based on a specific spec, determining if the target is a Virtual Machine or a Container.
* **Base OS Installation:** For VMs, the pipeline performs a clean OS installation of Ubuntu, Debian, or CentOS.
* **Ansible Provisioning:** Once the base OS is ready, Ansible applies core roles (like `bootstrap_linux`) to harden the security profile and install baseline software.
* **Jenkins Automation:** The `buildVmTemplate` function from the `pipeline-automation-lib` automates this entire process, handling the Packer execution and subsequent cleanup.


### 2. Instance Deployment (The "Running" Phase)
Once a template is verified and stored in the vSphere library or Docker registry, it is ready for deployment.

* **Playbook Execution:** The standard `site.yml` playbook is utilized for deployment.
* **Targeting:** Deployment is triggered using the `deploy-vm` tag, which instructs Ansible to clone the previously built template into a functional VM instance.
* **Post-Deployment:** Following the initial clone, the pipeline continues with application-specific deployment and ongoing maintenance roles as defined in the automation lifecycle.

---

### Documentation Source Reference
* **:** `README.md` - Outlines the role of `bootstrap_linux` and general architecture.
* **:** `image-templates.md` - Provides the Mermaid workflow diagram and repository links.
* **:** `buildVmTemplate.groovy` - Details the Jenkins function used to invoke Packer and build templates.
* **:** `site.yml` - Contains the primary orchestration logic and deployment tags.

The workflow to build a machine image (docker image or virtual machine template) leverages the Ansible `bootstrap_linux` role to set up the machine image before archival and distribution to the respective platform image manager (docker registry or VMware template library).  It is custom to have this image build process performed regularly/periodically in order to enable an efficient provisioning process for creating container or virtual machine instances utilizing the most secure, modern versions and configuration:

* **[Image Template Workflow](./docs/image-templates.md)**

---

## Contributing & Support

* **Reporting Issues:** Please use the GitHub Issues tab to report bugs or request features.
* **Pull Requests:** Contributions are welcome. Please ensure all Molecule tests pass before submitting.
* **Contact:** Connect with [Lee James Johnson on LinkedIn](https://www.linkedin.com/in/leejjohnson/).

---

## Documentation Links
* [Jenkins Operations & Job Control](./docs/jenkins-ansible-jobs.md)
* [Image Templates](docs/image-templates.md)

