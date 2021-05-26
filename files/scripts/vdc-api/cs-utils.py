#! /usr/bin/env python

##
## ref: https://raw.githubusercontent.com/cloudops/cookbook_cloudstack/master/resources/api_keys.rb
## usage: https://supermarket.chef.io/cookbooks/cloudstack
##


from __future__ import print_function
import requests
from pprint import pprint, pformat

# import getpass
import os
import sys
import configparser
from collections import OrderedDict

import logging
import json
import time
from cs import CloudStack

logging.basicConfig()
log = logging.getLogger(__name__)
log.setLevel(logging.DEBUG)

class ApiKeyHelper(object):
    """
        Class for making signed API calls to the Interoute VDC.
    """
    def __init__(self, apiUrl='http://localhost:8080/client/api', apiKey=None, secret=None):
        """
            Initialise the signed API call object with the URL and the
            required API key and Secret key.
        """
        log.info("init(): starting")
        self.apiUrl = apiUrl
        self.apiKey = apiKey
        self.secret = secret

    def cloudstack_api_is_running(self):
        logPrefix="cloudstack_api_is_running():"
        log.info("%s starting" % logPrefix)
        # log.debug("cloudstack_api_is_running(): starting")
        try:
            response = requests.get(self.apiUrl)
            log.debug("%s response.status_code=[%s]" % (logPrefix, response.status_code))
            log.debug("%s response.text=[%s]" % (logPrefix, response.text))
            if response.status_code == 401:
              return True
            else:
              return False
        except Exception as error:
            self.handle_error(apiUrl)
            return False

    def create(self, resource):
        new_resource = None
        log.info("create(): starting")
        wait_count = 0
        while ( not self.cloudstack_api_is_running() or wait_count == 5):
            time.sleep(5)
            wait_count += 1
            # logging.info("%s: started" % log_prefix)
            if wait_count == 1: log.info('Waiting CloudStack to start' )

        if self.cloudstack_api_is_running():
            new_resource = self.create_admin_apikeys(resource)
        else:
            log.error('CloudStack not running, cannot generate API keys.')

        return new_resource

    def reset(self, new_resource):
        log.info("reset(): starting")
        # force generate new API keys
        # load_current_resource
        if self.cloudstack_is_running():
            if new_resource.username == 'admin':
                log.info('Reseting admin api keys')
                admin_keys = self.generate_admin_keys(new_resource.url, new_resource.password)
                log.info('admin api keys: Generate new admin keys admin_keys=[%s]' % admin_keys)

                new_resource.admin_apikey = admin_keys['api_key']
                new_resource.admin_secretkey = admin_keys['secret_key']
        else:
            log.error('CloudStack not running, cannot generate API keys.')


    def create_admin_apikeys(self, resource):
        log.info("create_admin_apikeys(): starting")
        # 1. make sure cloudstack is running
        # 2. get admin apikeys
        #    2.1 does admin keys defines in attributes?
        #    2.2 does admin keys found in Chef environment?
        #    2.3 does admin keys are already generated in cloudstack?
        # 3. if none of the above generate new admin api keys
        ##################################################################
        # bypass the section if CloudStack is not running.
        if ('admin_apikey' in resource or 'admin_secretkey' in resource):
            return self.admin_apikeys_from_cloudstack(resource)
        elif self.keys_valid(resource):
            # test API-KEYS on cloudstack, if they work, skip the section.
            resource.exists = True
            log.info('api keys: are valid, nothing to do.')
        else:
            return self.admin_apikeys_from_cloudstack(resource)

    def admin_apikeys_from_cloudstack(self, resource):
        new_resource = resource
        logPrefix="admin_apikeys_from_cloudstack():"
        log.info("%s starting" % logPrefix)
        log.debug("%s resource=%s" % (logPrefix, resource))

        # look if apikeys already exist
        # otherwise  generate them
        if resource['username'] == 'admin':
            admin_keys = self.retrieve_admin_keys(resource['password'])
            log.debug("%s admin_keys=%s" % (logPrefix, admin_keys))
            # if ('api_key' not in admin_keys or admin_keys['api_key'] is None):
            if (admin_keys.get('api_key') is None or admin_keys.get('secret_key') is None):
                log.info('%s keys not found' % logPrefix)
                log.info('%s Creating keys for admin' % logPrefix)
                admin_keys = self.generate_admin_keys(resource['password'])
                log.info('%s admin api keys: Generated new key admin_keys=%s' % (logPrefix, admin_keys))
            else:
                log.info('%s admin api keys: use existing in CloudStack' % logPrefix)

            # return admin_keys
            new_resource['admin_apikey'] = admin_keys['api_key']
            new_resource['admin_secretkey'] = admin_keys['secret_key']
        else:
            log.error('%s Account not admin' % logPrefix)

        log.info("%s new_resource = %s" % (logPrefix, pformat(new_resource)))
        return new_resource

    def generate_admin_keys(self, password = 'password'):
        logPrefix="generate_admin_keys():"
        log.info("%s starting" % logPrefix)

        login_params = { 'command': 'login', 'username': 'admin', 'password': password, 'response': 'json' }

        # # create sessionkey and cookie of the api session initiated with username and password
        session = requests.Session()
        # res = http.post(uri.request_uri, '')  # POST enforced since ACS 4.6
        res = session.post(self.apiUrl, params=login_params)

        get_keys_params = {
            'sessionkey': res.json()['loginresponse']['sessionkey'],
            'command': 'registerUserKeys',
            'response': 'json',
            'id': '2',
        }

        keys = {}

        # use sessionkey + cookie to generate admin API and SECRET keys.
        time.sleep(2) # add some delay to have the session working
        query_for_keys = session.get(self.apiUrl, params=get_keys_params)
        log.info("%s query_for_keys.status_code = %s" % (logPrefix, query_for_keys.status_code))
        if query_for_keys.status_code == 200:
            res_json = query_for_keys.json()
            log.info("%s res_json = %s" % (logPrefix, pformat(res_json)))
            keys = {
                'api_key': res_json['registeruserkeysresponse']['userkeys']['apikey'],
                'secret_key': res_json['registeruserkeysresponse']['userkeys']['secretkey'],
            }
        else:
            log.info("%s Error creating keys errorcode: #%s" % (logPrefix, query_for_keys.status_code))

        return keys


    def keys_valid(self, new_resource):
        logPrefix="keys_valid():"
        log.info("%s starting" % logPrefix)
        log.debug("%s new_resource=%s" % (logPrefix, new_resource))
        # Test if current defined keys are valid
        #
        if ('admin_apikey' in new_resource or 'admin_secretkey' in new_resource):
            try:
                ## ref: https://github.com/exoscale/cs
                cs = CloudStack(endpoint=new_resource.url,
                                key=new_resource.admin_apikey,
                                secret=new_resource.admin_secretkey)

                list_apis = cs.listApis()

            except Exception:
                return False

            if list_apis is None:
                return False
            else:
                return True
        else:
            return False

    def retrieve_admin_keys(self, password = 'password'):
        logPrefix="retrieve_admin_keys():"
        log.info("%s starting" % logPrefix)

        login_params = { 'command': 'login', 'username': 'admin', 'password': password, 'response': 'json' }
        log.info("%s login_params=%s" % (logPrefix, login_params))

        # # create sessionkey and cookie of the api session initiated with username and password
        session = requests.Session()
        # res = http.post(uri.request_uri, '')  # POST enforced since ACS 4.6
        res = session.post(self.apiUrl, params=login_params)

        res_json={}
        try:
            res_json = res.json()
            log.info("%s res_json = %s" % (logPrefix, pformat(res_json)))
        except json.decoder.JSONDecodeError as exp:
            log.error("%s json not returned result.text=%s" % (logPrefix, res.text))
            raise exp

        if res.status_code == 531:
            log.error("%s Error in authenticating when logging into API: #%s" % (logPrefix, res_json.status_code))
            raise Exception("authentication error: return errorcode %s, errortext %r." % (
                res_json.status_code, res_json.errortext))
        elif res.status_code != 200:
            log.error("%s Error logging into API: #%s" % (logPrefix, res_json.status_code))
            raise Exception("exception error: return errorcode %s, errortext %r." % (
                res_json.status_code, res_json.errortext))

        # get_keys_params = {
        #     'sessionkey': res_json['loginresponse']['sessionkey'],
        #     'command': 'listUsers',
        #     'response': 'json',
        #     'id': '2',
        # }
        get_keys_params = {
            'command': 'listUsers',
            'response': 'json',
        }

        keys = {}

        # use sessionkey + cookie to generate admin API and SECRET keys.
        time.sleep(2) # add some delay to have the session working
        query_for_keys = session.get(self.apiUrl, params=get_keys_params)

        if query_for_keys.status_code == 200:
            res_json_keys = query_for_keys.json()
            log.info("%s res_json_keys = %s" % (logPrefix, pformat(res_json_keys)))

            # keys['api_key']=res_json_keys['listusersresponse']['user'][0]['apikey']
            # if 'secret_key' in res_json_keys['listusersresponse']['user'][0]:
            #     keys['secret_key']=res_json_keys['listusersresponse']['user'][0]['secretkey']

            keys = {
                'api_key':    res_json_keys['listusersresponse']['user'][0].get('apikey'),
                'secret_key': res_json_keys['listusersresponse']['user'][0].get('secretkey'),
            }

            # get_user_params = {
            #     'command': 'getUser',
            #     'userapikey': keys['api_key'],
            #     'response': 'json',
            # }
            # query_for_userkeys = session.get(self.apiUrl, params=get_user_params)
            # res_json_user = query_for_userkeys.json()
            # log.info("%s res_json_user = %s" % (logPrefix, pformat(res_json_user)))

            # get_account_params = {
            #     'command': 'listAccounts',
            #     'response': 'json',
            # }
            # query_for_userkeys = session.get(self.apiUrl, params=get_account_params)
            # res_json_user = query_for_userkeys.json()
            # log.info("%s res_json_user = %s" % (logPrefix, pformat(res_json_user)))

        else:
            log.error("%s Error getting keys errorcode: #%s" % (logPrefix, query_for_keys.status_code))
            raise Exception("exception error: return errorcode %s, errortext %r." % (
                query_for_keys.status_code, query_for_keys.errortext))

        return keys


