---
title: "Bootstrap Java Role"
role: roles/bootstrap_java
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_java]
---

# Bootstrap Java Role Documentation

## Summary

The `bootstrap_java` role installs and configures Java on various operating systems, including RedHat-based, Debian-based, and FreeBSD systems. It ensures the appropriate Java packages are installed and, if configured, sets the `JAVA_HOME` environment variable.

## Variables

| Variable Name                  | Default Value                                                                 | Description                                                                                       |
|--------------------------------|-------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------|
| `bootstrap_java__home`         | `""`                                                                         | Specifies the path to the Java installation directory.                                           |
| `bootstrap_java__set_as_default` | `false`                                                                     | Boolean flag to set the installed Java version as the system default.                             |
| `bootstrap_java__jvm_basedir`  | `/usr/lib/jvm`                                                                | Base directory for JVM installations.                                                             |
| `__bootstrap_java__packages`   | `{{ bootstrap_java__packages \| d(__bootstrap_java__packages_default) \| list }}` | List of Java packages to be installed.                                                           |
| `__bootstrap_java__default_java_package` | `{{ bootstrap_java__package_default \| d(__bootstrap_java__packages[0]) }}` | Default Java package to be set as the system default.                                            |

## Usage

To use the `bootstrap_java` role, include it in your playbook and specify the desired variables. Here is an example playbook:

```yaml
---
- hosts: all
  roles:
    - role: bootstrap_java
      vars:
        bootstrap_java__home: "/usr/lib/jvm/java-11-openjdk"
        bootstrap_java__set_as_default: true
```

## Dependencies

This role does not have any external dependencies. However, it uses the following Ansible modules:

- `ansible.builtin.include_vars`
- `ansible.builtin.debug`
- `ansible.builtin.include_tasks`
- `ansible.builtin.template`
- `ansible.builtin.file`
- `ansible.builtin.apt`
- `community.general.pkgng`
- `ansible.posix.mount`
- `ansible.builtin.package`
- `community.general.alternatives`
- `ansible.builtin.set_fact`

## Best Practices

1. **Specify JAVA_HOME**: Always specify the `bootstrap_java__home` variable to ensure the correct Java installation directory is used.
2. **Set Default Java**: Use the `bootstrap_java__set_as_default` variable to set the installed Java version as the system default, especially in environments where multiple Java versions are installed.
3. **Custom Packages**: If you need to install specific Java packages, override the `__bootstrap_java__packages` variable with the desired package names.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_java/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_java/tasks/main.yml)
- [tasks/setup-Debian.yml](../../roles/bootstrap_java/tasks/setup-Debian.yml)
- [tasks/setup-FreeBSD.yml](../../roles/bootstrap_java/tasks/setup-FreeBSD.yml)
- [tasks/setup-RedHat.yml](../../roles/bootstrap_java/tasks/setup-RedHat.yml)