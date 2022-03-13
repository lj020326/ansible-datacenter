#! /usr/bin/env python
# Python script for the Interoute Virtual Data Centre API:
#   Name: vm_deploy.py
#   Purpose: Deploy a virtual machine
#   Requires: class VDCApiCall in the file vdc_api_call.py
# For download and information: 
#   https://github.com/Interoute/VDC-API-examples-Python
#
# Copyright (C) Interoute Communications Limited, 2016

from __future__ import print_function
import vdc_api_call as vdc
import getpass
import json
import os
import pprint

if __name__ == '__main__':
    config_file = os.path.join(os.path.expanduser('~'), '.vdcapi')
    if os.path.isfile(config_file):
        with open(config_file) as fh:
            data = fh.read()
            config = json.loads(data)
            api_url = config['api_url']
            apiKey = config['api_key']
            secret = config['api_secret']
    else:
        print('API url (e.g. http://10.220.18.115:8080/client/api):', end='')
        api_url = raw_input()
        print('API key:', end='')
        apiKey = raw_input()
        secret = getpass.getpass(prompt='API secret:')

    # Create the api access object
    api = vdc.VDCApiCall(api_url, apiKey, secret)

    # Get the desired hostname of the VM
    vm_hostname = raw_input('Enter the desired VM hostname:')

    # Get the VM description
    vm_description = raw_input('Enter the desired VM description:')

    # Get the zone ID- you can find these IDs using the zone_get_all.py script
    zone_id = raw_input('Enter the zone ID (from zone_get_all.py script):')

    # Get the template ID- you can find these IDs using the template_get_by_zone.py
    # script
    template_id = raw_input('Enter the template ID' +
                            ' (from the template_get_by_zone.py script):')

    # Get the service offering ID- you can find these using the
    # service_offering_get_all.py script
    service_offering_id = raw_input('Enter the service offering ID' +
                                    ' (from the service_offering_get_all.py' +
                                    ' script):')
    # Get the network ID (or IDs if more than one network)
    network_ids = raw_input('Enter the network ID, or enter more than one separated by commas' +
                            ' (from the output of networks_get_by_zone.py):')

    # Deploy the VM

    request = {
        'serviceofferingid': service_offering_id,
        'templateid': template_id,
        'networkids': network_ids,
        'zoneid': zone_id,
        'displayname': vm_description,
        'name': vm_hostname
    }

    result = api.deployVirtualMachine(request)

    pprint.pprint(api.wait_for_job(result['jobid']))
