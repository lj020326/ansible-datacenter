#! /usr/bin/env python
# Python script for the Interoute Virtual Data Centre API:
#   Name: iso_get_by_zone.py
#   Purpose: List available ISOs to create a VM, in a specified zone
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

    # Get the zone ID- you can find these IDs with the zone_get_all.py script
    zone_id = raw_input('ID of zone to filter the list of templates' +
                        ' (you can find these IDs with the zone_get_all.py' +
                        ' script):')

    request = {
        'isofilter': 'executable', 'zoneid': zone_id
    }
    result = api.listIsos(request)

    for iso in result['iso']:
        print('%s: %s (NAME: %s, TYPE: %s)' % (
            iso['id'],
            iso['displaytext'],
            iso['name'],
            iso['ostypename'],
        ))
