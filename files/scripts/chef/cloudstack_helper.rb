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

require 'socket'
require 'timeout'
require 'uri'
require 'net/http'

module Cloudstack
  module Helper
    def port_open(ip, port, seconds = 1)
      Timeout.timeout(seconds) do
        begin
          TCPSocket.new(ip, port).close
          true
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          false
        end
      end
    rescue Timeout::Error
      false
    end

    def verify_db_connection?(db_host = 'localhost', db_user = 'root', db_password = 'password')
      # Make sure we can connect to db server
      conn_db_test = "mysql -h #{db_host} -u #{db_user} -p#{db_password} -e 'show databases;'"
      begin
        if shell_out!(conn_db_test).error?
          false
        else
          true
        end
      rescue
        false
      end
    end

    def db_exist?(db_host = 'localhost', db_user = 'cloud', db_password = 'password')
      # Test if CloudStack Database already exist
      # if fail to connect with db_user, return false;
      conn_db_test = "mysql -h #{db_host} -u #{db_user} -p#{db_password} -e 'show databases;'|grep cloud"
      begin
        if shell_out!(conn_db_test).error?
          false
        else
          true
        end
      rescue
        false
      end
    end

    def cloudstack_api_is_running?(host = 'localhost')
      uri = URI('http://' + host + ':8080/client/api/')
      cs_connect = Net::HTTP::Get.new(uri.to_s)
      begin
        response = Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.request(cs_connect)
        end
        if response.message == 'Unauthorized'
          return true
        else
          return false
        end
      rescue
        return false
      end
    end

    def integration_api_open?(host = 'localhost', port = '8096')
      # return true if integration api port is open.
      uri = URI('http://' + host + ':' + port + '/client/api/')
      cs_connect = Net::HTTP::Get.new(uri.to_s)
      begin
        response = Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.request(cs_connect)
        end
        if response.message.empty
          return true
        else
          return false
        end
      rescue
        return false
      end
    end

    def cloudstack_is_running?
      # Test if CloudStack Management server is running on localhost.
      port_open('127.0.0.1', 8080)
    end

    def test_connection?(api_key, secret_key)
      # test connection to CloudStack API
      require 'cloudstack_ruby_client'
      client = CloudstackRubyClient::Client.new('http://localhost:8080/client/api/', api_key, secret_key, false)
      begin
        test = client.list_accounts
      rescue LoadError => e
        Chef::Log.error("unable to contact CloudStack API: #{e}")
      end
      test['count'] >= 1
    end
  end
end
