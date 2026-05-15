# OpenSSH Server

This role configures the OpenSSH daemon. It:

* By default configures the SSH daemon with the normal OS defaults.
* Works across a variety of `UN*X` distributions
* Can be configured by dict or simple variables
* Supports Match sets
* Supports all `sshd_config` options. Templates are programmatically generated.
  (see [`meta/make_option_lists`](meta/make_option_lists))
* Tests the `sshd_config` before reloading sshd.

**WARNING** Misconfiguration of this role can lock you out of your server!
Please test your configuration and its interaction with your users configuration
before using in production!

**WARNING** Digital Ocean allows root with passwords via SSH on Debian and
Ubuntu. This is not the default assigned by this module - it will set
`PermitRootLogin without-password` which will allow access via SSH key but not
via simple password. If you need this functionality, be sure to set
`bootstrap_sshd__PermitRootLogin yes` for those hosts.

## Requirements

* Ubuntu precise, trusty, xenial, bionic, focal, jammy, noble
* Debian wheezy, jessie, stretch, buster, bullseye, bookworm
* EL 6, 7, 8, 9, 10 derived distributions
* All Fedora
* Latest Alpine
* FreeBSD 10.1
* OpenBSD 6.0
* AIX 7.1, 7.2
* OpenWrt 21.03

It will likely work on other flavors and more direct support via suitable
[vars/](vars/) files is welcome.

### Optional requirements

If you want to use advanced functionality of this role that can configure
firewall and selinux for you, which is mostly useful when custom port is used,
the role requires additional collections which are specified in
`meta/collection-requirements.yml`. These are not automatically installed.
If you want to manage `rpm-ostree` systems, additional collections are required.
You must install them like this:

```bash
ansible-galaxy install -vv -r meta/collection-requirements.yml
```

For more information, see `bootstrap_sshd__manage_firewall` and `bootstrap_sshd__manage_selinux`
options below, and the `rpm-ostree` section.  This additional functionality is
supported only on Red Hat based Linux.

## Variables

