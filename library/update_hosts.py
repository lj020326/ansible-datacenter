#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2022, Lee Johnson (lee.james.johnson@gmail.com)
# GNU General Public License v3.0+ (see COPYING or csv://www.gnu.org/licenses/gpl-3.0.txt)


from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: update_hosts
author:
    - "Lee Johnson (@lj020326)"
short_description: Add hosts to git repo inventory. 
description:
    - Add hosts to git repo inventory.
options:
    inventory_repo_url:
        description:
            - Git repo URL.
        required: true
        type: str
    inventory_repo_branch:
        description:
            - Git branch where perform git push.
        type: str
        default: main
    inventory_repo_scheme:
        description:
            - Git operations are performend either over ssh, https or local.
              Same as C(git@git...) or C(https://user:token@git...).
        choices: [ ssh, https, local ]
        default: ssh
        type: str
    yaml_lib_mode:
        description: 
            - specifies the YAML library - 'ruamel' or 'pyyaml'.
        choices: [ ruamel, pyyaml ]
        default: ruamel
        type: str
    inventory_file:
        required: true
        type: path
        description:
            - File path where inventory YAML file will loaded, updated and written/saved.
            - The inventory file must be YAML formatted.
    state:
        description:
            - State for the update - 'merge', 'overwrite', or 'absent'.
        choices: ['merge', 'overwrite', 'absent']
        default: merge
        type: str
    backup:
        description:
          - Create a backup inventory file including the timestamp information so you can get
            the original inventory file back if you somehow clobbered it incorrectly.
        type: bool
        default: no
    remove_repo_dir:
        description:
            - Remove temporary repo inventory directory after completing.
        type: bool
        default: yes
    host_list:
        description:
            - Specifies a list of host dicts.
        aliases: ['hosts']
        required: true
        type: list
        elements: dict
    ssh_params:
        description:
            - Dictionary containing SSH parameters.
        type: dict
        suboptions:
            key_file:
                description:
                    - Specify an optional private key file path, on the target host, to use for the checkout.
                type: path
                default: None
            accept_hostkey:
                description:
                    - If C(yes), ensure that "-o StrictHostKeyChecking=no" is
                      present as an ssh option.
                type: bool
                default: 'no'
            ssh_opts:
                description:
                    - Creates a wrapper script and exports the path as GIT_SSH
                      which git then automatically uses to override ssh arguments.
                      An example value could be "-o StrictHostKeyChecking=no"
                      (although this particular option is better set via
                      C(accept_hostkey)).
                type: str
                default: None
        version_added: "1.4.0"

requirements:
    - git>=2.10.0 (the command line tool)
'''  # NOQA

EXAMPLES = r'''
- name: Add Hosts to inventory at hosts.yml
  update_hosts:
    inventory_repo_url: "ssh://git@gitea.admin.dettonville.int:2222/infra/report-inventory-facts.git"
    inventory_file: /inventory/hosts.yml
    ssh_params:
      accept_hostkey: true
      key_file: "~/.ssh/id_rsa"
      ssh_opts: '-o UserKnownHostsFile={{ remote_tmp_dir }}/known_hosts'
    backup: no
    host_list:
      - hostname: vmlnx123-q1-s1.example.int
        hostvars:
          provisioning_data:
            jira_id: DCC-12345
            infra_group: MIDWA
        groups:
        - ntp_client
        - ldap_client
      - hostname: vmlnx124-q1-s1.example.int
        hostvars:
          provisioning_data:
            jira_id: DCC-12346
            infra_group: MIDWA
        groups:
        - ntp_client
        - nfs_client
        - ldap_client

- name: Update Hosts at hosts.yml
  update_hosts:
    inventory_repo_url: "ssh://git@gitea.admin.dettonville.int:2222/infra/report-inventory-facts.git"
    inventory_file: /inventory/hosts.yml
    inventory_repo_branch: master
    ssh_params:
      accept_hostkey: true
      key_file: "~/.ssh/id_rsa"
    host_list:
      - hostname: admin-q1-internal-s1.example.int
        hostvars:
          provisioning_data:
            jira_id: DCC-12345
            infra_group: DCC
        groups:
        - ntp_server
        - nfs_server
        - ldap_server
      - hostname: web-q1-internal-s1.example.int
        hostvars:
          provisioning_data:
            jira_id: DCC-12346
            infra_group: MIDWA
        groups:
        - ntp_client
        - nfs_client
        - ldap_client
        - web_server
      - hostname: web-q2-internal-s1.example.int
        hostvars:
          provisioning_data:
            jira_id: DCC-12346
            infra_group: MIDWA
        groups:
        - ntp_client
        - nfs_client
        - ldap_client
        - web_server

- name: Overwrite Hosts at hosts.yml
  update_hosts:
    inventory_repo_url: "ssh://git@gitea.admin.dettonville.int:2222/infra/report-inventory-facts.git"
    inventory_file: /inventory/hosts.yml
    inventory_repo_branch: master
    ssh_params:
      key_file: "~/.ssh/id_rsa"
    state: overwrite
    host_list:
      - hostname: admin-q1-internal-s1.example.int
        hostvars:
          provisioning_data: {}
        groups: {}
      - hostname: web-q1-internal-s1.example.int
        hostvars:
          provisioning_data:
            jira_id: DCC-88888
            infra_group: MIDWA
        groups:
        - ntp_client
        - web_server
      - hostname: web-q2-internal-s1.example.int
        hostvars:
          provisioning_data:
            jira_id: DCC-888888
            infra_group: MIDWA
        groups:
        - ntp_client
        - nfs_client
        - ldap_client
        - web_server
        - unica_proxy

- name: Remove hosts from inventory at hosts.yml
  update_hosts:
    inventory_repo_url: "ssh://git@gitea.admin.dettonville.int:2222/infra/report-inventory-facts.git"
    inventory_file: /inventory/hosts.yml
    ssh_params:
      key_file: "~/.ssh/id_rsa"
    state: absent
    host_list:
      - hostname: admin-q1-internal-s1.example.int
      - hostname: web-q1-internal-s1.example.int
      - hostname: web-q2-internal-s1.example.int

'''  # NOQA

RETURN = r'''
message: 
    description: Status message for lookup
    type: str
    returned: always
    sample: "Inventory updated successfully"
failed: 
    description: True if failed to add hosts.
    type: bool
    returned: always
changed: 
    description: True if successful
    type: bool
    returned: always
inventory_repo_dir:
    description: The path of the inventory repo directory that was updated
    type: str
    returned: when remove_repo_dir=no
    sample: /tmp/path/to/git_inventory_repo
backup_file:
    description: The name of the backup file that was created
    type: str
    returned: when backup=yes
    sample: /path/to/inventory.yml.1942.2017-08-24@14:16:01~

'''  # NOQA

# noqa: E402 - ansible module imports must occur after docs
from ansible.module_utils.basic import AnsibleModule
from ansible.module_utils.common.text.converters import to_text

# noinspection PyUnresolvedReferences
from ansible_collections.dettonville.utils.plugins.module_utils.git_actions import Git

# noinspection PyUnresolvedReferences
from ansible_collections.dettonville.utils.plugins.module_utils.git_configuration import GitConfiguration

# noinspection PyUnresolvedReferences
from ansible_collections.dettonville.inventory.plugins.module_utils.inventory_repo_updater \
    import InventoryRepoFactory

import datetime
import shutil
import tempfile


def main():
    # seed the result dict in the object
    # we primarily care about changed and state
    # changed is if this module effectively modified the target
    # state will include any data that you want your module to pass back
    # for consumption, for example, in a subsequent task
    result = dict(
        changed=False
    )

    # define available arguments/parameters a user can pass to the module
    argument_spec = dict(
        inventory_repo_url=dict(required=True),
        inventory_repo_scheme=dict(choices=['ssh', 'https', 'local'], default='ssh'),
        inventory_repo_branch=dict(default='main'),
        inventory_file=dict(required=True, type='path'),
        host_list=dict(required=True, aliases=['hosts'], type='list', elements='dict'),
        state=dict(choices=['merge', 'overwrite', 'absent'], default='merge'),
        remove_repo_dir=dict(type='bool', default=True),
        backup=dict(type='bool', default=False),
        ssh_params=dict(default=None, type='dict', required=False),
        yaml_lib_mode=dict(choices=['ruamel', 'pyyaml'], default='ruamel')
    )

    module = AnsibleModule(
        argument_spec=argument_spec,
        supports_check_mode=True
    )

    # if the user is working with this module in only check mode we do not
    # want to make any changes to the environment, just return the current
    # state with no modifications
    if module.check_mode:
        module.exit_json(**result)

    yaml_lib_mode = module.params.get('yaml_lib_mode')

    inventory_file = module.params.get('inventory_file')
    inventory_repo_dir = tempfile.mkdtemp(prefix="update_hosts")
    inventory_file_path = inventory_repo_dir + '/' + inventory_file

    remove_repo_dir = module.params.get('remove_repo_dir')

    git_commit_message = "dettonville.inventory.update_hosts(): updated inventory " + \
                         "{0} as of {1}".format(inventory_file, datetime.datetime.now())

    module.debug("inventory_file_path={0}".format(inventory_file_path))

    repo_config = {
        'repo_dir': inventory_repo_dir,
        'repo_url': module.params.get('inventory_repo_url'),
        'repo_mode': module.params.get('inventory_repo_scheme'),
        'repo_branch': module.params.get('inventory_repo_branch'),
        'remote': 'origin',
        'ssh_params': module.params.get('ssh_params') or None
    }

    git_user_config = {
        'name': "ansible",
        'email': "ansible@alsac.stjude.org"
    }

    git = Git(module, repo_config)

    result.update(git.clone())
    result.update(git.set_user_config(git_user_config))

    # ref: https://medium.com/design-patterns-in-python/factory-pattern-in-python-2f7e1ca45d3e
    inventory_repo = InventoryRepoFactory().get_repo_updater(yaml_lib_mode, module, inventory_file_path)

    host_list = module.params.get('host_list')
    state = module.params.get('state')
    backup = module.params.get('backup')
    update_hosts_result = inventory_repo.update_hosts(host_list, state, backup)

    changed_files = git.status()
    module.debug("changed_files={0}".format(changed_files))

    if changed_files:
        result.update(git.add())
        result.update(git.commit(git_commit_message))
        result.update(git.push())
        result['message'] = "Inventory updated successfully"
        result['changed'] = True
    else:
        result['message'] = "No changes required for {0}".format(inventory_file)
        result['changed'] = False

    if remove_repo_dir:
        try:
            shutil.rmtree(inventory_repo_dir)
        except OSError as e:
            module.fail_json(msg="Failed to remove temp inventory repo dir at %s" % inventory_repo_dir,
                             details=u"Error occurred while removing : %s" % to_text(e))
    else:
        result['inventory_repo_dir'] = inventory_repo_dir

    if backup:
        result['backup_file'] = update_hosts_result['backup_file']

    # module.debug('result: %s' % result)
    module.exit_json(**result)


if __name__ == "__main__":
    main()
