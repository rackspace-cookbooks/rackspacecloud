#
# Cookbook Name:: rackspacecloud
# Resource:: cbs
#
# Copyright:: 2014, Rackspace Hosting <steven.gonzales@rackspace.com>
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

actions :create_volume, :attach_volume, :create_and_attach, 
  :detach_volume, :delete_volume, :detach_and_delete
default_action :create_and_attach

attribute :rackspace_username, :kind_of => String, :required => true
attribute :rackspace_api_key, :kind_of => String, :required => true
attribute :rackspace_region, :kind_of => String, :default => "dfw"
attribute :rackspace_auth_url, :kind_of => String, :required => false
attribute :name, :name_attribute => true,  :kind_of => String, :required => true
attribute :type, :kind_of => String, :default => "SATA", :equal_to => ['SATA', 'SSD']
attribute :size, :kind_of => Integer,  :default => 100, :required => true
attribute :volume_id, :kind_of => String, :required => false

attr_accessor :server, :exists, :attached