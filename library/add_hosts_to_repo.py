#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2022, Lee Johnson (lee.james.johnson@gmail.com)
# GNU General Public License v3.0+ (see COPYING or csv://www.gnu.org/licenses/gpl-3.0.txt)


from __future__ import absolute_import, division, print_function

__metaclass__ = type

DOCUMENTATION = r'''
---
module: add_hosts_to_repo
author:
    - "Lee Johnson (@lj020326)"
short_description: Add host to git repo inventory. 
description:
    - Add host to git repo inventory.
options:
    inventory_file:
        required: true
        type: path
        description:
            - File path where inventory YAML file will loaded, updated and written/saved.
            - The inventory file must be YAML formatted.
    backup:
        description:
          - Create a backup inventory file including the timestamp information so you can get
            the original inventory file back if you somehow clobbered it incorrectly.
        type: bool
        default: no
    add_host_list:
        aliases: ['list']
        required: true
        type: list
        elements: dict
        description:
            - Specifies a list of host dicts.
    inventory_repo_url:
        description:
            - Git repo URL.
        required: True
        type: str
    inventory_repo_branch:
        description:
            - Git branch where perform git push.
        type: str
        default: main
    inventory_repo_scheme:
        description:
            - Git operations are performend eithr over ssh, https or local.
              Same as C(git@git...) or C(https://user:token@git...).
        choices: ['ssh', 'https', 'local']
        default: ssh
        type: str
    ssh_params:
        description:
            - Dictionary containing SSH parameters.
        type: dict
        suboptions:
            key_file:
                description:
                    - Specify an optional private key file path, on the target host, to use for the checkout.
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
- name: csv | Write hosts.yml
  add_hosts_to_repo:
    inventory_repo_scheme: ssh
    inventory_repo_url: "git@gitlab.com:networkAutomation/git_test_module.git"
    inventory_file: /tmp/test-add-hosts/hosts.yml
    inventory_repo_branch: master
    ssh_params:
      accept_hostkey: true
      key_file: '{{ lookup('env', 'HOME') }}/.ssh/id_rsa'
      ssh_opts: '-o UserKnownHostsFile={{ remote_tmp_dir }}/known_hosts'
    backup: no
    add_host_list:
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


'''  # NOQA

RETURN = r'''
message: 
    description: Status message for lookup
    type: str
    returned: always
    sample: "[master 99830f4] Add [ inventory/site.yml ]\n 1 files changed, 26 insertions(+)..."
failed: 
    description: True if failed to add hosts.
    type: bool
    returned: always
changed: 
    description: True if successful
    type: bool
    returned: always
inventory_file:
    description: The path of the inventory file that was updated
    type: str
    returned: when backup=yes
    sample: /path/to/inventory.yml
backup_file:
    description: The name of the backup file that was created
    type: str
    returned: when backup=yes
    sample: /path/to/inventory.yml.1942.2017-08-24@14:16:01~

'''  # NOQA

# noqa: E402 - ansible module imports must occur after docs
from ansible.module_utils.basic import AnsibleModule

try:
    from module_utils.git_actions import Git
except ImportError:
    from ansible.module_utils.git_actions import Git

try:
    from module_utils.inventory_repo_actions import InventoryRepo
except ImportError:
    from ansible.module_utils.inventory_repo_actions import InventoryRepo


import datetime
import tempfile


def main():
    # seed the result dict in the object
    # we primarily care about changed and state
    # changed is if this module effectively modified the target
    # state will include any data that you want your module to pass back
    # for consumption, for example, in a subsequent task
    result = dict(
        changed=False,
        message=''
    )

    # define available arguments/parameters a user can pass to the module
    argument_spec = dict(
        inventory_repo_url=dict(required=True),
        inventory_repo_scheme=dict(choices=['ssh', 'https', 'local'], default='ssh'),
        inventory_repo_branch=dict(default='main'),
        inventory_file=dict(required=True, type='path'),
        add_host_list=dict(required=True, aliases=['list'], type='list', elements='dict'),
        backup=dict(type='bool', default=False),
        ssh_params=dict(default=None, type='dict', required=False)
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

    inventory_file = module.params.get('inventory_file')
    inventory_repo_dir = tempfile.mkdtemp(prefix="add_hosts_to_repo")
    inventory_file_path = inventory_repo_dir + '/' + inventory_file

    git_commit_message = "ansible add_host_to_inventory: updated inventory in {0} as of {1}".format(inventory_file, datetime.datetime.now())

    print("inventory_file_path={0}".format(inventory_file_path))

    git = Git(module, inventory_repo_dir)

    git.clone()

    inventory_repo = InventoryRepo(module, inventory_file_path)

    add_host_list = module.params.get('add_host_list')
    backup = module.params['backup']
    add_hosts_result = inventory_repo.add_hosts_yaml(add_host_list, backup)

    changed_files = git.status()
    print("changed_files={0}".format(changed_files))

    if changed_files:
        git.add()
        result.update(git.commit(git_commit_message))
        result.update(git.push())
        result['changed'] = True
    else:
        result['message'] = "No changes required for {0}".format(inventory_file)
        result['changed'] = False

    result['inventory_repo_dir'] = inventory_repo_dir

    # print('add_hosts_result: {0}'.format(add_hosts_result))

    if backup:
        result['backup_file'] = add_hosts_result['backup_file']

    # print('result: %s' % result)
    module.exit_json(**result)


if __name__ == "__main__":
    main()
