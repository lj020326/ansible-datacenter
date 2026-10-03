---
harvested_date: '2023-08-07T18:07:09.248098+00:00'
original_path: roles/bootstrap_java/README.md
source_type: markdown
title: Ansible Role: bootstrap_java
category: Ansible
tags:
  - Ansible
  - Java
  - RedHat
  - CentOS
  - Debian
  - Ubuntu
---

# Ansible Role: bootstrap_java

Installs Java for RedHat/CentOS and Debian/Ubuntu Linux servers.

## Requirements

None.

## Role Variables

Available variables are listed below, along with default values:

```yaml
# The defaults provided by this role are specific to each distribution.
bootstrap_java__packages:
  - java-1.8.0-openjdk
```

Set the version/development kit of Java to install, along with any other necessary Java packages. This can be a list of multiple packages. Some other options are included in the distribution-specific files in this role's 'defaults' folder.

```yaml
bootstrap_java__home: ""
```

If set, the role will set the global environment variable `JAVA_HOME` to this value.

```yaml
bootstrap_java__state: "present"
```

The state of the Java packages. Options are "present" or "absent".

## Dependencies

None.

## Example Playbook (using default package)

```yaml
- hosts: servers
  roles:
    - role: bootstrap_java
      become: true
```

## Example Playbook (install OpenJDK 8)

### For RHEL / CentOS

```yaml
- hosts: servers
  roles:
    - role: bootstrap_java
      when: "ansible_os_family == 'RedHat'"
      bootstrap_java__packages:
        - java-1.8.0-openjdk
```

### For Ubuntu < 16.04

```yaml
- hosts: servers
  tasks:
    - name: Installing repo for Java 8 in Ubuntu
      apt_repository:
        repo: 'ppa:openjdk-r/ppa'

- hosts: servers
  roles:
    - role: bootstrap_java
      when: "ansible_distribution == 'Ubuntu' and ansible_distribution_major_version | int < 16"
      bootstrap_java__packages:
        - openjdk-8-jdk
```

## Reference

- [buluma/ansible-role-openjdk](https://github.com/buluma/ansible-role-openjdk)
- [geerlingguy/ansible-role-java](https://github.com/geerlingguy/ansible-role-java)
- [abessifi/ansible-java](https://github.com/abessifi/ansible-java)
- [traveloka/ansible-java-openjdk](https://github.com/traveloka/ansible-java-openjdk)
- [idealista/java_role](https://github.com/idealista/java_role)

## Backlinks

(Add any backlinks here if applicable)