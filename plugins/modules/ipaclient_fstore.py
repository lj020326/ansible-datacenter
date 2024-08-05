## source: https://github.com/freeipa/ansible-freeipa

from __future__ import (absolute_import, division, print_function)

__metaclass__ = type

ANSIBLE_METADATA = {
    'metadata_version': '1.0',
    'supported_by': 'community',
    'status': ['preview'],
}

DOCUMENTATION = '''
---
module: ipaclient_fstore
short_description: Backup files using IPA client sysrestore
description: Backup files using IPA client sysrestore
options:
  backup:
    description: File to backup
    type: str
    required: yes
author:
    - Thomas Woerner (@t-woerner)
'''

EXAMPLES = '''
- name: Backup /etc/krb5.conf
  ipaclient_fstore:
    backup: "/etc/krb5.conf"
'''

RETURN = '''
'''

from ansible.module_utils.basic import AnsibleModule
from ansible.module_utils.ansible_ipa_client import (
    setup_logging, check_imports, paths, sysrestore
)


def main():
    module = AnsibleModule(
        argument_spec=dict(
            backup=dict(required=True, type='str'),
        ),
    )

    module._ansible_debug = True
    check_imports(module)
    setup_logging()

    backup = module.params.get('backup')

    fstore = sysrestore.FileStore(paths.IPA_CLIENT_SYSRESTORE)
    if not fstore.has_file(backup):
        fstore.backup_file(backup)
        module.exit_json(changed=True)

    module.exit_json(changed=False)


if __name__ == '__main__':
    main()
