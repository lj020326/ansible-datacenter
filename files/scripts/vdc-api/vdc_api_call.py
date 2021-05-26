#! /usr/bin/env python
# Python class to simplify access to the Interoute Virtual Data Centre API
# Original code by Kelcey Damage & Kraig Amador, 2012
# Developed for Interoute.com by Sandy Walker, 2014
# For download and information: 
# http://cloudstore.interoute.com/main/knowledge-centre/library/vdc-api-python-scripts

# This program is configured for Python version 2.6/2.7 
#
# Copyright (C) Interoute Communications Limited, 2014

from __future__ import print_function
import base64
import hashlib
import hmac
import json
import sys
import time

import urllib
#import urllib2

## ref: https://stackoverflow.com/questions/2792650/import-error-no-module-name-urllib2
try:
    # For Python 3.0 and later
    from urllib.request import urlopen
except ImportError:
    # Fall back to Python 2's urllib2
    from urllib2 import urlopen

try:
    # For Python 3.0 and later
    from urllib.error import HTTPError
except ImportError:
    # Fall back to Python 2's urllib2
    from urllib2 import HTTPError

## added
import socket
import requests
import traceback

import logging

logging.basicConfig()
log = logging.getLogger(__name__)
log.setLevel(logging.INFO)

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

class VDCApiCall(object):
    """
        Class for making signed API calls to the Interoute VDC.
    """
    def __init__(self, apiUrl, apiKey='', secret=''):
        """
            Initialise the signed API call object with the URL and the
            required API key and Secret key.
        """
        self.apiUrl = apiUrl
        self.apiKey = apiKey
        self.secret = secret

    def request(self, args):
        """
            Form the request based on the provided args and using the apikey
            and secret. This ensures the request has the correct signature
            calculated.
        """
        args['apiKey'] = self.apiKey

        request = zip(args.keys(), args.values())
        request.sort(key=lambda x: x[0].lower())
        request_data = "&".join(["=".join([r[0], urllib.quote_plus(str(r[1]))])
                                for r in request])
        hashStr = "&".join(
            [
                "=".join(
                    [r[0].lower(),
                     str.lower(urllib.quote_plus(str(r[1]))).replace(
                         "+", "%20"
                     )]
                ) for r in request
            ]
        )
        sig = urllib.quote_plus(base64.b64encode(
            hmac.new(
                self.secret,
                hashStr,
                hashlib.sha1
            ).digest()
        ).strip())

        request_data += "&signature=%s" % sig

        try:
            # connection = urllib2.urlopen(self.apiUrl, request_data)
            connection = urlopen(self.apiUrl, request_data)
            response = connection.read()
        # except urllib2.HTTPError as error:
        except HTTPError as error:
            print('HTTP Error: %s' % error.code)
            description = str(error.info())
            description = description.split('\n')
            description = [line
                           for line
                           in description
                           if line.startswith('X-Description: ')]

            if len(description) > 0:
                description = description[0].split(':', 1)[-1].lstrip()
            else:
                description = '(No extended error message.)'

            print(description)
            sys.exit()
        return response

    def wait_for_job(self, job_id, delay=2, display_progress=True):
        """
            Wait for the given job ID to return a result.
            Sleeps for 'delay' seconds between each check for the job
            finishing- default 2.
            Will output a '.' for every 'delay' if 'display_progress' is true.
        """
        request = {
            'jobid': job_id,
        }

        while(True):
            result = self.queryAsyncJobResult(request)
            if display_progress:
                print('.', end='')
                sys.stdout.flush()
            if 'jobresult' in result:
                print('')
                return result['jobresult']
            time.sleep(delay)

    def __getattr__(self, name):
        def handlerFunction(*args, **kwargs):
            if kwargs:
                return self._make_request(name, kwargs)
            return self._make_request(name, args[0])
        return handlerFunction

    def _make_request(self, command, args):
        args['response'] = 'json'
        args['command'] = command
        data = self.request(args)
        # The response is of the format {commandresponse: actual-data}
        key = command.lower() + "response"
        return json.loads(data)[key]

    ## added from chef cloudstack-helper
    def handle_error(self, client_address):
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


    def cloudstack_api_is_running(self):
        # log.debug("cloudstack_api_is_running(): starting")
        try:
            # connection = urllib2.urlopen(apiUrl, request_data)
            # response = connection.read()
            response = requests.get(self.apiUrl)
            log.debug("cloudstack_api_is_running(): response.status_code=[%s]" % response.status_code)
            log.debug("cloudstack_api_is_running(): response.text=[%s]" % response.text)
            # if response.message == 'Unauthorized':
            # if response.json().message == 'Unauthorized':
            # if response.text == 'Unauthorized':
            if response.status_code == 401:
              return True
            else:
              return False

        #except urllib2.HTTPError as error:
        except Exception as error:
            self.handle_error(apiUrl)
            return False

        #return response


    def integration_api_open(self, host = 'localhost', port = '8096'):
        apiUrl = 'http://' + host + ':' + port + '/client/api/'

        try:
            # connection = urllib2.urlopen(apiUrl, request_data)
            # response = connection.read()
            response = requests.get(apiUrl)
            # if response.message == 'Unauthorized':
            # if response.json().message == 'Unauthorized':
            if response.text.empty:
                return True
            else:
                return False

        # except urllib2.HTTPError as error:
        except Exception as error:
            self.handle_error(apiUrl)
            return False

            # return response

    def cloudstack_is_running(self):
        # Test if CloudStack Management server is running on localhost.
        return self.port_open('127.0.0.1', 8080)

    def test_connection(self, apiUrl="http://localhost:8080/client/api/", api_key='', secret_key=''):
        # test connection to CloudStack API
        # cs = CloudStack(endpoint=apiUrl,
        #                   key=api_key,
        #                   secret=secret_key)
        #
        # users = cs.listUsers()
        # print(users)

        users = self.listUsers()
        print(users)

        return len(users) >= 1
