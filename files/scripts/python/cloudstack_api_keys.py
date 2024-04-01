#
# Cookbook Name:: cloudstack
# Resource:: api_keys
# Author:: Pierre-Luc Dion (<pdion@cloudops.com>)
# Copyright 2018, CloudOps, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
default_action = 'create'
username = ''
url = 'http://localhost:8080/client/api'
password = 'password'
admin_apikey = ''
admin_secretkey = ''
ssl = False

def create():
    wait_count = 0
    while not cloudstack_api_is_running() and wait_count < 5:
        cloudstack_api_is_running()
        time.sleep(5)
        wait_count += 1
        if wait_count == 1:
            print('Waiting CloudStack to start')
    if cloudstack_api_is_running():
        create_admin_apikeys()
    else:
        print('CloudStack not running, cannot generate API keys.')

def reset():
    if cloudstack_is_running():
        if username == 'admin':
            admin_keys = generate_admin_keys(url, password)
            print('admin api keys: Generate new')
            admin_apikey = admin_keys['api_key']
            admin_secretkey = admin_keys['secret_key']
    else:
        print('CloudStack not running, cannot generate API keys.')

def create_admin_apikeys():
    if admin_apikey or admin_secretkey:
        if admin_apikey and admin_secretkey:
            admin_apikeys_from_cloudstack()
        else:
            if keys_valid():
                print("api keys: found valid keys from {0} in the Chef environment: {1}.".format(other_nodes.first.name, node.chef_environment))
                print('api keys: updating node attributes')
    elif keys_valid():
        new_resource.exists = True
        print('api keys: are valid, nothing to do')

def cloudstack_api_is_running():
    # implementation of cloudstack_api_is_running function
    pass

def cloudstack_is_running():
    # implementation of cloudstack_is_running function
    pass

def generate_admin_keys(url, password):
    # implementation of generate_admin_keys function
    pass

def admin_apikeys_from_cloudstack():
    # implementation of admin_apikeys_from_cloudstack function
    pass

def keys_valid():
    # implementation of keys_valid function
    pass

