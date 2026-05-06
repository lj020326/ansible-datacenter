---
title: "Bootstrap Cobbler Resources Role"
role: roles/bootstrap_cobbler_resources
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_cobbler_resources]
---

# Role Documentation: `bootstrap_cobbler_resources`

## Overview

The `bootstrap_cobbler_resources` role is designed to automate the setup and configuration of Cobbler, a Linux provisioning system. This role ensures that Cobbler templates are present, ISO files are downloaded and mounted, profiles are created, and kickstart files are configured.

## Role Variables

### Default Variables (`defaults/main.yml`)

| Variable Name                    | Description                                                                                     | Default Value                                                                 |
|----------------------------------|-------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------|
| `cobbler_default_password_crypted` | The crypted password for the Cobbler default user.                                              | `$1$asdf3421$dEw9zCFxyo9KG3Y2xsd/n0`                                          |
| `cobbler_web_password_crypted`   | The crypted password for the Cobbler web interface user.                                        | `a2d6bae81669d707b72c0bd9806e01f3`                                            |
| `cobbler_pxe_just_once`          | If set to true, PXE boot will only occur once per system.                                         | `true`                                                                        |
| `cobbler_manage_dhcp`            | Whether Cobbler should manage DHCP.                                                             | `false`                                                                       |
| `cobbler_manage_dns`             | Whether Cobbler should manage DNS.                                                              | `false`                                                                       |
| `cobbler_isos_path`              | The path where ISO files will be stored.                                                        | `/etc/cobbler/distro-isos`                                                    |
| `cobbler_isos_mount_path`        | The path where ISO files will be mounted.                                                       | `/mnt/cobbler`                                                                |
| `cobbler_isos_delete`            | Whether to delete ISO files after importing them into Cobbler.                                  | `true`                                                                        |
| `cobbler_profiles`               | A list of profiles to be created in Cobbler, including the name, architecture, and URL for the ISO.| `[ { name: centos7, arch: x86_64, url: http://mirror.switch.ch/ftp/mirror/centos/7/isos/x86_64/CentOS-7-x86_64-DVD-1810.iso } ]` |
| `cobbler_kickstart_path`         | The path where kickstart files will be stored.                                                  | `/var/lib/cobbler/kickstarts`                                                 |
| `cobbler_templates_force`        | Whether to force the update of Cobbler templates.                                               | `true`                                                                        |

## Tasks (`tasks/main.yml`)

1. **Set OS Specific Variables**
   - Includes variables specific to the operating system or distribution.

2. **Ensure Cobbler Templates are Present**
   - Copies template files to `/etc/cobbler/` if `cobbler_templates_force` is true.
   - Notifies a handler to restart `cobblerd`.

3. **Ensure `di_dists` Directive is Set in `/etc/debmirror.conf`**
   - Updates the `@di_dists` directive in `/etc/debmirror.conf`.

4. **Ensure `di_archs` Directive is Set in `/etc/debmirror.conf`**
   - Updates the `@di_archs` directive in `/etc/debmirror.conf`.

5. **Ensure Cobbler Profile Folder Exists**
   - Creates directories for each profile under `/var/www/cobbler/ks_mirror/`.

6. **Ensure Folder for ISO Files Exist**
   - Ensures that the directory specified by `cobbler_isos_path` exists.

7. **Ensure ISO Mount Path Exists**
   - Ensures that the directory specified by `cobbler_isos_mount_path` exists.

8. **Ensure ISO Files are Present**
   - Downloads ISO files from URLs specified in `cobbler_profiles`.

9. **Ensure ISOs Are Mounted**
   - Mounts each downloaded ISO file to a path under `cobbler_isos_mount_path`.

10. **Ensure Distributions Are Imported**
    - Imports distributions into Cobbler if they are not already present.

11. **Ensure Kickstart Template is Copied to Cobbler Server**
    - Copies kickstart templates specified in `cobbler_profiles` to the Cobbler server.

12. **Ensure Kickstart Option is Set**
    - Sets the kickstart option for each profile in Cobbler.

13. **Ensure ISOs Are Unmounted After Import**
    - Unmounts ISO files after they have been imported into Cobbler.

14. **Ensure ISOs Are Deleted After Import**
    - Deletes ISO files if `cobbler_isos_delete` is true.

## Handlers (`handlers/main.yml`)

1. **Restart Apache**
   - Restarts the Apache service to apply configuration changes.

2. **Restart Cobblerd**
   - Restarts the Cobbler daemon to apply configuration changes.

3. **Cobbler Sync**
   - Runs `cobbler sync` to synchronize all configurations with Cobbler's internal database.

## Important Notes

- **Double-underscore variables** are intended for internal use only and should not be modified.
- This role does not define any related roles; it is self-contained.
- The documentation adheres strictly to standard GitHub Markdown formatting.

This comprehensive guide ensures that the `bootstrap_cobbler_resources` role is used effectively, providing a robust setup for Cobbler automation.