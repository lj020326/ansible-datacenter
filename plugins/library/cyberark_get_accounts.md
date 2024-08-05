
```shell
$ ansible-config dump |grep DEFAULT_MODULE_PATH
DEFAULT_MODULE_PATH(/Users/foobar/repos/ansible/ansible-datacenter/ansible.cfg) = ['/Users/foobar/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules', '/Users/foobar/repos/ansible/ansible-datacenter/library']

$ 
```


```shell
$ ansible-doc -t module cyberark_get_accounts

> CYBERARK_GET_ACCOUNTS    (/Users/foobar/repos/ansible/ansible-datacenter/library/cyberark_get_accounts.py)

        This module will get account information from cyberark. Need
        to pass the 'search filter string' to be used in cyberark
        search/filter API (e.g., 'Weblogic DEV console', 'Weblogic QA
        console', etc), safe name, cyberark api username and password.

ADDED IN: version 2.9.16

OPTIONS (= is mandatory):

= api_base_url
        cyberark base url

        type: str

= cyberark_auth_password
        cyberark API password

        type: str

= cyberark_auth_username
        cyberark API username

        type: str

= filter_search_string
        service account filter search string to be used in cyberark
        search/filter API (e.g., 'Weblogic DEV console', 'Weblogic QA
        console', etc)

        type: str

- log_level
        `DEBUG'   Debug logging. `INFO'    INFO logging. `NOTSET'  NOT
        logging.
        (Choices: csv, md)[Default: csv]

= safe_name
        account safe name

        type: str


EXAMPLES:

- name: get account information from cyberark
  cyberark_get_accounts:
    api_base_url: string
    filter_search_string: string
    safe_name: string
    cyberark_auth_username: string
    cyberark_auth_password: string
  register: result


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
        sample: accounts retrieved successfully
        type: str

- meta
        Dict containing results from cyberark lookup

        returned: always
        sample:
          filter_search_string: serviceaccounttest
          results:
            count: 1
            value:
            - address: example.int
              categoryModificationTime: 1627658595
              createdTime: 1627656701
              id: '155_55'
              name: Operating System-AD-un-Managed-example.int-serviceaccounttest
              password: passwordhere
              platformAccountProperties: {}
              platformId: AD-un-Managed
              safeName: A-T-Ansible
              secretManagement:
                automaticManagementEnabled: false
                lastModifiedTime: 1627658595
                manualManagementReason: No Reason
              secretType: password
              userName: serviceaccounttest
        
        type: str
```
