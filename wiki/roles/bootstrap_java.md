---
title: Bootstrap Java Role Documentation
role: bootstrap_java
category: System Configuration
type: Ansible Role
tags: java, jdk, installation, os-specific
---

## Summary

The `bootstrap_java` role is designed to install and configure Java Development Kit (JDK) on various operating systems including Debian-based distributions (like Ubuntu), RedHat-based distributions, and FreeBSD. It supports setting the JAVA_HOME environment variable and configuring default JDK versions where applicable.

## Variables

| Variable Name                     | Default Value                                                                 | Description                                                                                                                                                                                                 |
|-----------------------------------|-------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrap_java__home`            | `""`                                                                          | The path to set as JAVA_HOME. If left empty, JAVA_HOME will not be configured.                                                                                                                               |
| `bootstrap_java__set_as_default`  | `false`                                                                       | A boolean flag indicating whether the installed JDK should be set as the default Java version on RedHat-based systems.                                                                                      |
| `bootstrap_java__jvm_basedir`     | `/usr/lib/jvm`                                                                | The base directory where JVMs are installed.                                                                                                                                                                |
| `bootstrap_java__packages`        | `{{ __bootstrap_java__packages_default }}`                                    | A list of Java packages to install. This variable is dynamically set based on the OS and version.                                                                                                          |
| `bootstrap_java__package_default` | `{{ __bootstrap_java__packages[0] }}`                                         | The default Java package to use when setting the default JDK version on RedHat-based systems.                                                                                                                 |

## Usage

To use this role, include it in your playbook and optionally set the variables as needed:

```yaml
- hosts: all
  roles:
    - role: bootstrap_java
      vars:
        bootstrap_java__home: "/usr/lib/jvm/java-11-openjdk-amd64"
        bootstrap_java__set_as_default: true
```

## Dependencies

This role does not have any external dependencies beyond the Ansible core modules and some community modules:

- `community.general.pkgng` for FreeBSD package management.
- `community.general.alternatives` for setting default Java versions on RedHat-based systems.

Ensure these collections are installed in your environment:

```bash
ansible-galaxy collection install community.general
```

## Tags

This role does not use any custom tags. However, you can target specific tasks using the following tags:

- `java-installation`: For tasks related to Java installation.
- `java-home-setup`: For tasks related to setting JAVA_HOME.

Example usage of tags:

```bash
ansible-playbook -i inventory playbook.yml --tags java-installation
```

## Best Practices

1. **Specify JDK Version**: Always specify the exact version of Java you need by configuring the `bootstrap_java__packages` variable.
2. **Set Default JDK**: On RedHat-based systems, set `bootstrap_java__set_as_default` to `true` if you want the installed JDK to be the default system-wide Java version.
3. **JAVA_HOME Configuration**: Configure `bootstrap_java__home` if your application requires a specific JAVA_HOME path.

## Molecule Tests

This role includes Molecule tests to verify its functionality across different operating systems. To run the tests, navigate to the role directory and execute:

```bash
molecule test
```

Ensure you have Docker installed as it is used by Molecule for testing in containers.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_java/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_java/tasks/main.yml)
- [tasks/setup-Debian.yml](../../roles/bootstrap_java/tasks/setup-Debian.yml)
- [tasks/setup-FreeBSD.yml](../../roles/bootstrap_java/tasks/setup-FreeBSD.yml)
- [tasks/setup-RedHat.yml](../../roles/bootstrap_java/tasks/setup-RedHat.yml)