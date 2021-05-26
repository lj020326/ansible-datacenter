
#! /usr/bin/env python

##
## ref: https://raw.githubusercontent.com/cloudops/cookbook_cloudstack/master/resources/api_keys.rb
## usage: https://supermarket.chef.io/cookbooks/cloudstack
##


from __future__ import print_function
import vdc_api_call as vdc
import requests

# import getpass
# import json
# import os

import logging
import time
from cs import CloudStack

logging.basicConfig()
log = logging.getLogger(__name__)
log.setLevel(logging.DEBUG)

log.info("hello world!")
