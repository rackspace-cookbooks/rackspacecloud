#
# Cookbook Name:: rackspacecloud
# Provider:: cbs
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

include Opscode::Rackspace::BlockStorage

def whyrun_supported?
  true
end

#override the load_current_resource method to set resource attributes 
#indcating whether the #volume already exists and if the volume is 
#attached to the current server
def load_current_resource
  @current_resource = Chef::Resource::RackspacecloudCbs.new(@new_resource.name) 
  @current_resource.server = locate_server()
  match_existing_volume()
  match_existing_attachment()
  @current_resource
end

action :create_volume do
  converge_by("Adding cloud block storage volume") do
    unless @current_resource.exists
      create_volume()
      @new_resource.updated_by_last_action(true)
    else
      Chef::Log.info(
        "Cloud Block Storage volume '#{@current_resource.name}' already exists, no action taken")
    end
    update_node_data
  end
end

action :attach_volume do
  converge_by("Adding cloud block storage volume") do
    unless @current_resource.attached
      attach_volume()
      @new_resource.updated_by_last_action(true)
    else
      Chef::Log.info(
        "Cloud Block Storage volume '#{@current_resource.name}' already attached, no action taken")
    end
    update_node_data
  end
end

action :create_and_attach do
  converge_by("Adding cloud block storage volume") do
    unless @current_resource.exists
      create_volume()
    else
      Chef::Log.info(
        "Cloud Block Storage volume '#{@current_resource.name}' already exists, no action taken")
    end
    unless @current_resource.attached
      attach_volume()
      @new_resource.updated_by_last_action(true)
    else
      Chef::Log.info(
        "Cloud Block Storage volume '#{@current_resource.name}' already attached, no action taken")
    end
    update_node_data
  end
end

private

#locate the Fog::Compute::RackspaceV2::Server for this node by ip_address
def locate_server
  compute.servers.select{
      |server| server.public_ip_address == "192.237.162.222"
  }[0]
end

#check the Fog::Rackspace::BlockStorage::Volumes to find an existing volume by name
def match_existing_volume
  @current_resource.exists = false
  cbs.volumes.each do |volume|
    if @current_resource.name == volume.display_name
      @current_resource.exists = true
      @current_resource.volume_id(volume.id)
      break
    end
  end
end

#Check the Fog::Compute::RackspaceV2::Server Attachments to see if the volume is alreay attached.
#If not attached to this server
def match_existing_attachment
  @current_resource.attached = false
  @current_resource.server.attachments.each do |attachment|
    #if the server attachment matches the volume, 
    #it is already attached to the server
    if attachment.volume_id == @current_resource.volume_id
      @current_resource.attached = true
      @current_resource.device = attachment.device
    end
  end
  
end

#Create a Cloud Block Storage volume
def create_volume
  #the volume_id parameter is only valid for attaching nodes, not for creating
  raise "Cannot create a volume with a specific id (CBS chooses volume ids)" if @new_resource.volume_id
  #create the new volume and return the volume_id
  volume = cbs.volumes.create(
      :size => @new_resource.size,
      :display_name => @new_resource.name,
      :volume_type => @new_resource.type
  )
  Chef::Log.info(
    "Cloud Block Storage volume '#{volume.display_name}' created with volume_id: #{volume.id}")
  @current_resource.volume_id(volume.id)
end

#Attach a Cloud Block Storage volume to the current server
def attach_volume
  #check the Fog::Rackspace::BlockStorage::Volume Attachments to make sure the
  #volume is not attached to another server
  unless @new_resource.volume_id.nil?
    volume = cbs.volumes.get(@new_resource.volume_id)
  else
    volume = cbs.volumes.get(@current_resource.volume_id)
  end
  unless volume.attachments.empty?
    raise "Volume with id #{volume.id} exists but is attached to a different cloud server"
  end
  
  Chef::Log.info("Attaching volume #{volume.id} to server #{@current_resource.server.id}")
  #attach the volume and wait until the volume status shows 'IN-USE'
  attachment = @current_resource.server.attach_volume(volume.id)
  volume.wait_for(600)  do
    volume.attached?
  end
  @current_resource.attached = true
  @current_resource.device = attachment.device
end

#update node attributes to contain data for all attached volumes
def update_node_data
  Chef::Log.info("updating node[:rackspacecloud][:cbs][:attached_volumes] with volume attachment information")
  server_attachments =  (compute.list_attachments(@current_resource.server.id)).body["volumeAttachments"]
  server_attachments.collect!{|attachment| attachment["volumeId"]}
  attached_volumes = []
  server_attachments.each do |volume_id|
    volume = cbs.volumes.get(volume_id)
    attached_volumes << {
        :volume_id => volume.id,
        :type => volume.volume_type,
        :size => volume.size
    }
  end
  node.set[:rackspacecloud][:cbs][:attached_volumes] = attached_volumes 
  Chef::Log.info(attached_volumes) 
end
