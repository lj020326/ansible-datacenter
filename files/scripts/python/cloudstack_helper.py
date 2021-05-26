## ref: https://github.com/cloudops/cookbook_cloudstack/blob/master/libraries/cloudstack_helper.rb
#
# Cookbook Name:: cloudstack
# Library:: cloudstack
# Author:: Pierre-Luc Dion <pdion@cloudops.com>
# Copyright 2018, CloudOps, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
#
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
# Test if a TCP port is open and return true or false
# return boolean
# cut&paste snipet from :http://stackoverflow.com/questions/517219/ruby-see-if-a-port-is-open

from __future__ import print_function

import socket
import requests
import traceback

import base64
import hashlib
import hmac
import json
import sys
import time
import urllib
import urllib2

## ref: https://stackoverflow.com/questions/2281850/timeout-function-if-it-takes-too-long-to-finish
import signal

## ref: https://github.com/exoscale/cs
from cs import CloudStack


class timeout:
    def __init__(self, seconds=1, error_message='Timeout'):
        self.seconds = seconds
        self.error_message = error_message
    def handle_timeout(self, signum, frame):
        raise TimeoutError(self.error_message)
    def __enter__(self):
        signal.signal(signal.SIGALRM, self.handle_timeout)
        signal.alarm(self.seconds)
    def __exit__(self, type, value, traceback):
        signal.alarm(0)


class CloudstackHelper:
    def handle_error(self, request, client_address):
        """Handle an error gracefully.  May be overridden.

        The default is to print a traceback and continue.

        """
        print('-' * 40)
        print('Exception happened during processing of request from', end=' ')
        print(client_address)
        # traceback.print_exc() # XXX But this goes to stderr!
        traceback.print_exc(file=sys.stdout)
        print('-' * 40)

    def port_open(self, ip, port, seconds = 1):
        try:
            with timeout(seconds):
                #TCPSocket.new(ip, port).close
                # ref: https://docs.python.org/3.4/howto/sockets.html
                # create an INET, STREAMing socket
                s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                # now connect to the web server on port 80 - the normal http port
                s.connect((ip, port))

                return True
        except TimeoutError:
            return False

    # def verify_db_connection(db_host = 'localhost', db_user = 'root', db_password = 'password'):
    #   # Make sure we can connect to db server
    #   conn_db_test = "mysql -h #{db_host} -u #{db_user} -p#{db_password} -e 'show databases;'"
    #   begin
    #     if shell_out!(conn_db_test).error?
    #       false
    #     else
    #       true
    #     end
    #   rescue
    #     false
    #   end
    # end
    #
    # def db_exist?(db_host = 'localhost', db_user = 'cloud', db_password = 'password')
    #   # Test if CloudStack Database already exist
    #   # if fail to connect with db_user, return false;
    #   conn_db_test = "mysql -h #{db_host} -u #{db_user} -p#{db_password} -e 'show databases;'|grep cloud"
    #   begin
    #     if shell_out!(conn_db_test).error?
    #       false
    #     else
    #       true
    #     end
    #   rescue
    #     false
    #   end
    # end

    def cloudstack_api_is_running(self, host = 'localhost'):
        api_url = 'http://' + host + ':8080/client/api/'

        try:
            # connection = urllib2.urlopen(api_url, request_data)
            # response = connection.read()
            response = requests.get(api_url)
            # if response.message == 'Unauthorized':
            # if response.json().message == 'Unauthorized':
            if response.text == 'Unauthorized':
              return True
            else:
              return False

        #except urllib2.HTTPError as error:
        except Exception as error:
            self.handle_error(request, api_url)
            return False

        #return response


    def integration_api_open(self, host = 'localhost', port = '8096'):
        api_url = 'http://' + host + ':' + port + '/client/api/'

        try:
            # connection = urllib2.urlopen(api_url, request_data)
            # response = connection.read()
            response = requests.get(api_url)
            # if response.message == 'Unauthorized':
            # if response.json().message == 'Unauthorized':
            if response.text.empty:
                return True
            else:
                return False

        # except urllib2.HTTPError as error:
        except Exception as error:
            self.handle_error(request, api_url)
            return False

            # return response

    def cloudstack_is_running(self):
        # Test if CloudStack Management server is running on localhost.
        return self.port_open('127.0.0.1', 8080)

    def test_connection(self, api_url="http://localhost:8080/client/api/", api_key, secret_key):
        # test connection to CloudStack API
        cs = CloudStack(endpoint=api_url,
                          key=api_key,
                          secret=secret_key)

        users = cs.listUsers()
        print(users)

        return len(users) >= 1

end
