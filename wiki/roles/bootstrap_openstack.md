---
title: Bootstrap OpenStack Role Documentation
role: bootstrap_openstack
category: Infrastructure
type: Ansible Role
tags: openstack, kolla, ansible, virtualenv
---

## Summary

The `bootstrap_openstack` role is designed to set up and configure an OpenStack environment using Kolla-Ansible. It handles the creation of necessary directories, installation of Python packages into a virtual environment, generation of configuration files, and execution of Kolla-Ansible playbooks for bootstrapping and prechecking the OpenStack deployment.

## Variables

| Variable Name                                | Default Value                                                                                   | Description                                                                                                                                                                                                 |
|----------------------------------------------|-------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `openstack_release`                          | `train`                                                                                         | Specifies the OpenStack release to be installed.                                                                                                                                                            |
| `openstack_network_interface`                | `eth0`                                                                                        | The network interface used for internal communication within the OpenStack cluster.                                                                                                                         |
| `openstack_neutron_external_interface`       | `eth1`                                                                                        | The network interface used for external traffic in Neutron.                                                                                                                                                 |
| `openstack_kolla_internal_vip_address`       | `10.1.0.250`                                                                                  | Virtual IP address for internal communication within the Kolla deployment.                                                                                                                                  |
| `openstack_docker_registry`                  | `registry.example.int:5000`                                                                   | Docker registry URL used by Kolla-Ansible to pull images.                                                                                                                                                   |
| `openstack_ansible_version`                  | `2.9.4`                                                                                       | Version of Ansible to be installed in the virtual environment.                                                                                                                                                |
| `openstack_python_dist_version`              | `3`                                                                                           | Python distribution version used for the OpenStack deployment.                                                                                                                                                |
| `openstack_venv_path`                        | `/opt/openstack`                                                                              | Path where the OpenStack virtual environment will be created.                                                                                                                                               |
| `ansible_openstack_python_interpreter`       | `"{{ openstack_venv_path }}/bin/python"`                                                       | Python interpreter path within the virtual environment.                                                                                                                                                     |
| `openstack_venv_use_requirements_template`   | `true`                                                                                        | Whether to use a template for requirements.txt or specify packages directly in variables.                                                                                                                     |
| `openstack_kolla_options`                    | `{}`                                                                                            | Custom Kolla-Ansible options that override the default settings.                                                                                                                                            |
| `openstack_kolla_default_options`            | <pre>{<br>&nbsp;&nbsp;kolla_base_distro: centos,<br>&nbsp;&nbsp;kolla_install_type: source,<br>&nbsp;&nbsp;openstack_release: train<br>}</pre>               | Default Kolla-Ansible options used for the deployment.                                                                                                                                                      |
| `openstack_kolla_tpl_options`                | `"{{ openstack_kolla_default_options \| combine(openstack_kolla_options) }}"`                   | Combined Kolla-Ansible options from default and custom settings.                                                                                                                                          |
| `openstack_kolla_pb_inventory_dir`           | `"{{ '~/.openstack-kolla' \| expanduser }}"`                                                    | Directory where the Kolla-Ansible inventory file will be stored.                                                                                                                                            |
| `openstack_kolla_pb_inventory_file`          | `hosts-openstack.ini`                                                                         | Name of the Kolla-Ansible inventory file.                                                                                                                                                                   |
| `openstack_kolla_pb_debug_flags`             | `{}`                                                                                            | Debug flags for running Kolla-Ansible playbooks.                                                                                                                                                            |
| `openstack_kolla_run_playbooks`              | `false`                                                                                       | Whether to run Kolla-Ansible playbooks as part of this role execution.                                                                                                                                      |
| `openstack_kolla_playbooks`                  | <pre>- kolla_action: bootstrap-servers<br>&nbsp;&nbsp;playbook: share/kolla-ansible/ansible/kolla-host.yml<br>- kolla_action: precheck<br>&nbsp;&nbsp;playbook: share/kolla-ansible/ansible/site.yml</pre> | List of Kolla-Ansible playbooks to be executed.                                                                                                                                                             |
| `openstack_pip_packages`                     | <pre>- name: ansible<br>&nbsp;&nbsp;version: "{{ openstack_ansible_version }}"<br>- name: kolla-ansible<br>- name: kolla<br>- name: python-openstackclient<br>- name: python-cinderclient<br>- name: python-glanceclient<br>- name: python-heatclient<br>- name: python-keystoneclient<br>- name: python-neutronclient<br>- name: python-novaclient<br>- name: python-swiftclient<br>- name: python-designateclient</pre> | List of Python packages to be installed in the virtual environment.                                                                                                                                         |

## Usage

To use the `bootstrap_openstack` role, include it in your Ansible playbook and provide any necessary variables as needed. Here is an example:

```yaml
- hosts: openstack_servers
  roles:
    - role: bootstrap_openstack
      vars:
        openstack_release: train
        openstack_network_interface: eth0
        openstack_neutron_external_interface: eth1
        openstack_kolla_internal_vip_address: 10.1.0.250
        openstack_docker_registry: registry.example.int:5000
        openstack_ansible_version: 2.9.4
        openstack_python_dist_version: 3
        openstack_venv_path: /opt/openstack
        openstack_kolla_run_playbooks: true
```

## Dependencies

- `ansible.builtin` modules (file, template, command, pip)
- `community.general.filetree`
- Kolla-Ansible and its dependencies

## Tags

- `bootstrap-openstack-settings`: Applies to tasks related to setting up OpenStack configuration.
- `openstack-kolla-playbook`: Applies to tasks related to running Kolla-Ansible playbooks.

## Best Practices

- Ensure that the specified network interfaces (`eth0` and `eth1`) are correctly configured on your servers.
- Verify that the Docker registry URL is accessible from all nodes in the OpenStack cluster.
- Review and customize the Kolla-Ansible options as per your deployment requirements.
- Run the role with appropriate privileges to ensure it can create directories, install packages, and execute playbooks.

## Molecule Tests

This role does not include Molecule tests. Ensure that you manually test the role in a safe environment before deploying it in production.

## Backlinks

- [defaults/main.yml](../../roles/bootstrap_openstack/defaults/main.yml)
- [tasks/main.yml](../../roles/bootstrap_openstack/tasks/main.yml)
- [tasks/run-openstack-kolla-playbook.yml](../../roles/bootstrap_openstack/tasks/run-openstack-kolla-playbook.yml)
- [tasks/setup-openstack-venv.yml](../../roles/bootstrap_openstack/tasks/setup-openstack-venv.yml)