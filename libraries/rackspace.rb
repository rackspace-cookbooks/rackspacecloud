#
# Cookbook Name:: rackspacecloud
# Library:: rackspace
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


module Opscode
  module Rackspace

      def initialize(name, run_context=nil)
        super
        begin
          require 'fog'
        rescue LoadError
          Chef::Log.error("Missing gem 'fog'. Use the default rackspace recipe to install it first.")
        end

     end

  end
end
