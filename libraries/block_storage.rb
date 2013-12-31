#
# Cookbook Name:: rackspacecloud
# Library:: BlockStorage
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

module Opscode
  module Rackspace
    module BlockStorage

      include Opscode::Rackspace

      def cbs

        @@cbs ||= Fog::Rackspace::BlockStorage.new({
                :rackspace_username  => new_resource.rackspace_username,
                :rackspace_api_key   => new_resource.rackspace_api_key,
                :rackspace_region    => new_resource.rackspace_region || :dfw,
                :rackspace_auth_url  => new_resource.rackspace_auth_url || Fog::Rackspace::US_AUTH_ENDPOINT
        })

      end

      def compute

        @@compute ||= Fog::Compute.new({
                :provider => 'Rackspace',
                :rackspace_username  => new_resource.rackspace_username,
                :rackspace_api_key   => new_resource.rackspace_api_key,
                :rackspace_region    => new_resource.rackspace_region || :dfw,
                :rackspace_auth_url  => new_resource.rackspace_auth_url || Fog::Rackspace::US_AUTH_ENDPOINT
        })

      end
    end
  end
end