| Variable Name                                          | Default Value                                                    | Description                                                                |
|--------------------------------------------------------|------------------------------------------------------------------|----------------------------------------------------------------------------|
| `bootstrap_sshd__enable`                               | `true`                                                           | Enable or disable the execution of this role.                              |
| `bootstrap_sshd__skip_defaults`                        | `false`                                                          | Skip applying default configurations if set to true.                       |
| `bootstrap_sshd__manage_service`                       | `true`                                                           | Manage the SSH service (start, stop, enable, disable).                     |
| `bootstrap_sshd__allow_reload`                         | `true`                                                           | Allow reloading of the SSH service when configuration changes are made.    |
| `bootstrap_sshd__install_service`                      | `false`                                                          | Install custom systemd service files for SSHD.                             |
| `bootstrap_sshd__service_template_service`             | `sshd.service.j2`                                                | Template file for the main SSHD service unit.                              |
| `bootstrap_sshd__service_template_at_service`          | `sshd@.service.j2`                                               | Template file for the instanced SSHD service unit.                         |
| `bootstrap_sshd__service_template_socket`              | `sshd.socket.j2`                                                 | Template file for the SSHD socket unit.                                    |
| `bootstrap_sshd__backup`                               | `true`                                                           | Backup existing configuration files before making changes.                 |
| `bootstrap_sshd__sysconfig`                            | `false`                                                          | Manage the `/etc/sysconfig/sshd` file on RedHat-based systems.             |
| `bootstrap_sshd__sysconfig_override_crypto_policy`     | `false`                                                          | Override the crypto policy in the sysconfig file.                          |
| `bootstrap_sshd__sysconfig_use_strong_rng`             | `0`                                                              | Use a strong random number generator in the sysconfig file.                |
| `bootstrap_sshd__config`                               | `{}`                                                             | Custom SSHD configuration options as a dictionary.                         |
| `bootstrap_sshd__config_file`                          | `"{{ __bootstrap_sshd__config_file }}"`                          | Path to the main SSHD configuration file.                                  |
| `bootstrap_sshd__trusted_user_ca_keys_list`            | `[]`                                                             | List of trusted user CA keys.                                              |
| `bootstrap_sshd__principals`                           | `{}`                                                             | Dictionary of authorized principals for users.                             |
| `bootstrap_sshd__packages`                             | `"{{ __bootstrap_sshd__packages }}"`                             | List of packages to install for SSHD.                                      |
| `bootstrap_sshd__config_owner`                         | `"{{ __bootstrap_sshd__config_owner }}"`                         | Owner of the SSHD configuration file.                                      |
| `bootstrap_sshd__config_group`                         | `"{{ __bootstrap_sshd__config_group }}"`                         | Group owner of the SSHD configuration file.                                |
| `bootstrap_sshd__config_mode`                          | `"0644"`                                                         | Permissions mode for the SSHD configuration file.                          |
| `bootstrap_sshd__binary`                               | `"{{ __bootstrap_sshd__binary }}"`                               | Path to the SSHD binary.                                                   |
| `bootstrap_sshd__service`                              | `"{{ __bootstrap_sshd__service }}"`                              | Name of the SSHD service.                                                  |
| `bootstrap_sshd__sftp_server`                          | `"{{ __bootstrap_sshd__sftp_server }}"`                          | Path to the SFTP server binary.                                            |
| `bootstrap_sshd__drop_in_dir_mode`                     | `"{{ __bootstrap_sshd__drop_in_dir_mode }}"`                     | Permissions mode for the drop-in configuration directory.                  |
| `bootstrap_sshd__main_config_file`                     | `"{{ __bootstrap_sshd__main_config_file }}"`                     | Path to the main SSHD configuration file (used for include directives).    |
| `bootstrap_sshd__trustedusercakeys_directory_owner`    | `"{{ __bootstrap_sshd__trustedusercakeys_directory_owner }}"`    | Owner of the directory containing trusted user CA keys.                    |
| `bootstrap_sshd__trustedusercakeys_directory_group`    | `"{{ __bootstrap_sshd__trustedusercakeys_directory_group }}"`    | Group owner of the directory containing trusted user CA keys.              |
| `bootstrap_sshd__trustedusercakeys_directory_mode`     | `"{{ __bootstrap_sshd__trustedusercakeys_directory_mode }}"`     | Permissions mode for the directory containing trusted user CA keys.        |
| `bootstrap_sshd__trustedusercakeys_file_owner`         | `"{{ __bootstrap_sshd__trustedusercakeys_file_owner }}"`         | Owner of the trusted user CA key files.                                    |
| `bootstrap_sshd__trustedusercakeys_file_group`         | `"{{ __bootstrap_sshd__trustedusercakeys_file_group }}"`         | Group owner of the trusted user CA key files.                              |
| `bootstrap_sshd__trustedusercakeys_file_mode`          | `"{{ __bootstrap_sshd__trustedusercakeys_file_mode }}"`          | Permissions mode for the trusted user CA key files.                        |
| `bootstrap_sshd__authorizedprincipals_directory_owner` | `"{{ __bootstrap_sshd__authorizedprincipals_directory_owner }}"` | Owner of the directory containing authorized principals files.             |
| `bootstrap_sshd__authorizedprincipals_directory_group` | `"{{ __bootstrap_sshd__authorizedprincipals_directory_group }}"` | Group owner of the directory containing authorized principals files.       |
| `bootstrap_sshd__authorizedprincipals_directory_mode`  | `"{{ __bootstrap_sshd__authorizedprincipals_directory_mode }}"`  | Permissions mode for the directory containing authorized principals files. |
| `bootstrap_sshd__authorizedprincipals_file_owner`      | `"{{ __bootstrap_sshd__authorizedprincipals_file_owner }}"`      | Owner of the authorized principals files.                                  |
| `bootstrap_sshd__authorizedprincipals_file_group`      | `"{{ __bootstrap_sshd__authorizedprincipals_file_group }}"`      | Group owner of the authorized principals files.                            |
| `bootstrap_sshd__authorizedprincipals_file_mode`       | `"{{ __bootstrap_sshd__authorizedprincipals_file_mode }}"`       | Permissions mode for the authorized principals files.                      |
| `bootstrap_sshd__verify_hostkeys`                      | `auto`                                                           | Verify host keys on startup (can be `true`, `false`, or `auto`).           |
| `bootstrap_sshd__hostkey_owner`                        | `"{{ __bootstrap_sshd__hostkey_owner }}"`                        | Owner of the SSHD host key files.                                          |
| `bootstrap_sshd__hostkey_group`                        | `"{{ __bootstrap_sshd__hostkey_group }}"`                        | Group owner of the SSHD host key files.                                    |
| `bootstrap_sshd__hostkey_mode`                         | `"0640"`                                                         | Permissions mode for the SSHD host key files.                              |
| `bootstrap_sshd__config_namespace`                     | `{}`                                                             | Namespace for configuration snippets (used in `install_namespace.yml`).    |
| `bootstrap_sshd__manage_firewall`                      | `false`                                                          | Manage firewall rules to allow SSH traffic on specified ports.             |
| `bootstrap_sshd__manage_selinux`                       | `false`                                                          | Manage SELinux policies for custom SSH ports.                              |

