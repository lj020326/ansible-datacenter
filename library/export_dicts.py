#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2022, Lee Johnson (lee.james.johnson@gmail.com)
# GNU General Public License v3.0+ (see COPYING or csv://www.gnu.org/licenses/gpl-3.0.txt)


from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: export_dicts
author:
    - "Lee Johnson (@lj020326)"
short_description: Write a list of flat dictionaries to a file with either csv or markdown format.
description:
    - Write a list of flat dictionaries (a dictionary mapping fieldnames to strings or numbers) to a flat file using a
      specified format choice (csv or markdown) from a list of provided column names, headers and column list order.
options:
    file:
        required: true
        type: path
        description:
            - File path where file will be written/saved.
    format:
        description:
          - C(csv) write to csv formatted file.
            C(md)  write to markdown formatted file.
        required: false
        type: str
        choices: [ csv, md ]
        default: "csv"
    export_list:
        aliases: ['list']
        required: true
        type: list
        elements: dict
        description:
            - Specifies a list of dicts to write to flat file.
    column_list:
        aliases: ['columns']
        description:
            - List containing a list of column dictionary specifications for each column in the file.  
              Each column element should contain a dict specifying values for the 'name' and 'header' keys.
              If the 'column_list' is not specified, it will be derived from the keys of the first row in the
              export_list.
        required: false
        default: []
        type: list
        elements: dict

'''  # NOQA

EXAMPLES = r'''
- name: csv | Write file1.csv
  export_dicts:
    file: /tmp/test-exports/file1.csv
    format: csv
    export_list: 
      - { key1: "value11", key2: "value12", key3: "value13", key4: "value14" }
      - { key1: "value21", key2: "value22", key3: "value23", key4: "value24" }
      - { key1: "value31", key2: "value32", key3: "value33", key4: "value34" }
      - { key1: "value41", key2: "value42", key3: "value43", key4: "value44" }

- name: md | Write markdown export_dicts.md
  export_dicts:
    file: /tmp/test-exports/export_dicts.md
    format: md
    export_list: 
      - { key1: "value11", key2: "value12", key3: "value13", key4: "value14" }
      - { key1: "value21", key2: "value22", key3: "value23", key4: "value24" }
      - { key1: "value31", key2: "value32", key3: "value33", key4: "value34" }
      - { key1: "value41", key2: "value42", key3: "value43", key4: "value44" }

- name: csv with headers | Write file1.csv
  export_dicts:
    file: /tmp/test-exports/file1.csv
    format: csv
    columns: 
      - { "name": "key1", "header": "Key #1" }
      - { "name": "key2", "header": "Key #2" }
      - { "name": "key3", "header": "Key #3" }
      - { "name": "key4", "header": "Key #4" }
    export_list: 
      - { key1: "value11", key2: "value12", key3: "value13", key4: "value14" }
      - { key1: "value21", key2: "value22", key3: "value23", key4: "value24" }
      - { key1: "value31", key2: "value32", key3: "value33", key4: "value34" }
      - { key1: "value41", key2: "value42", key3: "value43", key4: "value44" }

- name: md with headers | Write markdown export_dicts.md
  export_dicts:
    file: /tmp/test-exports/export_dicts.md
    format: md
    columns: 
      - { "name": "key1", "header": "Key #1" }
      - { "name": "key2", "header": "Key #2" }
      - { "name": "key3", "header": "Key #3" }
      - { "name": "key4", "header": "Key #4" }
    export_list: 
      - { key1: "båz", key2: "value12", key3: "value13", key4: "value14" }
      - { key1: "value21", key2: "ﬀöø", key3: "value23", key4: "value24" }
      - { key1: "value31", key2: "value32", key3: "ḃâŗ", key4: "value34" }
      - { key1: "value41", key2: "value42", key3: "ﬀöø", key4: "båz" }

'''  # NOQA

RETURN = r'''
message: 
    description: Status message for export
    type: str
    returned: always
    sample: "The markdown file has been created successfully at /foo/bar/test.md"
failed: 
    description: True if export failed
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


# ref: https://docs.python.org/3/library/csv.html
# ref: https://realpython.com/python-csv/
# ref: https://www.geeksforgeeks.org/writing-csv-files-in-python/
def write_csv(module, output_file, export_list, column_list):
    (headers, fieldnames) = get_headers_and_fields(column_list)

    try:
        with open(output_file, mode='w') as csv_file:
            writer = csv.DictWriter(csv_file, lineterminator='\n', fieldnames=fieldnames, extrasaction='ignore')

            header_row_dict = dict(zip(fieldnames, headers))

            # print('header_row_dict: %s' % header_row_dict)

            writer.writerow(header_row_dict)
            writer.writerows(export_list)

            # for row in list_of_rows:
            #     row_output = [row[column.name] for column in column_list]
            #     writer.writerow(row_output)

    except IOError:
        module.fail_json(msg="Unable to create file %s", traceback=traceback.format_exc())

    result = dict(
        changed=True,
        message="The csv file has been created successfully at {0}".format(output_file)
    )

    return result


# ref: https://cppsecrets.com/users/1102811497104117108109111104116975048484864103109971051084699111109/Convert-a-CSV-file-to-a-table-in-a-markdown-file.php # noqa: E501 url size exceeds 120
def write_markdown(module, output_file, export_list, column_list):
    # print('column_list: %s' % column_list)
    (headers, fieldnames) = get_headers_and_fields(column_list)

    md_string = " | "
    for header in headers:
        md_string += header + " | "

    md_string += "\n |"
    for i in range(len(headers)):
        md_string += "--- | "

    md_string += "\n"
    for row in export_list:
        module.log('row = %s' % str(row))
        md_string += " | "
        for column in column_list:
            column_value = None
            if column['name'] in row:
                column_value = row[column['name']]
            module.log('column_value = %s' % str(column_value))
            md_string += str(column_value) + " | "
        md_string += "\n"

    try:
        # writing md_string to the output_file
        # file = open(output_file, "w", encoding="UTF-8")
        file = codecs.open(output_file, "w", encoding="UTF-8")
        file.write(md_string)
        file.close()

    except IOError:
        module.fail_json(msg="Unable to create file %s", traceback=traceback.format_exc())

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
        format=dict(choices=['md', 'csv'], default='csv'),
        export_list=dict(required=True, aliases=['list'], type='list', elements='dict'),
        column_list=dict(aliases=['columns'], type='list', elements='dict'),
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
    export_list = module.params.get('export_list')
    column_list = module.params['column_list'] or None

    if not column_list:
        column_list = []
        # Derive column_list for the csv file based on first row of export_list.
        column_keys = list(export_list[0].keys())
        for column_name in column_keys:
            column_list.append({
                "name": column_name,
                "header": column_name
            })

    for column in column_list:
        column_name = column['name']
        if not column_name:
            module.fail_json(msg='Column name not found', **result)

    if file_format == "md":
        export_result = write_markdown(module, file, export_list, column_list)
    elif file_format == "csv":
        export_result = write_csv(module, file, export_list, column_list)

    # print('export_result: %s' % export_result)

    result['changed'] = export_result['changed']
    result['message'] = export_result['message']

    # print('result: %s' % result)
    module.exit_json(**result)


if __name__ == "__main__":
    main()
