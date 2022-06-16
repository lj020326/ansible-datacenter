
* ref: https://docs.ansible.com/ansible/latest/dev_guide/developing_modules_general.html
* ref: https://docs.ansible.com/ansible/latest/dev_guide/developing_locally.html
* ref: https://www.techbeatly.com/how-to-add-custom-modules-in-ansible/
* ref: https://stackoverflow.com/questions/53750049/location-to-keep-ansible-custom-modules

```shell
$ ansible-config dump |grep DEFAULT_MODULE_PATH
DEFAULT_MODULE_PATH(/Users/ljohnson/repos/ansible/ansible-datacenter/ansible.cfg) = ['/Users/ljohnson/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules', '/Users/ljohnson/repos/ansible/ansible-datacenter/library']

$ 
```

Local test custom module using python:
```shell
python -m library.export_dicts tests/modules/export_dicts.test1.args.json

{"changed": true, "original_message": "hello", "message": "goodbye", "invocation": {"module_args": {"name": "hello", "new": true}}}

```

Test using ansible-playbook:

Playbook:
```yaml
---

- name: "TEST export_dicts | Export test dicts"
  hosts: localhost
  vars:
    output_file: "/tmp/file1.csv"
  tasks:

    - name: "TEST export_dicts | Export test_list dicts to {{ output_file }}"
      export_dicts:
        file: "/tmp/file1.csv"
        format: "csv"
        export_list:
          - { key1: "value11", key2: "value12", key3: "value13", key4: "value14" }
          - { key1: "value21", key2: "value22", key3: "value23", key4: "value24" }
          - { key1: "value31", key2: "value32", key3: "value33", key4: "value34" }
          - { key1: "value41", key2: "value42", key3: "value43", key4: "value44" }
      register: export_result

    - name: dump export_result
      debug:
        var: export_result

```


```shell
ansible-playbook ./tests/test-export-dicts.yml

PLAY [TEST export_dicts | Export test dicts] *****************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ***************************************************************************************************************************************************************************************************************************************************
ok: [localhost]

TASK [TEST export_dicts | Export test_list dicts to /tmp/file1.csv] ******************************************************************************************************************************************************************************************************
changed: [localhost]

TASK [dump export_result] ************************************************************************************************************************************************************************************************************************************************
ok: [localhost] => 
  export_result:
    changed: true
    failed: false
    message: The csv file has been created successfully at /tmp/file1.csv

PLAY RECAP ***************************************************************************************************************************************************************************************************************************************************************
localhost                  : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   


```


```shell
$ ansible-doc -t module export_dicts

> EXPORT_DICTS    (/Users/ljohnson/repos/ansible/ansible-datacenter/library/export_dicts.py)


        Write a list of flat dictionaries to a flat file using a specified format choice (csv or markdown) from a list of provided column names, headers and column list order.

OPTIONS (= is mandatory):

- column_list
        List containing a list of column dictionary specifications for each column in the file. Each column element should contain a dict specifying values for the 'name' and 'header' keys. If the 'column_list'
        is not specified, it will be derived from the keys of the first row in the export_list.
        (Aliases: columns)[Default: []]
        elements: dict
        type: list

= export_list
        Specifies a list of dicts to write to flat file.
        (Aliases: list)
        elements: dict
        type: list

= file
        File path where file will be written/saved.

        type: path

- format
        `csv' write to csv formatted file. `md'  write to markdown formatted file.
        (Choices: csv, md)[Default: csv]
        type: str


AUTHOR: Lee Johnson (@lj020326)

EXAMPLES:

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



        Write a list of flat dictionaries to a flat file using a specified format choice (csv or markdown) from a list of provided column names, headers and column list order.

OPTIONS (= is mandatory):

- column_list
        List containing a list of column dictionary specifications for each column in the file. Each column element should contain a dict specifying values for the 'name' and 'header' keys. If the 'column_list'
        is not specified, it will be derived from the keys of the first row in the export_list.
        (Aliases: columns)[Default: []]
        elements: dict
        type: list

= export_list
        Specifies a list of dicts to write to flat file.
        (Aliases: list)
        elements: dict
        type: list

= file
        File path where file will be written/saved.

        type: path

- format
        `csv' write to csv formatted file. `md'  write to markdown formatted file.
        (Choices: csv, md)[Default: csv]
        type: str


AUTHOR: Lee Johnson (@lj020326)

EXAMPLES:

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


RETURN VALUES:
- changed
        True if successful

        returned: always
        type: bool

- failed
        True if cyberark accounts lookup failed to find results

        returned: always
        type: bool

- message
        Status message for lookup

        returned: always
        sample: The markdown file has been created successfully at /foo/bar/test.md
        type: str

```