### Primary role variables

Unconfigured, this role will provide a `sshd_config` that matches the OS default,
minus the comments and in a different order.

#### bootstrap_sshd__enable

If set to *false*, the role will be completely disabled. Defaults to *true*.

#### bootstrap_sshd__skip_defaults

If set to *true*, don't apply default values. This means that you must have a
complete set of configuration defaults via either the `sshd` dict, or
`bootstrap_sshd__Key` variables. Defaults to *false* unless `bootstrap_sshd__config_namespace` is
set or `bootstrap_sshd__config_file` points to a drop-in directory to avoid recursive include.

#### bootstrap_sshd__manage_service

If set to *false*, the service/daemon won't be **managed** at all, i.e. will not
try to enable on boot or start or reload the service.  Defaults to *true*
unless: Running inside a docker container (it is assumed ansible is used during
build phase) or AIX (Ansible `service` module does not currently support `enabled`
for AIX)

#### bootstrap_sshd__allow_reload

If set to *false*, a reload of sshd won't happen on change. This can help with
troubleshooting. You'll need to manually reload sshd if you want to apply the
changed configuration. Defaults to the same value as `bootstrap_sshd__manage_service`.
(Except on AIX, where `bootstrap_sshd__manage_service` is default *false*, but
`bootstrap_sshd__allow_reload` is default *true*)

#### bootstrap_sshd__install_service

If set to *true*, the role will install service files for the ssh service.
Defaults to *false*.

The templates for the service files to be used are pointed to by the variables

* `bootstrap_sshd__service_template_service` (**default**: `templates/sshd.service.j2`)
* `bootstrap_sshd__service_template_at_service` (**default**: `templates/sshd@.service.j2`)
* `bootstrap_sshd__service_template_socket` (**default**: `templates/sshd.socket.j2`)

Using these variables, you can use your own custom templates. With the above
default templates, the name of the installed ssh service will be provided by
the `bootstrap_sshd__service` variable.

#### bootstrap_sshd__manage_firewall

If set to *true*, the SSH port(s) will be opened in firewall. Note, this
works only on Red Hat based OS. The default is *false*.

NOTE: `bootstrap_sshd__manage_firewall` is limited to *adding* ports. It cannot be used
for *removing* ports. If you want to remove ports, you will need to use the
firewall system role directly.

#### bootstrap_sshd__manage_selinux

If set to *true*, the selinux will be configured to allow sshd listening
on the given SSH port(s). Note, this works only on Red Hat based OS.
The default is *false*.

