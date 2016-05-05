#
# Cookbook Name:: rackspacecloud
# Provider:: dbaas_db
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

require 'ostruct'
include Opscode::Rackspace::Databases

use_inline_resources if defined?(use_inline_resources)

def whyrun_supported?
  true
end

def load_current_resource
  @current_resource = Chef::Resource::RackspacecloudDbaasDb.new(@new_resource.name)
  db = retr_db
  if db.nil? || db.empty?
    @current_resource.exists = false
    @current_resource
  else
    @current_resource.exists = true
    @current_resource.name = db['name']
  end
end

def retr_db
  begin
    db = dbaas.list_databases(new_resource.instance).body['databases'].find do |db_current|
      db_current['name'] == new_resource.name
    end
  rescue Fog::Rackspace::Databases::NotFound
    raise 'Database instance ID specified does not exist, please create a database and provide a valid ID'
  end
  return db
end

def delete_db
  dbaas.delete_database(new_resource.instance, new_resource.name)
rescue Fog::Rackspace::Databases::NotFound
  raise "Database not found on Database instance #{new_resource.instance}"
else
  Chef::Log.info "Database #{new_resource.name} has been removed from Database instance #{new_resource.instance}"
end

def create_db
  dbaas.create_database(new_resource.instance, new_resource.name)
rescue Fog::Rackspace::Databases::NotFound
  raise 'Database instance ID specified does not exist, please create a database and provide a valid ID'
else
  Chef::Log.info "Database #{new_resource.name} has been created on Database instance #{new_resource.instance}"
end

def check_db_exists
  @current_resource.exists
end

action :create do
  unless check_db_exists
    converge_by("Adding database #{new_resource.name} to instance #{new_resource.instance}") do
      create_db
    end
  end
end

action :delete do
  if check_db_exists
    converge_by("Removing database #{new_resource.name} from instance #{new_resource.instance}") do
      delete_db
    end
  end
end