if __name__ == '__main__':

    # apiUrl = "http://node01.johnson.int:8080/client/api"
    # username='admin'
    # password=print(os.environ['CS_PASSWORD'])

    home_dir = os.path.expanduser("~")

    conf_file=None
    if os.path.isfile("./.cs-utils.conf"):
        conf_file="./.cs-utils.conf"
    elif os.path.isfile("%s/.cs-utils.conf" % home_dir):
        conf_file = "%s/.cs-utils.conf" % home_dir
    else:
        log.error("no conf file [.cs-utils.conf] found in current or home dir")
        sys.exit(1)

    ## ref: https://www.reddit.com/r/learnpython/comments/264ffw/what_is_the_pythonic_way_of_storing_credentials/
    config = configparser.ConfigParser()
    config.read(conf_file)

    username = config.get("configuration", "username")
    password = config.get("configuration", "password")
    endpoint = config.get("configuration", "endpoint")
    timeout = config.get("configuration", "timeout")

    cs_conf_file = config.get("configuration", "cloudstack_conf_file")
    cs_conf_path = "%s/%s" % (home_dir, cs_conf_file)
    # cs_conf_path = os.path.expanduser(cs_conf_path)

    if os.path.isfile(cs_conf_path):
        log.error("conf file [%s] already exists, quitting" % cs_conf_path)
        sys.exit(1)

    log.info("cloudstack conf file will be created at [%s]" % cs_conf_path)

    resource = {
        'username': username,
        'password': password
    }
    log.setLevel(logging.DEBUG)
    log.info("starting create")

    # Create the api access object
    api = ApiKeyHelper(endpoint)
    new_resource = api.create(resource)
    log.info("main(): api.create returned new_resource=%s" % pformat(new_resource))

    ## added
    cloud_config = configparser.ConfigParser(dict_type=OrderedDict)
    cloud_config.read_dict(
        {'cloudstack':{
            'endpoint': endpoint,
            'key': new_resource['admin_apikey'],
            'secret': new_resource['admin_secretkey'],
            'timeout': timeout
        }})

    with open(cs_conf_path, 'w') as configfile:
        cloud_config.write(configfile)