NOTE: `bootstrap_sshd__manage_selinux` is limited to *adding* policy. It cannot be used
for *removing* policy. If you want to remove ports, you will need to use the
selinux system role directly.

#### bootstrap_sshd__config

A dict containing configuration.  e.g.

```yaml
bootstrap_sshd__config:
  Compression: delayed
  ListenAddress:
    - 0.0.0.0
```

#### sshd_`<OptionName>`

Simple variables can be used rather than a dict. Simple values override dict
values. e.g.:

```yaml
bootstrap_sshd__Compression: off
```

In all cases, booleans are correctly rendered as yes and no in sshd
configuration. Lists can be used for multiline configuration items. e.g.

```yaml
bootstrap_sshd__ListenAddress:
  - 0.0.0.0
  - '::'
```

Renders as:

```text
ListenAddress 0.0.0.0
ListenAddress ::
```

#### bootstrap_sshd__match, bootstrap_sshd__match_1 through bootstrap_sshd__match_9

A list of dicts or just a dict for a Match section. Note, that these variables
do not override match blocks as defined in the `sshd` dict. All of the sources
will be reflected in the resulting configuration file. The use of
`bootstrap_sshd__match_*` variant is deprecated and no longer recommended.

#### bootstrap_sshd__backup

When set to *false*, the original `bootstrap_sshd__config` file is not backed up. Default
is *true*.

#### bootstrap_sshd__sysconfig

On RHEL-based systems, sysconfig is used for configuring more details of sshd
service. If set to *true*, this role will manage also the `/etc/sysconfig/sshd`
configuration file based on the following configurations. Default is *false*.

#### bootstrap_sshd__sysconfig_override_crypto_policy

In RHEL8-based systems, this can be used to override system-wide crypto policy
by setting to *true*. Without this option, changes to ciphers, MACs, public
key algorithms will have no effect on the resulting service in RHEL8. Defaults
to *false*.

#### bootstrap_sshd__sysconfig_use_strong_rng

In RHEL-based systems (before RHEL9), this can be used to force sshd to reseed
openssl random number generator with the given amount of bytes as an argument.
The default is *0*, which disables this functionality. It is not recommended to
turn this on if the system does not have hardware random number generator.

#### bootstrap_sshd__config_file

The path where the openssh configuration produced by this role should be saved.
This is useful mostly when generating configuration snippets to Include from
drop-in directory (default in Fedora and RHEL9).

When this path points to a drop-in directory (like
`/etc/ssh/sshd_config.d/00-custom.conf`), the main configuration file (defined
with the variable `bootstrap_sshd__main_config_file`) is checked to contain a proper
`Include` directive.

#### bootstrap_sshd__main_config_file

When the system is using drop-in directory, this option can be used to set
a path to the main configuration file and let you configure only the drop-in
configuration file using `bootstrap_sshd__config_file`. This is useful in cases when
you need to configure second independent sshd service with different
configuration file. This is also the file used in the service file.

On systems without drop-in directory, it defaults to `None`. Otherwise it
defaults to `/etc/ssh/sshd_config`. When the `bootstrap_sshd__config_file` is set
outside of the drop in directory (its parent directory is not
`bootstrap_sshd__main_config_file` ~ '.d'), this variable is ignored.

#### bootstrap_sshd__config_namespace

By default (*null*), the role defines whole content of the configuration file
including system defaults. You can use this variable to invoke this role from
other roles or from multiple places in a single playbook as an alternative to
using a drop-in directory. The `bootstrap_sshd__skip_defaults` is ignored and no system
defaults are used in this case.

When this variable is set, the role places the configuration that you specify
to configuration snippets in a existing configuration file under the given
namespace. You need to select different namespaces when invoking the role
several times.

Note that limitations of the openssh configuration file still apply. For
example, only the first option specified in a configuration file is effective
for most of the variables.

Technically, the role places snippets in `Match all` blocks, unless they contain
other match blocks, to ensure they are applied regardless of the previous match
blocks in the existing configuration file. This allows configuring any
non-conflicting options from different roles invocations.

