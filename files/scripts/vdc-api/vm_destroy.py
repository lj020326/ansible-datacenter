# Python script for the Interoute Virtual Data Centre API:
#   Name: vm_destroy.py
#   Purpose: Destroy a virtual machine
#   Requires: class VDCApiCall in the file vdc_api_call.py
# For download and information: 
#   http://cloudstore.interoute.com/main/knowledge-centre/library/vdc-api-python-scripts
#
# Copyright (C) Interoute Communications Limited, 2014

from __future__ import print_function
import vdc_api_call as vdc
import getpass
import json
import os
import pprint

if __name__ == '__main__':
    cloudinit_scripts_dir = 'cloudinit-scripts'
    config_file = os.path.join(os.path.expanduser('~'), '.vdcapi')
    if os.path.isfile(config_file):
        with open(config_file) as fh:
            data = fh.read()
            config = json.loads(data)
            api_url = config['api_url']
            apiKey = config['api_key']
            secret = config['api_secret']
            try:
                cloudinit_scripts_dir = config['cloudinit_scripts_dir']
            except KeyError:
                pass
    else:
        print('API url (e.g. http://10.220.18.115:8080/client/api):', end='')
        api_url = raw_input()
        print('API key:', end='')
        apiKey = raw_input()
        secret = getpass.getpass(prompt='API secret:')

    # Create the api access object
    api = vdc.VDCApiCall(api_url, apiKey, secret)

    # Ask for the VM id
    print ('This script attempts to destroy a VM. USE WITH CARE!')
    print ('Enter value of the VM ID:')
    id = raw_input()

    # Destroy the VM
    request = {
        'id': id,
    }
    result = api.destroyVirtualMachine(request)
    job_id = result['jobid']

    request = {
        'jobid': job_id,
    }

    pprint.pprint(api.wait_for_job(job_id))
