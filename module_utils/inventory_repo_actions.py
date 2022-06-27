from __future__ import absolute_import, division, print_function
__metaclass__ = type

import os
import stat
import re
import shutil
import tempfile
import traceback

from ruamel.yaml import YAML
from pathlib import Path

try:
    from module_utils.messages import FailingMessage
except ImportError:
    from ansible.module_utils.messages import FailingMessage

try:
    from module_utils.six import b
except ImportError:
    from ansible.module_utils.six import b

try:
    from module_utils._text import to_native, to_text
except ImportError:
    from ansible.module_utils._text import to_native, to_text


# # ref: https://stackoverflow.com/questions/44313992/how-to-keep-null-value-in-yaml-file-while-dumping-though-ruamel-yaml # noqa: E501 url size exceeds 120
# def my_represent_none(self, data):
#     return self.represent_scalar(u'tag:yaml.org,2002:null', u'null')

class InventoryRepo:

    def __init__(self, module, inventory_file_path):
        self.module = module
        self.inventory_file_path = inventory_file_path

        destination_path = os.path.dirname(self.inventory_file_path)
        if not os.path.exists(destination_path):
            self.module.fail_json(rc=257, msg='Destination directory %s does not exist!' % destination_path)


    # # ref: https://stackoverflow.com/questions/44313992/how-to-keep-null-value-in-yaml-file-while-dumping-though-ruamel-yaml # noqa: E501 url size exceeds 120
    # def my_represent_none(self, data):
    #     return self.represent_scalar(u'tag:yaml.org,2002:null', u'null')

    def add_hosts_yaml(self, add_host_list, backup=False):
        backup_file = None
        if not self.module.check_mode:

            # ref: https://yaml.readthedocs.io/en/latest/api.html#loading
            # ref: https://github.com/yaml/pyyaml/issues/199
            yaml = YAML()
            yaml.preserve_quotes = True

            filepath = Path(self.inventory_file_path)
            data = yaml.load(filepath)

            # yaml.dump(data, sys.stdout)

            inventory = data['all']
            inventory_hosts = inventory['hosts']
            inventory_groups = inventory['children']

            for host in add_host_list:
                print(host['hostname'], '->', host['hostvars'])
                inventory_hosts[host['hostname']] = host['hostvars']

                if 'groups' in host.keys():
                    host_groups = host['groups']
                    for group in host_groups:
                        if group not in inventory_groups:
                            inventory_groups[group] = {}

                        if 'hosts' not in inventory_groups[group]:
                            inventory_groups[group]['hosts'] = {}

                        inventory_groups[group]['hosts'][host['hostname']] = {}

            # ref: https://yaml.readthedocs.io/en/latest/example.html
            # ref: https://yaml.readthedocs.io/en/latest/detail.html
            mapping = 2
            sequence = 2
            offset = 0
            yaml.indent(mapping=mapping, sequence=sequence, offset=offset)

            # ref: https://stackoverflow.com/questions/44313992/how-to-keep-null-value-in-yaml-file-while-dumping-though-ruamel-yaml # noqa: E501 url size exceeds 120
            def my_represent_none(self, data):
                return self.represent_scalar(u'tag:yaml.org,2002:null', u'null')

            # ref: https://stackoverflow.com/questions/44313992/how-to-keep-null-value-in-yaml-file-while-dumping-though-ruamel-yaml # noqa: E501 url size exceeds 120
            yaml.representer.add_representer(type(None), my_represent_none)
            # yaml.representer.add_representer(self.my_represent_none)

            if backup:
                backup_file = self.module.backup_local(self.inventory_file_path)
                print("backup_file={0}".format(backup_file))

            dummy, tmpfile = tempfile.mkstemp()
            print("tmpfile={0}".format(tmpfile))

            try:
                os.remove(tmpfile)
                with open(tmpfile, 'w') as fd:
                    yaml.dump(data, fd)
            except IOError:
                self.module.fail_json(msg="Unable to create temporary file %s", traceback=traceback.format_exc())

            try:
                self.module.atomic_move(tmpfile, self.inventory_file_path)
            except IOError:
                self.module.ansible.fail_json(msg='Unable to move temporary \
                                       file %s to %s, IOError' % (tmpfile, self.inventory_file_path), traceback=traceback.format_exc())
            finally:
                if os.path.exists(tmpfile):
                    os.remove(tmpfile)

        result = dict(
            changed=True,
            backup_file=backup_file,
            message="The inventory file has been updated successfully at {0}".format(self.inventory_file_path)
        )

        return result

