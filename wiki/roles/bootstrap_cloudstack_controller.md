---
title: "Bootstrap Cloudstack Controller Role"
role: roles/bootstrap_cloudstack_controller
category: Roles
type: ansible-role
tags: [ansible, role, bootstrap_cloudstack_controller]
---

# Role Documentation: `bootstrap_cloudstack_controller`

## Overview

The `bootstrap_cloudstack_controller` role is designed to automate the setup and configuration of a CloudStack management server. This role handles various tasks including setting up NTP, configuring MySQL, installing necessary packages, and configuring network settings for CloudStack.

## Role Path
```
roles/bootstrap_cloudstack_controller
```

## Variables

### Default Variables

#### `defaults/devcloud.yml`
- **zones**: Defines the zones in the CloudStack environment.
  - **name**: Name of the zone.
  - **physical_networks**: Configuration details for physical networks within the zone.
    - **broadcastdomainrange**: Range of broadcast domains.
    - **name**: Name of the network.
    - **traffictypes**: Types of traffic supported by the network.
      - **typ**: Type of traffic (e.g., Guest, Management).
    - **providers**: Providers for the physical network.
      - **broadcastdomainrange**: Range of broadcast domains.
      - **name**: Name of the provider.
  - **dns1** and **dns2**: Primary and secondary DNS servers.
  - **securitygroupenabled**: Whether security groups are enabled.
  - **localstorageenabled**: Whether local storage is enabled.
  - **networktype**: Type of network (e.g., Basic, Advanced).
  - **pods**: Configuration details for pods within the zone.
    - **name**: Name of the pod.
    - **gateway**, **netmask**, **startip**, **endip**: Network configuration for the pod.
    - **guestIpRanges**: IP ranges for guest networks.
      - **gateway**, **netmask**, **startip**, **endip**: Guest network IP range details.
    - **clusters**: Clusters within the pod.
      - **clustername**: Name of the cluster.
      - **hypervisor**: Hypervisor type (e.g., KVM).
      - **hosts**: Hosts in the cluster.
        - **username**: Username for accessing the host.
        - **url**: URL of the host.
        - **password**: Password for accessing the host.
  - **internaldns1**: Internal DNS server.
  - **secondaryStorages**: Configuration details for secondary storage.
    - **url**: URL of the secondary storage.
    - **provider**: Provider type (e.g., NFS).
- **logger**: Logger configuration.
  - **name**: Name of the logger.
  - **file**: Log file path.
- **mgtSvr**: Management server configuration.
  - **mgtSvrIp**: IP address of the management server.
  - **port**: Port for the management server.
  - **hypervisor**: Hypervisor type (e.g., kvm).
- **dbSvr**: Database server configuration.
  - **dbSvr**: IP address of the database server.
  - **port**: Port for the database server.
  - **user**: Username for accessing the database.
  - **passwd**: Password for accessing the database.
  - **db**: Name of the database.

#### `defaults/main.yml`
- **CSAdminUser**: Admin username for CloudStack.
- **CSMySQLPwd**: MySQL password.
- **CSAdminPwd**: Admin password for CloudStack.
- **CloudDBPass**: Password for the cloud user in the database.
- **CSHostPassword**: Host password.
- **XSPassword**: XenServer password.
- **python_dist_version**: Python distribution version.
- **cloudstack_conf_file**: Configuration file for CloudStack.
- **cs_resource_prefix**: Prefix for resource names.
- **cs_common_template**: Common template name.
- **cs_common_service_offering**: Common service offering.
- **cs_common_zone_adv**: Advanced zone configuration.
- **cs_common_zone_basic**: Basic zone configuration.
- **cs_zone**: Zone configuration (not defined in the provided snippet).
- **cs_region**: Region name.
- **cs_group**: Group configuration (not defined in the provided snippet).
- **cs_force**: Force flag for certain operations.
- **cs_offering**: Service offering.
- **cs_template**: Template name.
- **cs_affinity_groups**: Affinity groups (empty list by default).
- **cs_security_groups**: Security groups (default is `["default"]`).
- **cs_instance_name**: Instance name, defaults to the short hostname of the inventory host.
- **cs_instance_affinity_group**: Affinity group for the instance (not defined in the provided snippet).
- **cs_instance_security_groups**: Security groups for the instance (defaults to `["default"]`).
- **cs_instance_ssh_key**: SSH key for the instance, defaults to the current user and hostname.
- **cs_ssh_keys**: List of SSH keys (defaults to `[cs_instance_ssh_key]`).
- **cs_private_network**: Private network name.
- **cs_dns_domain**: DNS domain (not defined in the provided snippet).
- **cs_user_data**: User data for instances, includes managing `/etc/hosts` and setting FQDN.
- **cloudstack_setup_nfs_share**: Flag to setup NFS share.
- **cloudstack_mount_nfs_share**: Flag to mount NFS share.
- **cloudstack_reset_api_client_token**: Flag to reset the API client token.
- **CMConfig**: Configuration for CloudStack Manager, includes various settings like IP addresses, DNS servers, network configurations, and more.

## Tasks

