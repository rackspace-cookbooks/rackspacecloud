#
# Cookbook Name:: rackspacecloud
# Provider:: dbaas_user
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
  @current_resource = Chef::Resource::RackspacecloudDbaasUser.new(@new_resource.name)
  user = retr_user
  if user.nil? || user.empty?
    @current_resource.exists = false
    @current_resource
  else
    @current_resource.exists = true
    @current_resource.username = user['name']
    @current_resource.databases = user['databases']
    @current_resource.host = user['host']
  end
end

# Rackspace API expects an array of hashes for Databases
def dbarray_to_dbhash(databases)
  databases.map { |db| { 'name' => db } }
end

def retr_user
  begin
    user = dbaas.list_users(new_resource.instance).body['users'].find do |dbuser|
      dbuser['name'] == new_resource.username
    end
  rescue Fog::Rackspace::Databases::NotFound
    raise 'Database instance ID specified does not exist, please create a database and provide a valid ID'
  end
  return user
end

def delete_user
  dbaas.delete_user(new_resource.instance, new_resource.username)
rescue Fog::Rackspace::Databases::NotFound
  raise "User #{new_resource.username} not found on Database instance #{new_resource.instance}"
else
  Chef::Log.info "User #{new_resource.username} has been removed from Database instance #{new_resource.instance}"
end

def create_user
  dbaas.create_user(
    new_resource.instance,
    new_resource.username,
    new_resource.password,
    databases: dbarray_to_dbhash(new_resource.databases), host: new_resource.host
  )
rescue Fog::Rackspace::Databases::NotFound
  raise 'Database instance ID specified does not exist, please create a database and provide a valid ID'
else
  Chef::Log.info "User #{new_resource.username} has been created on Database instance #{new_resource.instance}"
end

def grant_user_access
  # Fog requires an Obj in order to set the host
  user = OpenStruct.new
  user.name = new_resource.username
  user.host = new_resource.host
  dbaas.grant_user_access(new_resource.instance, user, *new_resource.databases)
# If a database doesn't exist when granting permission the API will still return a success
# so there is not much exceptions we can catch.
# We could validate the DB exists first but it's probably out of scope for the Chef resource
rescue Fog::Rackspace::Databases::NotFound
  raise 'Database instance ID or user specified does not exist, please create a database and provide a valid ID'
else
  Chef::Log.info "User #{new_resource.username} has been granted access to the following databases: " +
                 new_resource.databases.join(',')
end

def revoke_user_access
  new_resource.databases.each do |db|
    dbaas.revoke_user_access(new_resource.instance, new_resource.username, db)
  end
# If a database doesn't exist when granting permission the API will still return a success
# so there is not much exceptions we can catch.
# We could validate the DB exists first but it's probably out of scope for the Chef resource
rescue Fog::Rackspace::Databases::NotFound
  raise 'Database instance ID or user specified does not exist, please create a database and provide a valid ID'
else
  Chef::Log.info "User #{new_resource.username} has been denied access to the following databases: " +
                 new_resource.databases.join(',')
end

def check_user_exists
  @current_resource.exists
end

def check_grant_exists
  dbarray_to_dbhash(new_resource.databases).all? { |e| @current_resource.databases.include?(e) } && (@current_resource.host == new_resource.host)
end

action :create do
  unless check_user_exists
    converge_by("Adding user #{new_resource.username} to instance #{new_resource.instance}") do
      create_user
    end
  end
end

action :delete do
  if check_user_exists
    converge_by("Removing user #{new_resource.username} from instance #{new_resource.instance}") do
      delete_user
    end
  end
end

action :grant do
  unless check_user_exists
    converge_by("Adding user #{new_resource.username} to instance #{new_resource.instance}") do
      create_user
    end
  end
  unless check_grant_exists
    converge_by("Giving user #{new_resource.username} access to databases: #{new_resource.databases.join(',')}") do
      grant_user_access
    end
  end
end

action :revoke do
  if check_grant_exists
    converge_by("Revoking user #{new_resource.username} access from databases: #{new_resource.databases.join(',')}") do
      revoke_user_access
    end
  else
    Chef::Application.fatal!('The requested grant was not found while trying to revoke!')
  end
end
