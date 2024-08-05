#!/usr/bin/env python3

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: cyberark_get_accounts

short_description: search for account information based on search filter string to be used in cyberark search/filter API (e.g., 'Weblogic DEV console', 'Weblogic QA console', etc) and return the account details including passwords.

# If this is part of a collection, you need to use semantic versioning,
# i.e. the version is of the from "2.5.0" and not "2.4".

version_added: "2.9.16"

description: This module will get account information from cyberark. Need to pass the 'search filter string' to be used in cyberark search/filter API (e.g., 'Weblogic DEV console', 'Weblogic QA console', etc), safe name, cyberark api username and password.

options:
    api_base_url:
        description: cyberark base url
        required: true
        type: str
    filter_search_string:
        description: service account filter search string to be used in cyberark search/filter API (e.g., 'Weblogic DEV console', 'Weblogic QA console', etc)
        required: true
        type: str
    safe_name:
        description: account safe name
        required: true
        type: str
    cyberark_auth_username:
        description: cyberark API username
        required: true
        type: str
    cyberark_auth_password:
        description: cyberark API password
        required: true
        type: str
    log_level:
        description:
          - C(DEBUG)   Debug logging.
            C(INFO)    INFO logging.
            C(NOTSET)  NOT logging.
        required: false
        choices: [ csv, md ]
        default: "csv"

'''

EXAMPLES = r'''
- name: get account information from cyberark
  cyberark_get_accounts:
    api_base_url: string
    filter_search_string: string
    safe_name: string
    cyberark_auth_username: string
    cyberark_auth_password: string
  register: result
'''

RETURN = r'''
message: 
    description: Status message for lookup
    type: str
    returned: always
    sample: "accounts retrieved successfully"
failed: 
    description: True if cyberark accounts lookup failed to find results
    type: bool
    returned: always
changed: 
    description: True if successful
    type: bool
    returned: always
meta:
    description: Dict containing results from cyberark lookup
    type: str
    returned: always
    sample: 
      filter_search_string: serviceaccounttest
      results:
        count: 1
        value:
        - platformAccountProperties: {}
          userName: serviceaccounttest
          name: Operating System-AD-un-Managed-example.int-serviceaccounttest
          platformId: AD-un-Managed
          categoryModificationTime: 1627658595
          secretManagement:
            lastModifiedTime: 1627658595
            automaticManagementEnabled: false
            manualManagementReason: No Reason
          safeName: A-T-Ansible
          secretType: password
          address: example.int
          createdTime: 1627656701
          password: passwordhere
          id: '155_55'

'''

from ansible.module_utils.basic import AnsibleModule
import requests
import json
import logging

requests.packages.urllib3.disable_warnings()


def construct_url(api_base_url, end_point):
    return "{baseurl}/{endpoint}".format(baseurl=api_base_url.rstrip("/"), endpoint=end_point.lstrip("/"))


def cyberark_get_accounts_module_func(input_json_data):
    # Get module parameters
    api_base_url = input_json_data['api_base_url']
    filter_search_string = input_json_data['filter_search_string']
    safe_name = input_json_data['safe_name']
    cyberark_username = input_json_data['cyberark_auth_username']
    cyberark_password = input_json_data['cyberark_auth_password']

    # cyberark api call to get api token
    auth_payload = {"username": cyberark_username, "password": cyberark_password}
    end_point = "/PasswordVault/API/auth/LDAP/Logon"
    login_url = construct_url(api_base_url, end_point)
    response_token_data = requests.post(login_url,
                                        data=json.dumps(auth_payload),
                                        headers={'content-type': 'application/json'},
                                        verify=False)

    if response_token_data.status_code == 200:
        response_token = response_token_data.json()
    elif response_token_data.status_code == 403:  # if not 200 response return bad username and password
        return {"result": "failed", "reason": "bad username and password"}
    else:
        return {"result": "failed", "reason": "cyberark server not reachable or given url wrong"}

    end_point = "/PasswordVault/api/accounts?search={}&filter=safeName eq {}".format(filter_search_string, safe_name)
    account_query_url = construct_url(api_base_url, end_point)

    response = requests.get(account_query_url,
                            headers={'content-type': 'application/json', 'Authorization': response_token}, verify=False)
    accounts_results = response.json()
    logging.debug("Response for {%s}: {%s}", account_query_url, accounts_results)

    if accounts_results['value']:
        for index, account in enumerate(accounts_results['value']):
            account_id = account['id']

            # Cyberark password to retrieve password using account_id
            end_point = "/PasswordVault/api/Accounts/{}/Password/Retrieve".format(account_id)
            get_pass_url = construct_url(api_base_url, end_point)

            password_response = requests.post(get_pass_url,
                                              headers={'content-type': 'application/json',
                                                     'Authorization': response_token},
                                              verify=False).json()
            account['password'] = password_response
            accounts_results['value'][index] = account

    else:
        meta = {"result": "failed",
                "reason": "safe '{}' or results for filter_search_string '{}' are not found".format(safe_name,
                                                                                                    filter_search_string)}
        return meta

    meta = {"result": "success", "filter_search_string": filter_search_string, "results": accounts_results}

    return meta


def main():
    # define available arguments/parameters a user can pass to the module
    module_args = dict(
        api_base_url=dict(type='str', required=True, default=None),
        filter_search_string=dict(type='str', required=True, default=None),
        safe_name=dict(type='str', required=True, default=None),
        cyberark_auth_username=dict(type='str', required=True, default=None),
        cyberark_auth_password=dict(type='str', required=True, default=None, no_log=True),
        format=dict(choices=["NOTSET", "DEBUG", "INFO"], default='NOTSET')
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=False
    )

    result = dict(
        message='',
        meta={},
        failed=False,
        changed=False
    )


    if module.params["log_level"]:
        logging.basicConfig(
            level=module.params["log_level"]
        )

    logging.info("Starting Module")

    try:
        meta = cyberark_get_accounts_module_func(module.params)
        if result['result'] == 'success':
            # module.exit_json(changed=True, meta=meta, msg='accounts retrieved successfully')
            result['changed'] = True
            result['meta'] = meta
            result['msg'] = 'accounts retrieved successfully'
            module.exit_json(**result)
        else:
            result['changed'] = False
            result['failed'] = True
            result['meta'] = meta
            result['msg'] = 'accounts retrieved failed'
            module.fail_json(changed=False, meta=meta, msg='accounts retrieved failed')

    except Exception as e:
        module.fail_json(msg="Error while fetching accounts from cyberark", meta={'result': 'error', 'reason': str(e)})

    module.exit_json(**result)

if __name__ == '__main__':
    main()
