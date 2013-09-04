#
# Cookbook Name:: rackspacecloud
# Resource:: record
#
# Copyright:: 2013, Rackspace Hosting <ryan.walker@rackspace.com>
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


actions :add, :delete, :update
default_action :add

attribute :rackspace_username, :kind_of => String, :required => true
attribute :rackspace_api_key, :kind_of => String, :required => true
attribute :rackspace_region, :kind_of => String, :default => "dfw"
attribute :rackspace_auth_url, :kind_of => String
attribute :name, :name_attribute => true, :kind_of => String, :required => true
attribute :record, :kind_of => String, :required => true
attribute :value, :kind_of => String, :required => true
attribute :type, :kind_of => String, :default => "A"
attribute :ttl, :kind_of => Integer, :default => 300
