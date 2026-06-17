# Ansible Datacenter

This repository provides a `site.yml` playbook to configure a multi-OS datacenter (Ubuntu/CentOS/Debian and Windows).

## Table of Contents
* [Summary](#summary)
* [CI Status](#ci-status)
* [Wiki](#wiki)
* [Linux OS Platform Molecule Tests](#linux-os-platform-molecule-tests)
* [Ansible Developer Environment](#ansible-developer-environment)
* [Prerequisites](#prerequisites)
* [Running Ansible Site Plays](#running-ansible-site-plays)
* [Jenkins Ansible Jobs](#jenkins-ansible-jobs)
* [Image Build & Deployment Workflow](#image-build--deployment-workflow)
* [Contributing & Support](#contributing--support)

---

## Summary

* **Automation Architectures:** Collection of roles, playbooks, and modules.
* **Image Build Systems:** Integration with Packer and vSphere.
* **Lifecycle Management:** From OS hardening to application deployment and maintenance.

---

## CI Status

[![CI](https://github.com/lj020326/ansible-datacenter/actions/workflows/verify_all_green.yml/badge.svg?branch=main)](https://github.com/lj020326/ansible-datacenter/actions/workflows/verify_all_green.yml)
> **Note:** The badge above tracks the `main` branch. To track a feature branch, update the URL to `.../verify_all_green.yml/badge.svg?branch=<your-branch-name>`.

---

## Wiki

The wiki is automatically generated and maintained by the  [LLM-powered wiki pipeline](https://github.com/lj020326/jenkins-docker-agent/tree/main/image/wiki-pipeline).
It provides professional, GitHub-native documentation for the ansible-datacenter repository.

* **[Ansible Datacenter WIKI](./wiki/README.md)**

---

## Repository architectural conventions

Note the following architectural conventions used within this repository:

- **Variable Namespacing:** All public role variable names must be prefixed with `role_name__` (e.g., `role_foobar__enable_option`). Any existing role variables that violate this convention are considered **deprecated** and will be refactored in future updates.
- **Internal Variables:** Variables prefixed with a double-underscore (e.g., `__internal_var`) are strictly internal to the role. These variables handle local logic and must never be overridden via inventory or the command line.
- **Tag Scope:** Tag usage is restricted to the Ansible play level and must not be defined within individual roles. Any legacy tags currently embedded within roles are considered **deprecated** and will be systematically removed.
- **Loop Controls:** When looping over `ansible.builtin.include_tasks`, always explicitly define the loop variable using `loop_control.loop_var`. This prevents implicit namespace collisions with the default `item` variable.
- **Inventory Decoupling:** Ansible roles must be completely divorced from inventory-specific architecture. Relying on explicit group facts or magic variables (e.g., `groups`, `group_names`) inside a role is considered bad practice. Design roles to depend strictly on input parameters and role-specific defaults to ensure maximum portability.
- **Configuration Desensitization:** Default variables within roles must never contain environment-specific or production data. Real-world implementation details must be replaced with neutral, generic defaults (e.g., setting `role_name__domain_name` to `example.com` or `example.int` rather than an actual corporate domain). Actual environmental configurations belong in the inventory, while sensitive secrets belong exclusively in the Ansible Vault.
- **Role Parameterization & Topology Toggling:** Roles responsible for handling multi-tiered or heterogeneous architectures (e.g., master/worker, server/client, leader/follower) must remain topology-agnostic. Instead of checking inventory groups directly within the tasks, the role must expose a clear behavior-toggling input variable (e.g., `role_name__node_type: "client"`). The responsibility of assigning these types falls entirely on the inventory's `group_vars` (e.g., leveraging child group variable overrides so that a `postfix_server` group overrides the defaults of a parent `postfix_network` group).

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

4. **Run playbook:** Run playbook for specified tag(s) and/or group(s)
   ```shell
   run-playbook.sh -t bootstrap-linux -l admin01 site.yml
   ## install collections
   INSTALL_GALAXY_COLLECTIONS=1 run-playbook.sh --tags bootstrap-docker -l control01  site.yml
   ## install and upgrade collections
   FORCE_GALAXY_COLLECTIONS=1 UPGRADE_GALAXY_COLLECTIONS=1 run-playbook.sh --tags bootstrap-docker-control -l control02 site.yml
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

### Machine Image Templates

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