#### bootstrap_sshd__config_owner, bootstrap_sshd__config_group, bootstrap_sshd__config_mode

Use these variables to set the ownership and permissions for the openssh
configuration file that this role produces.

#### bootstrap_sshd__verify_hostkeys

By default (*auto*), this list contains all the host keys that are present in
the produced configuration file. If there are none, the OpenSSH default list
will be used after excluding non-FIPS approved keys in FIPS mode. The paths
are checked for presence and new keys are generated if they are missing.
Additionally, permissions and file owners are set to sane defaults. This is
useful if the role is used in deployment stage to make sure the service is
able to start on the first attempt.

To disable this check, set this to empty list.

#### bootstrap_sshd__hostkey_owner, bootstrap_sshd__hostkey_group, bootstrap_sshd__hostkey_mode

Use these variables to set the ownership and permissions for the host keys from
the above list.

### Secondary role variables

These variables are used by the role internals and can be used to override the
defaults that correspond to each supported platform. They are not tested and
generally are not needed as the role will determine them from the OS type.

#### bootstrap_sshd__packages

Use this variable to override the default list of packages to install.

#### bootstrap_sshd__binary

The path to the openssh executable

#### bootstrap_sshd__service

The name of the openssh service. By default, this variable contains the name of
the ssh service that the target platform uses. But it can also be used to set
the name of the custom ssh service when the `bootstrap_sshd__install_service` variable is
used.

#### bootstrap_sshd__sftp_server

Default path to the sftp server binary.

### Variables Exported by the Role

#### bootstrap_sshd__has_run

This variable is set to *true* after the role was successfully executed.

## Configure SSH certificate authentication

To configure SSH certificate authentication on your SSH server, you need to provide at least the trusted user CA key, which will be used to validate client certificates against.
This is done with the `bootstrap_sshd__trusted_user_ca_keys_list` variable.

If you need to map some of the authorized principals to system users, you can do that using the `bootstrap_sshd__principals` variable.

### Additional variables

#### bootstrap_sshd__trusted_user_ca_keys_list

List of the trusted user CA public keys in OpenSSH (one-line) format (mandatory).

#### bootstrap_sshd__trustedusercakeys_directory_owner, shsd_trustedusercakeys_directory_group, bootstrap_sshd__trustedusercakeys_directory_mode

Use these variables to set the ownership and permissions for the Trusted User CA Keys directory. Defaults are respectively *root*, *root* and *0755*.

#### bootstrap_sshd__trustedusercakeys_file_owner, shsd_trustedusercakeys_file_group, bootstrap_sshd__trustedusercakeys_file_mode

Use these variables to set the ownership and permissions for the Trusted User CA Keys file. Defaults are respectively *root*, *root* and *0640*.

#### bootstrap_sshd__principals

A dict containing principals for users in the os (optional). e.g.

```yaml
bootstrap_sshd__principals:
  admin:
    - frontend-admin
    - backend-admin
  somelinuxuser:
    - some-principal-defined-in-certificate
```

#### bootstrap_sshd__authorizedprincipals_directory_owner, shsd_authorizedprincipals_directory_group, bootstrap_sshd__authorizedprincipals_directory_mode

Use these variables to set the ownership and permissions for the Authorized Principals directory. Defaults are respectively *root*, *root* and *0755*.

#### bootstrap_sshd__authorizedprincipals_file_owner, shsd_authorizedprincipals_file_group, bootstrap_sshd__authorizedprincipals_file_mode

Use these variables to set the ownership and permissions for the Authorized Principals file. Defaults are respectively *root*, *root* and *0644*.

### Additional configuration

The SSH server needs this information stored in files so in addition to the above variables, respective configuration options `TrustedUserCAKeys` (mandatory) and `AuthorizedPrincipalsFile` (optional) need to be present the `sshd` dictionary when invoking the role. For example:

