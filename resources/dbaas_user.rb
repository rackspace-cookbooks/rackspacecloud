#
# Cookbook Name:: rackspacecloud
# Resource:: dbaas_user
#
# Copyright:: 2013, Rackspace Hosting <zack.feldstein@rackspace.com>
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

actions :create, :delete, :grant, :revoke
default_action :create

attribute :rackspace_username, kind_of: String, required: true
attribute :rackspace_api_key, kind_of: String, required: true
attribute :rackspace_region, kind_of: String, default: 'dfw'
attribute :rackspace_auth_url, kind_of: String
attribute :username, name_attribute: true, kind_of: String, required: true
attribute :databases, kind_of: Array
attribute :instance, kind_of: String, required: true
attribute :password, kind_of: String
attribute :host, kind_of: String, default: '%'

attr_accessor :exists
