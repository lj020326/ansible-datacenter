##
## ref: https://raw.githubusercontent.com/cloudops/cookbook_cloudstack/master/resources/api_keys.rb
## usage: https://supermarket.chef.io/cookbooks/cloudstack
##

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

default_action :create

property :username,        String, name_property: true
property :url,             String, default: 'http://localhost:8080/client/api'
property :password,        String, default: 'password'
property :admin_apikey,    String
property :admin_secretkey, String
property :ssl,             equal_to: [true, false, 'true', 'false'], default: false

actions :create do
  wait_count = 0
  until cloudstack_api_is_running? || wait_count == 5
    cloudstack_api_is_running?
    sleep(5)
    wait_count += 1
    Chef::Log.info 'Waiting CloudStack to start' if wait_count == 1
  end

  if cloudstack_api_is_running?
    create_admin_apikeys
  else
    Chef::Log.error 'CloudStack not running, cannot generate API keys.'
  end
end

actions :reset do
  # force generate new API keys
  # load_current_resource
  if cloudstack_is_running?
    if new_resource.username == 'admin'
      converge_by('Reseting admin api keys') do
        admin_keys = generate_admin_keys(new_resource.url, new_resource.password)
        Chef::Log.info 'admin api keys: Generate new'
        node.normal['cloudstack']['admin']['api_key'] = admin_keys[:api_key]
        node.normal['cloudstack']['admin']['secret_key'] = admin_keys[:secret_key]
        node.save unless Chef::Config[:solo]
        new_resource.admin_apikey = admin_keys[:api_key]
        new_resource.admin_secretkey = admin_keys[:secret_key]
      end
    end
  else
    Chef::Log.error 'CloudStack not running, cannot generate API keys.'
  end
end