```yaml
bootstrap_sshd__config:
  TrustedUserCAKeys: /etc/ssh/path-to-trusted-user-ca-keys/trusted-user-ca-keys.pub
  AuthorizedPrincipalsFile: "/etc/ssh/path-to-auth-principals/auth_principals/%u"
```

To learn more about SSH Certificates, here is a [nice tutorial to pure SSH certificates, from wikibooks](https://en.wikibooks.org/wiki/OpenSSH/Cookbook/Certificate-based_Authentication).

To understand principals and to set up SSH certificates with Vault, this is a [well-explained tutorial from Hashicorp](https://www.hashicorp.com/blog/managing-ssh-access-at-scale-with-hashicorp-vault).

## Dependencies

None

For tests, the `ansible.posix` collection is required for the `mount` role to
emulate FIPS mode.

## Usage

To use the `bootstrap_sshd` role, include it in your playbook and customize the variables as needed:

```yaml
- hosts: all
  roles:
    - role: dettonville.bootstrap_sshd
      vars:
        bootstrap_sshd__config:
          Port: 2222
          PasswordAuthentication: no
          PermitRootLogin: no
```

### Example Playbook

**DANGER!** This example is to show the range of configuration this role
provides. Running it will likely break your SSH access to the server!

```yaml
---
- hosts: all
  vars:
    bootstrap_sshd__skip_defaults: true
    bootstrap_sshd__config:
      Compression: true
      ListenAddress:
        - "0.0.0.0"
        - "::"
      GSSAPIAuthentication: false
      Match:
        - Condition: "Group user"
          GSSAPIAuthentication: true
    bootstrap_sshd__UsePrivilegeSeparation: false
    bootstrap_sshd__match:
        - Condition: "Group xusers"
          X11Forwarding: true
  roles:
    - role: boostrap_sshd
```

Results in:

```text
# Ansible managed: ...
Compression yes
GSSAPIAuthentication no
UsePrivilegeSeparation no
Match Group user
  GSSAPIAuthentication yes
Match Group xusers
  X11Forwarding yes
```

Since Ansible 2.4, the role can be invoked using `include_role` keyword,
for example:

```yaml
---
- hosts: all
  become: true
  tasks:
  - name: "Configure sshd"
    ansible.builtin.include_role:
      name: bootstrap_sshd
    vars:
      bootstrap_sshd__skip_defaults: true
      bootstrap_sshd__config:
        Compression: true
        ListenAddress:
          - "0.0.0.0"
          - "::"
        GSSAPIAuthentication: false
        Match:
          - Condition: "Group user"
            GSSAPIAuthentication: true
      bootstrap_sshd__UsePrivilegeSeparation: false
      bootstrap_sshd__match:
          - Condition: "Group xusers"
            X11Forwarding: true
```

You can just add a configuration snippet with the `bootstrap_sshd__config_namespace`
option:

```yaml
---
- hosts: all
  tasks:
  - name: Configure sshd to accept some useful environment variables
    ansible.builtin.include_role:
      name: bootstrap_sshd
    vars:
      bootstrap_sshd__config_namespace: accept-env
      bootstrap_sshd__config:
        # there are some handy environment variables to accept
        AcceptEnv:
          LANG
          LS_COLORS
          EDITOR
```

The following snippet will be added to the default configuration file
(if not yet present):

```text
# BEGIN sshd system role managed block: namespace accept-env
Match all
  AcceptEnv LANG LS_COLORS EDITOR
# END sshd system role managed block: namespace accept-env
```

More example playbooks can be found in [`examples/`](examples/) directory.

## Template Generation

The [`sshd_config.j2`](templates/sshd_config.j2) and
[`sshd_config_snippet.j2`](templates/sshd_config_snippet.j2) templates are
programmatically generated by the scripts in meta. New options should be added
to the `options_body` and/or `options_match`.

To regenerate the templates, from within the `meta/` directory run:
`./make_option_lists`

## rpm-ostree

See README-ostree.md

## Reference 

* https://github.com/willshersystems/ansible-sshd
