Getting started
===============

.. contents::
   :local:

The ``dettonville.iscsi`` role depends heavily on the LVM support. It can be
configured using ``dettonville.lvm`` role added to the playbook before the
``dettonville.iscsi`` role.

Before using ``dettonville.iscsi`` role, you should configure an iSCSI Target. It
can be configured either on a dedicated SAN storage host, or using Linux
packages like ``targetcli``, ``tgt`` and others. You can use ``dettonville.tgt``
role to create a simple iSCSI Target server, however using ``targetcli`` to
setup a LIO-based iSCSI Target might be easier.

The ``dettonville.unattended_upgrades`` role can be used with a provided list of
blocklisted packages to prevent the unattended upgrade of the ``open-iscsi``
package, which might result in connection loss to the iSCSI Target and broken
services.

Example inventory
-----------------

To configure iSCSI Initiator to connect to remote storage, you should add
a given host to ``[dettonville_service_iscsi]`` Ansible group::

    [dettonville_service_iscsi]
    hostname

Inventory variables
-------------------

Before configuring the role, you should specify the IQN date and Naming
Authority (by default, ``ansible_domain``) to have consistent IQN naming
scheme. It's best to use the registration date of your domain, you can check it
using ``whois`` command::

    bootstrap_iscsi_client__iqn_date: '1995-08'
    bootstrap_iscsi_client__iqn_authority: '{{ ansible_domain }}'

Above variables will be used to create and store IQN base name, available as
``{{ bootstrap_iscsi_client__iqn }}``. You can use it in your IQN strings, provided that the
same scheme is used on your iSCSI Target hosts.

iSCSI storage should be configured on a separate internal network or VLAN to
provide security. By default, ``dettonville.iscsi`` discovers iSCSI Targets on all
configured interfaces. To change that, you can specify interface names to use::

    bootstrap_iscsi_client__interfaces: [ 'eth1', 'vlan300' ]

You need to specify FQDN hostnames or IP addresses of hosts that provide the
storage to discover iSCSI Targets::

    bootstrap_iscsi_client__portals: [ 'storage.iscsi.{{ ansible_domain }}' ]

You will also want to configure :ref:`bootstrap_iscsi_client__targets` and
:ref:`bootstrap_iscsi_client__logical_volumes` to specify what iSCSI Targets to connect to, as
well as how to manage the storage volumes.

Default usernames and passwords for discovery and session authentication can be
found in ``secret/`` directory (see ``dettonville.secret`` role for more details).
You can change them by modifying the created files and re-running the role.

Example playbook
----------------

Here's an example playbook which uses ``dettonville.iscsi`` role::

    ---

    - name: Configure iSCSI Initiator
      hosts: [ 'dettonville_service_iscsi' ]
      become: True

      roles:

        - role: dettonville.unattended_upgrades
          tags: [ 'role::unattended_upgrades' ]
          unattended_upgrades__dependent_blocklist: '{{ bootstrap_iscsi_client__unattended_upgrades__dependent_blocklist }}'

        - role: dettonville.lvm
          tags: [ 'role::lvm' ]

        - role: dettonville.iscsi
          tags: [ 'role::iscsi' ]