action_class do
  require 'uri'
  require 'net/http'
  require 'json'

  include Cloudstack::Helper

  def create_admin_apikeys
    # 1. make sure cloudstack is running
    # 2. get admin apikeys
    #    2.1 does admin keys defines in attributes?
    #    2.2 does admin keys found in Chef environment?
    #    2.3 does admin keys are already generated in cloudstack?
    # 3. if none of the above generate new admin api keys
    ##################################################################
    # bypass the section if CloudStack is not running.
    if new_resource.admin_apikey || new_resource.admin_secretkey
      # if keys attributes are empty search in Chef environment for other node having API-KEYS.
      if Chef::Config[:solo]
        Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
        other_nodes = []
      else
        other_nodes = search(:node, "chef_environment:#{node.chef_environment} AND cloudstack_admin_api_key:* NOT name:#{node.name}")
      end
      if other_nodes.empty?
        admin_apikeys_from_cloudstack
      else
        new_resource.admin_apikey(other_nodes.first['cloudstack']['admin']['api_key'])
        new_resource.admin_secretkey(other_nodes.first['cloudstack']['admin']['secret_key'])
        if keys_valid?
          # API-KEYS from other nodes are valids, so updating current node attributes.
          # new_resource.exists = true
          Chef::Log.info "api keys: found valid keys from #{other_nodes.first.name} in the Chef environment: #{node.chef_environment}."
          Chef::Log.info 'api keys: updating node attributes'
        end
      end
    elsif keys_valid?
      # test API-KEYS on cloudstack, if they work, skip the section.
      new_resource.exists = true
      Chef::Log.info 'api keys: are valid, nothing to do.'
    else
      admin_apikeys_from_cloudstack
    end
  end

  def admin_apikeys_from_cloudstack
    # look if apikeys already exist
    # otherwise  generate them
    if new_resource.username == 'admin'
      admin_keys = retrieve_admin_keys(new_resource.url, new_resource.password)
      if admin_keys[:api_key].nil?
        converge_by('Creating api keys for admin') do
          admin_keys = generate_admin_keys(new_resource.url, new_resource.password)
          Chef::Log.info 'admin api keys: Generate new'
        end
      else
        Chef::Log.info 'admin api keys: use existing in CloudStack'
      end
      # puts admin_keys
      node.normal['cloudstack']['admin']['api_key'] = admin_keys[:api_key]
      node.normal['cloudstack']['admin']['secret_key'] = admin_keys[:secret_key]
      node.save unless Chef::Config[:solo]
      new_resource.admin_apikey = admin_keys[:api_key]
      new_resource.admin_secretkey = admin_keys[:secret_key]
      Chef::Log.info "$admin_apikey = #{new_resource.admin_apikey}"
    else
      Chef::Log.error 'Account not admin'
    end
  end

  def generate_admin_keys(url = 'http://localhost:8080/client/api', password = 'password')
    login_params = { command: 'login', username: 'admin', password: password, response: 'json' }
    # create sessionkey and cookie of the api session initiated with username and password
    uri = URI(url)
    uri.query = URI.encode_www_form(login_params)
    http = Net::HTTP.new(uri.hostname, uri.port)
    res = http.post(uri.request_uri, '') # POST enforced since ACS 4.6
    get_keys_params = {
      sessionkey: JSON.parse(res.body)['loginresponse']['sessionkey'],
      command: 'registerUserKeys',
      response: 'json',
      id: '2',
    }

    # use sessionkey + cookie to generate admin API and SECRET keys.
    uri2 = URI(url)
    uri2.query = URI.encode_www_form(get_keys_params)
    sleep(2) # add some delay to have the session working
    http_cookie = res.response['set-cookie'].split('; ')[0]
    http_headers = { 'Cookie': http_cookie }
    query_for_keys = http.get(uri2.request_uri, http_headers)

    if query_for_keys.code == '200'
      keys = {
        api_key: JSON.parse(query_for_keys.body)['registeruserkeysresponse']['userkeys']['apikey'],
        secret_key: JSON.parse(query_for_keys.body)['registeruserkeysresponse']['userkeys']['secretkey'],
      }
    else
      Chef::Log.info "Error creating keys errorcode: #{query_for_keys.code}"
    end
    keys
  end

  def keys_valid?
    # Test if current defined keys from Chef are valid
    #
    if new_resource.admin_apikey || new_resource.admin_secretkey
      # return false if one key is empty
      require 'cloudstack_ruby_client'
      begin
        client = CloudstackRubyClient::Client.new(new_resource.url, new_resource.admin_apikey, new_resource.admin_secretkey, new_resource.ssl)
        list_apis = client.list_apis
      rescue
        false
      end
      if list_apis.nil?
        false
      else
        true
      end
    else
      false
    end
  end

  def retrieve_admin_keys(url = 'http://localhost:8080/client/api', password = 'password')
    login_params = { command: 'login', username: 'admin', password: password, response: 'json' }
    # create sessionkey and cookie of the api session initiated with username and password
    uri = URI(url)
    uri.query = URI.encode_www_form(login_params)
    http = Net::HTTP.new(uri.hostname, uri.port)
    res = http.post(uri.request_uri, '') # POST enforced since ACS 4.6
    get_keys_params = {
      sessionkey: JSON.parse(res.body)['loginresponse']['sessionkey'],
      command: 'listUsers',
      response: 'json',
      id: '2',
    }
    # use sessionkey + cookie to generate admin API and SECRET keys.
    uri2 = URI(url)
    uri2.query = URI.encode_www_form(get_keys_params)
    sleep(2) # add some delay to have the session working
    http_cookie = res.response['set-cookie'].split('; ')[0]
    http_headers = { 'Cookie': http_cookie }
    users = http.get(uri2.request_uri, http_headers)
    if users.code == '200'
      keys = {
        api_key:    JSON.parse(users.body)['listusersresponse']['user'].first['apikey'],
        secret_key: JSON.parse(users.body)['listusersresponse']['user'].first['secretkey'],
      }
    else
      Chef::Log.info "Error creating keys errorcode: #{users.code}"
    end
    keys
  end
end
