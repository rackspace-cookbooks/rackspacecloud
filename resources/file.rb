#
# Cookbook Name:: rackspace
# Resource:: cloudfile
# Author:: Julian C. Dunn (<jdunn@opscode.com>)
#
# Copyright 2013, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

actions :create, :create_if_missing, :upload

default_action :create

attribute :rackspace_username, :kind_of => String, :required => true
attribute :rackspace_api_key, :kind_of => String, :required => true
attribute :rackspace_region, :kind_of => String, :default => "dfw"
attribute :rackspace_auth_url, :kind_of => String
attribute :filename, :kind_of => String, :name_attribute => true
attribute :directory, :kind_of => String, :required => true
attribute :binmode, :kind_of => [ TrueClass, FalseClass ], :default => false

attr_accessor :exists
attr_accessor :checksum
