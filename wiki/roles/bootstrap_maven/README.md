```markdown
---
title: Ansible Role - bootstrap_maven
original_path: roles/bootstrap_maven/README.md
category: Ansible Roles
tags: [ansible, maven, java]
---

# Ansible Role: bootstrap_maven

This role installs the [Apache Maven](https://maven.apache.org) build tool.

## Requirements

- **Ansible**: >= 2.8
- **Linux Distribution**:
  - **Debian Family**:
    - Debian: Stretch (9), Buster (10), Bullseye (11)
    - Ubuntu: Bionic (18.04), Focal (20.04)
  - **RedHat Family**:
    - Rocky Linux: 8
    - Fedora: 34
  - **SUSE Family**:
    - openSUSE: 15.2

  *Note*: Other versions are likely to work but have not been tested.

- **Java SE Development Kit (JDK)**:
  - The required JDK version depends on the Apache Maven version:

| Maven Version | Minimum JDK Version |
|--------------:|------------------:|
|         3.8.x |                   7 |
|         3.6.x |                   7 |
|         3.5.x |                   7 |
|         3.3.x |                   7 |
|         3.2.x |                   6 |
|         3.1.x |                   5 |

## Role Variables

The following variables can be adjusted to change the behavior of this role (default values are shown below):

```yaml
# Maven version number
maven_version: '3.8.4'

# Mirror to download the Maven redistributable package from
maven_mirror: "http://archive.apache.org/dist/maven/maven-{{ maven_version|regex_replace('\\..*', '') }}/{{ maven_version }}/binaries"

# Base installation directory for the Maven distribution
maven_install_dir: /opt/maven

# Directory to store files downloaded for Maven installation
maven_download_dir: "{{ x_ansible_download_dir | default(ansible_env.HOME + '/.ansible/tmp/downloads') }}"

# The number of seconds to wait before the Maven download times out
maven_download_timeout: 10

# Whether to use the proxy when downloading Maven (if the proxy environment variable is present)
maven_use_proxy: yes

# Whether to validate HTTPS certificates when downloading Maven
maven_validate_certs: yes

# If this is the default installation, symbolic links to mvn and mvnDebug will be created in /usr/local/bin
maven_is_default_installation: yes

# Name of the group of Ansible facts relating to this Maven installation.
#
# Override if you want to use this role more than once to install multiple versions of Maven.
#
# e.g. maven_fact_group_name: maven_3_3
# would change the Maven home fact to:
# ansible_local.maven_3_2.general.home
maven_fact_group_name: maven
```

### Supported Maven Versions

The following versions of Maven are supported without additional configuration (for other versions, follow the [Advanced Configuration](#advanced-configuration) instructions):

- `3.8.4`
- `3.8.2`
- `3.8.1`
- `3.6.3`
- `3.6.2`
- `3.6.1`
- `3.6.0`
- `3.5.4`
- `3.5.3`
- `3.5.2`
- `3.5.0`
- `3.3.9`
- `3.2.5`
- `3.1.1`

## Advanced Configuration

For Maven versions not pre-configured by this role, you must configure the following variable:

```yaml
# SHA256 sum for the redistributable package (i.e., apache-maven-{{ maven_version }}-bin.tar.gz)
maven_redis_sha256sum: '6e3e9c949ab4695a204f74038717aa7b2689b1be94875899ac1b3fe42800ff82'
```

## Example Playbooks

### Default Installation

By default, this role installs the latest version of Maven supported by this role:

```yaml
- hosts: servers
  roles:
    - role: gantsign.maven
```

### Specific Version Installation

To install a specific version of Maven, specify the `maven_version` variable (additional configuration may be required for unsupported versions):

```yaml
- hosts: servers
  roles:
    - role: gantsign.maven
      maven_version: '3.3.9'
```

### Multiple Versions Installation

To install multiple versions of Maven using this role more than once:

```yaml
- hosts: servers
  roles:
    - role: gantsign.maven
      maven_version: '3.3.9'
      maven_is_default_installation: yes
      maven_fact_group_name: maven

    - role: gantsign.maven
      maven_version: '3.2.5'
      maven_is_default_installation: no
      maven_fact_group_name: maven_3_2
```

## Role Facts

This role exports the following Ansible facts for use by other roles:

- `ansible_local.maven.general.version`
  - e.g., `3.3.9`
- `ansible_local.maven.general.home`
  - e.g., `/opt/maven/apache-maven-3.3.9`

Overriding `maven_fact_group_name` will change the names of the facts, for example:

```yaml
maven_fact_group_name: maven_3_2
```

Would change the fact names to:

- `ansible_local.maven_3_2.general.version`
- `ansible_local.maven_3_2.general.home`

## Related Roles

You may find the following related roles useful:

- [gantsign.java](https://galaxy.ansible.com/gantsign/java) for installing the JDK.
- [gantsign.maven-notifier](https://galaxy.ansible.com/gantsign/maven-notifier) for providing a GUI notification when a build ends.

  *Installs the [Maven Notifier](https://github.com/jcgay/maven-notifier) extension for Maven authored by [Jean-Christophe Gay](https://github.com/jcgay).*

## More Roles From GantSign

You can find more roles from GantSign on [Ansible Galaxy](https://galaxy.ansible.com/gantsign).

## Development & Testing

This project uses [Molecule](http://molecule.readthedocs.io/) to aid in development and testing; the role is unit tested using [Testinfra](http://testinfra.readthedocs.io/) and [pytest](http://docs.pytest.org/).

To develop or test, you'll need:

- Linux (e.g., [Ubuntu](http://www.ubuntu.com/))
- [Docker](https://www.docker.com/)
- [Python](https://www.python.org/) (including python-pip)
- [Ansible](https://www.ansible.com/)
- [Molecule](http://molecule.readthedocs.io/)

This project includes [Molecule Wrapper](https://github.com/gantsign/molecule-wrapper), a shell script that installs Molecule and its dependencies (apart from Linux) and then executes Molecule with the command you pass it.

To test this role using Molecule Wrapper, run:

```bash
./moleculew test
```

*Note*: Some dependencies require `sudo` permission to install.

## Backlinks

- [Ansible Roles](https://galaxy.ansible.com/gantsign)
```