### `tasks/add-host.yml`
- **Start cloudstack-agent Service**: Ensures that the `cloudstack-agent` service is started and enabled.
- **Adding host**: Adds a host to the specified cluster in CloudStack. Includes error handling and retry logic if the initial attempt fails.
  - **create host**: Uses the `ngine_io.cloudstack.host` module to add the host.
  - **Display exception**: Displays an error message if adding the host fails.
  - **Restart cloudstack-agent Service**: Restarts the `libvirtd` and `cloudstack-agent` services in case of failure.
- **Print host info**: Prints information about the added host using the `ansible.builtin.debug` module.
- **verify test create host**: Asserts that the pod and cluster names match the expected values.

### `tasks/configure.yml`
- **Install python packages for CS config with pip**: Installs necessary Python packages (`sshpubkeys`, `cs`) using pip3.
- **Validate input - CSHostPassword**: Fails the playbook if the `CSHostPassword` variable is empty or incorrect.
- **Configure zone and resources**: Configures a zone in CloudStack using the `ngine_io.cloudstack.zone` module.
  - **Print zone info**: Prints information about the configured zone.
- **Setup network configs**: Sets up physical networks, traffic types, and enables the physical network.

### `tasks/initialize-api-config.yml`
- **Setup script dir**: Creates a directory for CloudStack utility scripts.
- **Setup cs-utils in {{ CSUtils.AppDir }}**: Copies the `cs-utils` directory to the specified application directory.
- **Setup cs-utils conf**: Configures the `cs-utils` configuration file using a template.
- **install python packages into cs-utils venv**: Installs Python packages required by `cs-utils` into a virtual environment.
- **Wait for {{ CSMgtClientEndpoint }} to come up**: Waits until the CloudStack management client endpoint is reachable.
- **Stat {{ cloudstack_conf_file }}**: Checks if the CloudStack configuration file exists.
- **Get API key from {{ cloudstack_conf_file }}**: Retrieves or creates an API key from the CloudStack configuration file.
  - **Move {{ cloudstack_conf_file }} to {{ cloudstack_conf_file }}.{{ snap_date }}**: Backs up the existing configuration file before creating a new one.
  - **Create {{ cloudstack_conf_file }} on {{ ansible_host }}**: Creates the CloudStack configuration file using `cs-utils.py`.
  - **Fetch file {{ cloudstack_conf_file }}**: Fetches the created configuration file to the local machine.
  - **Display apikey**: Displays the API key from the configuration file.
- **Get API key from {{ cloudstack_conf_file }}**: Sets facts for the CloudStack endpoint, API key, and API secret.

### `tasks/main.yml`
- **Set OS specific variables**: Includes OS-specific variable files based on the distribution or OS family.
- **Setup Cloudstack Manager**: Includes tasks to set up the CloudStack manager.
  - **Setup Cloudstack Manager**: Includes tasks to initialize the API configuration and configure the CloudStack manager.

### `tasks/setup.yml`
- **Install NTP**: Installs the NTP package.
- **Configure NTP file**: Configures the NTP settings using a template.
- **Start the NTP daemon**: Starts and enables the NTP service.
- **Set SELinux to permissive**: Sets SELinux to permissive mode.
- **Configure MySQL repo**: Configures the MySQL repository using a template.
- **Configure CloudStack repo**: Configures the CloudStack repository using a template.
- **Install utility cloudstack script files**: Copies utility scripts for CloudStack to `/opt/scripts`.
- **Create /opt/scripts/.env**: Creates an environment file for CloudStack scripts.
- **Install python dependencies for cloudstack db/management scripts**: Installs Python dependencies required by CloudStack database and management scripts.
- **Install cloudstack dependent packages**: Installs necessary packages for CloudStack.
- **configure firewall for cloudstack node**: Configures the firewall using the `bootstrap_linux_firewalld` role if enabled.
- **Download vhd-util for Xenserver hypervisors**: Downloads the `vhd-util` tool for XenServer hypervisors.
- **Copy vhd-util for Xenserver hypervisors**: Copies the `vhd-util` tool to the appropriate directory.

### `tasks/setupdb.yml`
- **Create /etc/my.cnf**: Configures MySQL settings using a template.
- **Create .my.cnf**: Creates a `.my.cnf` file with root user credentials.
- **Start/enable the MySQL daemon**: Starts and enables the MySQL service.
- **Secure MySQL installation / change root user password**: Changes the root user password for MySQL.
- **Restart mysqld service**: Restarts the MySQL service.
- **Add cloud user**: Adds a `cloud` user to MySQL with appropriate privileges.
- **Add cloud user to sudoers list**: Adds the `cloud` user to the sudoers list.
- **check if DB exists**: Checks if the `cloud` database exists.

## Handlers

### `handlers/main.yml`
- **restart cloudstack**: Restarts the CloudStack management service.
- **start nfs server**: Starts and enables the NFS service.
- **restart ntp**: Restarts the NTP service.
- **restart iptables**: Restarts the iptables service.
- **save iptables**: Saves the current iptables configuration.

## Important Notes

- Double-underscore variables are internal only.
- Do not invent related roles.
- Use only standard GitHub Markdown for documentation.

This comprehensive guide provides a detailed overview of the `bootstrap_cloudstack_controller` role, including its variables, tasks, and handlers. This should help in understanding and utilizing the role effectively in your Ansible playbooks.