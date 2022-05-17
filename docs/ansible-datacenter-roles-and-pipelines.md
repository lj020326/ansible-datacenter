
Ansible Datacenter Roles and Pipelines
===

> A collection of high quality roles and playbooks that follow current best practices, a common style and have detailed documentation and User Stories reflecting the use cases.
> 
> Roles can be used individually or combined in playbooks to solve common problems such as Cloud Image Factory, Discovery, Migration, Continuous Patching and Compliance, Cloud Provisioning, and Kubernetes/OpenShift deployment and management.
> 

Document Control

**TODO:**

-   Overall structure.
-   Presentation decks in Google Docs

## Problem Description and Solution[](#problem-description-and-solution "Permanent link")

#### Problems[](#problems "Permanent link")

-   **Cloud:** Building and managing virtual and cloud environments across DEV, TEST, STAGING and PRODUCTION requires a lot of manual steps that cannot be easily shared and re-used across platforms. Building and maintaing master golden images is expensive, and is not easily re-used.
-   **Security and Compliance**: DEV and PRODUCTION environments are built differently and don't usually share the same compliance or security settings.
-   **Migration** across platforms is difficult and re-install or re-platform approaches are time consuming.
-   **Container Builds**: are inconsistent and not aligned with OS security baselines.
-   **Security**: Update and maintain SSL and Certificate Authority configuration.
-   **Modernization and Migration**: how can I re-platform to a modern system that uses automation and configuration management? Ex: move from manually managed runbooks to runbook automation.

#### Solution[](#solution "Permanent link")

-   End-to-end automation that is modular, extensible and easily integrated with Continuous Deployment systems.
-   Automated image build system that creates modular images that target all virtual and cloud platforms, and can be extended / combined as part of a CI/CD pipeline to create tailored images (ex: PCI compliant PS images that target IBM Cloud VCS and Azure / AWS / VMware that share the same build systems and tools as the local images used for DEV/TEST that might run on VirtualBox, KVM, OpenStack or RHV platforms).
-   Security and compliance are built in, from day 1. Images are updated as part of the build process, and daily / continuous builds and automated testing allow for images to always be provisioned using a secure baseline.
-   Discovery scripts used for OS migration. Modular images used as landing platforms.
-   Modern, two-stage container builds that use buildah to package applications for container platforms.

#### Technical description[](#technical-description "Permanent link")

-   Collection of Ansible roles, playbooks, plugins, and modules
-   OS image build systems (packer, virsh and kickstart)

#### Example Workflow[](#example-workflow "Permanent link")

> An example workflow for using the master golden images


```mermaid
graph TD;
    A[Packer Build Spec] --> B{Virtual Machine}
    B -->|yes| C["Install OS (Centos/Ubuntu/Debian)"]
    B -->|no| D[Container Build]
    C --> E[Post OS Install - VM Base VM Template Image]
    D --> F[Post OS Install - OS Base Container Image]
    E --> G["Ansible Provision Role + Harden Security Profile (VM/Cloud/Container)"]
    F --> G["Ansible Provision Role + Harden Security Profile (VM/Cloud/Container)"]
    G --> H["Ansible Post OS Install - Software Install"]
    H --> I[Ansible Application Deploy]
    I --> J[Ansible Maintenance]

```

#### Role Development Workflow[](#role-development-workflow "Permanent link")

-   Init a new role from the Cookiecutter Template
-   Lint code with `yamllint` and `ansible-lint`
-   Install role with `molecule` on Docker and KVM
-   Unit test role with `goss`
-   Push to Github
-   Trigger automatic CI/CD using Travis-CI (test matrix against supported Operating Systems). Runs molecule / goss tests.

## Personas Served[](#personas-served "Permanent link")

-   Developer: writes code, sets up static analysis, runs builds.
-   Image Architect / Migration Engineer: migrate and convert virtual machines. Discover applications and systems. Install middleware.
-   CI/CD/Build Engineer/Delivery Engineer: sets up CI/CD, automates builds.
-   Cloud Architect: uses multiple cloud providers, APIs, SDKs and toolkits. Provision entire landscapes.
-   SRE Engineer / Linux and UNIX Systems Administrator: Install various server roles, configure and secure systems.
-   Ansible Developer: Writes ansible playbooks and roles.
-   Kubernetes Engineer: sets up Kubernetes / OpenShift environments. Creates container builds.
-   Linux Desktop User: sets up Linux desktop environments and configures dotfiles.
-   Compliance Officer: sets up compliance and security rules.

## Use Cases and User Stories[](#use-cases-and-user-stories "Permanent link")

> Use cases include Provisioning, Configuration Management and Configuring Operating Systems, Application Deployment Continuous Delivery, Security and Compliance Automation, Orchestration, and Migration.

## Playbooks[](#playbooks "Permanent link")

-   Linux Node
-   Python Development
-   Patching
-   Continuous Compliance
-   Windows
-   MacOS
-   Backup

## Tested Operating Systems[](#tested-operating-systems "Permanent link")

Most roles are supported on:

-   CentOS / RHEL 7
-   CentOS / RHEL 8
-   Debian 10
-   Ubuntu 18.04
-   Ubuntu 20.04

Roles that manage AIX, Windows or Cloud instances are described as such.

## Roles[](#roles "Permanent link")

### Basic Roles[](#basic-roles "Permanent link")

### Server Roles[](#server-roles "Permanent link")

### Cloud Roles[](#cloud-roles "Permanent link")

## Ansible Playbooks[](#ansible-playbooks "Permanent link")

[Ansible Playbooks](https://github.com/devopstoolbox/playbooks)

## Code Repository and Links[](#code-repository-and-links "Permanent link")

### Github and Ansible Galaxy[](#github-and-ansible-galaxy "Permanent link")

-   [GitHub Repositories](https://github.com/devopstoolbox)
-   [Ansible Collections by Mihai Criveti](http://galaxy.ansible.com/devopstoolbox)

### Presentations and Talks:[](#presentations-and-talks "Permanent link")

-   [Automate Everything with Python, Ansible and Kubernetes](https://drive.google.com/open?id=19AlIB3T3jDUE0Kry86cHvKXRg1-Ih_d1)
-   [PyCon 2019 Talk: DevOps flows with Ansible, Packer & Kubernetes](https://www.youtube.com/watch?v=lO884XAdddQ)

### Lines of Code[](#lines-of-code "Permanent link")

```
───────────────────────────────────────────────────────────────────────────────
Language                 Files     Lines   Blanks  Comments     Code Complexity
───────────────────────────────────────────────────────────────────────────────
YAML                       448     15202      854       686    13662          0
Markdown                   217     13253     4072         0     9181          0
Shell                       74      1256      209        98      949         67
HTML                        38      3692     1517        61     2114          0
CSS                         32      1212      177        14     1021          0
Jinja                       32      1074      120         0      954         48
gitignore                   26       165       26        29      110          0
JavaScript                  17       814       64       228      522         95
XML                          8       406       83         0      323          0
JSON                         3        69        0         0       69          0
License                      3        97       20         0       77          0
TOML                         3        96        7         7       82          2
Plain Text                   2        15        0         0       15          0
Python                       1        71       11        11       49          9
SVG                          1        18        0         0       18          0
Systemd                      1        27        2         0       25          0
───────────────────────────────────────────────────────────────────────────────
Total                      906     37467     7162      1134    29171        221
───────────────────────────────────────────────────────────────────────────────
Estimated Cost to Develop $932,812
Estimated Schedule Effort 14.942132 months
Estimated People Required 7.394968
───────────────────────────────────────────────────────────────────────────────

```

___
