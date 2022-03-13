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
import urllib2

class VDCApiCall(object):
    """
        Class for making signed API calls to the Interoute VDC.
    """
    def __init__(self, api_url, apiKey, secret):
        """
            Initialise the signed API call object with the URL and the
            required API key and Secret key.
        """
        self.api_url = api_url
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
            connection = urllib2.urlopen(self.api_url, request_data)
            response = connection.read()
        except urllib2.HTTPError as error:
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
