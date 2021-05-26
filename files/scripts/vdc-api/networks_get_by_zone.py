#! /usr/bin/env python
# Python script for the Interoute Virtual Data Centre API:
#   Name: networks_get_by_zone.py
#   Purpose: List available networks in a specific zone
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

    #THE CODE ABOVE HERE YOU DO NOT NEED TO CHANGE.

    #THE CODE BELOW IS WHERE YOU MAKE THE API CALL AND
    #PROCESS THE DATA THAT IS IN THE RESPONSE

    # (1) Get the zone ID
    zone_id = raw_input('ID of the zone?:')
 
    # (2) contents of the request
    request = {
     'zoneid': zone_id
    }

    # (3) send the request to the API server
    result = api.listNetworks(request)
 
    # (4) print out selected parts of the response data
    for network in result['network']:
        print('%s: %s (gateway: %s, cidr: %s)' % (
         network['id'],
         network['name'],
         network['gateway'],
         network['cidr']
    ))
