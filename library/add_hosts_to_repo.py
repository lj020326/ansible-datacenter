#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2022, Lee Johnson (lee.james.johnson@gmail.com)
# GNU General Public License v3.0+ (see COPYING or csv://www.gnu.org/licenses/gpl-3.0.txt)


from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: add_host_to_repo
author:
    - "Lee Johnson (@lj020326)"
short_description: Add host to git repo inventory. 
description:
    - Add host to git repo inventory.
options:
    file:
        required: true
        type: path
        description:
            - File path where file will be written/saved.
    format:
        description:
          - C(yml) write to YAML formatted file.
            C(ini)  write to INI formatted file.
        required: false
        type: str
        choices: [ yml, ini ]
        default: "csv"
    host_list:
        aliases: ['list']
        required: true
        type: list
        elements: dict
        description:
            - Specifies a list of host dicts.

'''  # NOQA

EXAMPLES = r'''
- name: csv | Write hosts.yml
  add_host_to_repo:
    file: /tmp/test-exports/hosts.yml
    format: yml
    host_list: 
      - { key1: "value11", key2: "value12", key3: "value13", key4: "value14" }
      - { key1: "value21", key2: "value22", key3: "value23", key4: "value24" }
      - { key1: "value31", key2: "value32", key3: "value33", key4: "value34" }
      - { key1: "value41", key2: "value42", key3: "value43", key4: "value44" }

'''  # NOQA

RETURN = r'''
message: 
    description: Status message for lookup
    type: str
    returned: always
    sample: "The markdown file has been created successfully at /foo/bar/test.md"
failed: 
    description: True if cyberark accounts lookup failed to find results
    type: bool
    returned: always
changed: 
    description: True if successful
    type: bool
    returned: always

'''  # NOQA

# noqa: E402 - ansible module imports must occur after docs
from ansible.module_utils.basic import AnsibleModule

import csv
import os
import traceback
import codecs


def get_headers_and_fields(column_list):
    fieldnames = [column["name"] for column in column_list]
    headers = [column["header"] for column in column_list]

    # just in case the headers were not specified
    if not headers:
        headers = fieldnames

    return headers, fieldnames


def write_yml(module, output_file, host_list):


    result = dict(
        changed=True,
        message="The csv file has been created successfully at {0}".format(output_file)
    )

    return result


def write_ini(module, output_file, host_list):


    result = dict(
        changed=True,
        message="The markdown file has been created successfully at {0}".format(output_file)
    )

    return result


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

    export_result = None

    # define available arguments/parameters a user can pass to the module
    argument_spec = dict(
        file=dict(required=True, type='path'),
        format=dict(choices=['yml', 'ini'], default='yml'),
        host_list=dict(required=True, aliases=['list'], type='list', elements='dict')
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

    file = module.params.get('file')

    destination_path = os.path.dirname(file)
    if not os.path.exists(destination_path):
        module.fail_json(rc=257, msg='Destination directory %s does not exist!' % destination_path)

    file_format = module.params.get('format')
    host_list = module.params.get('host_list')

    if file_format == "ini":
        export_result = write_ini(module, file, host_list)
    elif file_format == "yml":
        export_result = write_yml(module, file, host_list)

    # print('export_result: %s' % export_result)

    result['changed'] = export_result['changed']
    result['message'] = export_result['message']

    # print('result: %s' % result)
    module.exit_json(**result)


if __name__ == "__main__":
    main()
