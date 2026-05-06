---
title: "Bootstrap Rsyncd Role"
role: roles/bootstrap_rsyncd
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_rsyncd]
---

# Role Documentation: `bootstrap_rsyncd`

## Overview

The `bootstrap_rsyncd` Ansible role is designed to automate the setup and configuration of the Rsync daemon (`rsyncd`) on target hosts. It ensures that Rsync is installed, configured, and running correctly, facilitating secure file synchronization between a source host and a remote host.

## Role Variables

### Default Variables

The following variables are defined in `defaults/main.yml`:

- **`rsync_packages`**: A list of packages to be installed for Rsync. By default, it includes only the `rsync` package.
  ```yaml
  rsync_packages:
    - rsync
  ```

- **`rsyncd_config`**: The path to the Rsync daemon configuration file.
  ```yaml
  rsyncd_config: /etc/rsyncd.conf
  ```

- **`rsyncd_service`**: The name of the Rsync service.
  ```yaml
  rsyncd_service: rsyncd.service
  ```

- **`rsyncd_temp_sudoers_file`**: The path to a temporary sudoers file used for granting permissions to the Ansible user for running Rsync with elevated privileges.
  ```yaml
  rsyncd_temp_sudoers_file: /etc/sudoers.d/rsyncuser
  ```

## Tasks

### `tasks/main.yml`

1. **Install Rsync**: Ensures that Rsync is installed on both the source and remote hosts.
   - Uses the `ansible.builtin.package` module to install the necessary packages.

2. **Set `__rsync_dict`**: Creates a fact dictionary containing installation status and IP addresses of the target hosts.
   - Utilizes the `ansible.builtin.set_fact` module to store this information.

3. **Backup `rsyncd.conf`**: Backs up the existing Rsync configuration file if it exists and has not been modified.
   - Uses the `ansible.builtin.copy` module with `remote_src: true`.

4. **Start and Enable the Service**: Starts and enables the Rsync service on both the source and remote hosts.
   - Employs the `ansible.builtin.service` module.

5. **Configure `/etc/rsyncd.conf`**: Configures the Rsync daemon using a Jinja2 template.
   - Utilizes the `ansible.builtin.template` module to generate the configuration file.

6. **Restart Rsyncd**: Restarts the Rsync service on the remote host to apply the new configuration.
   - Uses the `ansible.builtin.service` module with `become: true`.

7. **Run Rsync**: Executes a synchronization command from the source host to the remote host.
   - Utilizes the `ansible.builtin.command` module.

8. **Restore Backup of `rsyncd.conf`**: Restores the backup of the Rsync configuration file if necessary.
   - Uses the `ansible.builtin.copy` module with `remote_src: true`.

### `tasks/execute_sync.yml`

1. **Assert Variables are Defined**: Ensures that required variables (`remote_host`, `source_filesystem_path`) are defined and not empty.
   - Utilizes the `ansible.builtin.assert` module.

2. **Perform Stat on Source Filesystem Path**: Checks if the source filesystem path exists on the source host.
   - Uses the `ansible.builtin.stat` module.

3. **Error Handling for Source Path**: Handles errors related to the source filesystem path not existing.
   - Utilizes a block and rescue structure with `ansible.builtin.assert` and `ansible.builtin.set_fact`.

4. **Synchronize Files**: Synchronizes files from the source host to the remote host using Rsync if no errors were detected.
   - Employs the `ansible.builtin.command` module.

### `tasks/rsync_cleanup.yml`

1. **Clean Up Temporary Sudoers Files**: Removes temporary sudoers files used for granting permissions.
   - Uses the `ansible.builtin.file` module.

2. **Clean Up SELinux State**: Cleans up any changes made to SELinux policies and booleans if necessary.
   - Utilizes a block structure with `ansible.builtin.command` and `ansible.builtin.file`.

3. **Show Rsync Variables**: Displays internal variables related to the Rsync configuration and service state.
   - Uses the `ansible.builtin.debug` module.

4. **Restore `rsyncd.conf` to Previous State**: Restores the backup of the Rsync configuration file if it was modified.
   - Uses the `ansible.builtin.copy` module with `remote_src: true`.

5. **Restore Rsyncd Service to Previous State**: Restores the Rsync service to its previous state (started or stopped).
   - Utilizes the `ansible.builtin.service` module.

### `tasks/rsync_listener.yml`

1. **Assert Remote Filesystem Path is Defined**: Ensures that the `remote_filesystem_path` variable is defined and not empty.
   - Utilizes the `ansible.builtin.assert` module.

2. **Gather Current Services State**: Gathers facts about the current state of services on the remote host.
   - Uses the `ansible.builtin.service_facts` module.

3. **Set Rsyncd Service State**: Sets the desired state of the Rsync service based on its current state.
   - Utilizes the `ansible.builtin.set_fact` module.

4. **Gather Current SELinux State**: Checks the current SELinux enforcement mode.
   - Uses the `ansible.builtin.command` module.

5. **Configure SELinux**: Configures SELinux policies and booleans if necessary to allow Rsync operations.
   - Utilizes a block structure with `ansible.builtin.copy`, `ansible.builtin.command`, and `ansible.builtin.set_fact`.

6. **Configure Rsyncd**: Configures the Rsync daemon using a static configuration string.
   - Uses the `ansible.builtin.copy` module.

7. **Create Remote Filesystem Path**: Ensures that the remote filesystem path exists as a directory.
   - Utilizes the `ansible.builtin.file` module.

8. **Set Rsyncd Backup Path**: Sets a fact containing the backup path of the Rsync configuration file if it was modified.
   - Uses the `ansible.builtin.set_fact` module.

9. **(Re)start Rsyncd**: Restarts the Rsync service to apply the new configuration.
   - Utilizes the `ansible.builtin.service` module.

### `tasks/rsync_prep.yml`

1. **Gather Facts**: Gathers facts about the target host to determine its operating system and version.
   - Uses the `ansible.builtin.gather_facts` module.

2. **Ensure Rsync is Installed (RHEL 7 and Earlier)**: Installs Rsync on Red Hat Enterprise Linux versions 7 and earlier.
   - Utilizes the `ansible.builtin.package` module.

3. **Ensure Rsync is Installed (RHEL 8 and Later)**: Installs Rsync and its daemon package on Red Hat Enterprise Linux versions 8 and later.
   - Uses the `ansible.builtin.package` module.

4. **Configure Temporary Sudo Permissions for Ansible Rsync**: Configures temporary sudo permissions for the Ansible user to run Rsync with elevated privileges.
   - Utilizes the `ansible.builtin.lineinfile` module.

## Important Notes

- **Double-underscore Variables**: Variables prefixed with double underscores (e.g., `__rsync_failures_detected`) are internal and should not be modified outside of this role.
  
- **No Related Roles**: This documentation does not include related roles. The `bootstrap_rsyncd` role is self-contained.

## Usage Example

Below is an example playbook that demonstrates how to use the `bootstrap_rsyncd` role:

```yaml
---
- name: Bootstrap Rsync Daemon and Synchronize Files
  hosts: all
  become: true
  vars:
    remote_host: "remote.example.com"
    source_filesystem_path: "/path/to/source/files"
    remote_filesystem_path: "/path/to/remote/files"
  roles:
    - role: bootstrap_rsyncd
```

This playbook will install and configure the Rsync daemon on all hosts specified in your inventory, synchronize files from the source host to the remote host, and clean up any temporary configurations after the synchronization is complete.