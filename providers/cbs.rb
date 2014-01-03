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
#indcating whether the volume already exists and if the volume is 
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
    #the volume_id parameter is only valid for attaching nodes, not for creating
    raise "Cannot create a volume with a specific id (CBS chooses volume ids)" if @new_resource.volume_id
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
  converge_by("Attaching cloud block storage volume to node") do
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
  converge_by("Creating cloud block storage volume and attaching to node") do
    #the volume_id parameter is only valid for attaching nodes, not for creating
    raise "Cannot create a volume with a specific id (CBS chooses volume ids)" if @new_resource.volume_id
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

action :detach_volume do
  converge_by("Detaching cloud block storage volume form server") do
    if @current_resource.attached
      detach_volume()
      @new_resource.updated_by_last_action(true)
    else
      Chef::Log.info(
        "Cloud Block Storage volume '#{@current_resource.name}' not attached, no action taken")
    end
    update_node_data
  end
end

action :delete_volume do
  converge_by("Deleting cloud block storage volume") do
    if @current_resource.exists
      delete_volume()
      @new_resource.updated_by_last_action(true)
    else
      Chef::Log.info(
        "Cloud Block Storage volume '#{@current_resource.name}' does not exist, no action taken")
    end
    update_node_data
  end
end

action :detach_and_delete do
  converge_by("detaching cloud block storage volume from node and deleting volume") do
    if @current_resource.attached
      detach_volume()
    else
      Chef::Log.info(
        "Cloud Block Storage volume '#{@current_resource.name}' not attached, no action taken")
    end
    if @current_resource.exists
      delete_volume()
      @new_resource.updated_by_last_action(true)
    else
      Chef::Log.info(
        "Cloud Block Storage volume '#{@current_resource.name}' does not exist, no action taken")
    end
    update_node_data
  end
end

private

#locate the Fog::Compute::RackspaceV2::Server by shelling out 
#and reading the id from xenstore
def locate_server
  server_id = `xenstore-read name`.sub("instance-","").strip
  Chef::Log.info("Node matched to compute server #{server_id}")
  server = compute.servers.get(server_id)
  raise "unable to locate server in compute API" if server.nil?
  server
end

#Match the recource by searching Fog::Rackspace::BlockStorage::Volumes
#If the volume_id was given, attempt to match volume by volume_id, 
#otherwise search volumes by name
def match_existing_volume
  @current_resource.exists = false 
  unless @new_resource.volume_id.nil?
    volume = cbs.volumes.get(@new_resource.volume_id)
    raise "volume with id #{@new_resource.volume_id} could not be found" if volume.nil?
    @current_resource.exists = true
    @current_resource.volume_id(volume.id)
  else
    cbs.volumes.each do |volume|
      if @current_resource.name == volume.display_name
        @current_resource.exists = true
        @current_resource.volume_id(volume.id)
        break
      end
    end
  end 
end

#Check the Fog::Compute::RackspaceV2::Server Attachments to see 
#if the volume is alreay attached.
def match_existing_attachment
  @current_resource.attached = false
  @current_resource.server.attachments.each do |attachment|
    #if the server attachment matches the volume, 
    #it is already attached to the server
    if attachment.volume_id == @current_resource.volume_id
      @current_resource.attached = true
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
  
  #attach the volume and poll until the volume status shows 'IN-USE'
  attachment = @current_resource.server.attach_volume(volume.id)
  volume.wait_for(600)  do
    volume.attached?
  end
  #update the status of the resource
  @current_resource.attached = true
  Chef::Log.info("Volume #{volume.id} attached at device #{attachment.device}")
end

#detach a Cloud Block Storage volume from the current server
def detach_volume
  #check the Fog::Rackspace::BlockStorage::Volume Attachments to make sure the
  #volume is not attached to another server
  unless @new_resource.volume_id.nil?
    volume = cbs.volumes.get(@new_resource.volume_id)
  else
    volume = cbs.volumes.get(@current_resource.volume_id)
  end
  attached_servers = volume.attachments.collect{|attachment| attachment["server_id"]}
  unless attached_servers.include? @current_resource.server.id 
    raise "Volume with id #{volume.id} exists but is attached to a different cloud server"
  end
  
  Chef::Log.info("Detaching volume #{volume.id} from server #{@current_resource.server.id}")
  #attach the volume and wait until the volume status shows 'IN-USE'
  compute.delete_attachment(@current_resource.server.id,volume.id)
  volume.wait_for(600)  do
    volume.ready?
  end
  @current_resource.attached = false
end

#Delete a Cloud Block Storage volume
def delete_volume
  #check the Fog::Rackspace::BlockStorage::Volume Attachments to make sure the
  #volume is not attached to another server
  unless @new_resource.volume_id.nil?
    volume = cbs.volumes.get(@new_resource.volume_id)
  else
    volume = cbs.volumes.get(@current_resource.volume_id)
  end
  unless volume.attachments.empty?
    raise "Volume #{volume.id} can not be deleted because it has active attachments"
  end
  
  Chef::Log.info("Deleting volume #{volume.id}")
  #attach the volume and wait until the volume status shows 'IN-USE'
  volume.destroy
  @current_resource.exists = false
end

#update node attributes to contain data for all volumes attached to this server
def update_node_data
  Chef::Log.info("updating node[:rackspacecloud][:cbs][:attached_volumes] with volume attachment information")
  server_attachments =  (compute.list_attachments(@current_resource.server.id)).body["volumeAttachments"]
  attached_volumes = []
  server_attachments.each do |attachment|
    volume = cbs.volumes.get(attachment["volumeId"])
    attached_volumes << {
        :volume_id => volume.id,
        :display_name => volume.display_name,
        :volume_type => volume.volume_type,
        :size => volume.size,
        :device => attachment["device"]
    }
  end
  node.set[:rackspacecloud][:cbs][:attached_volumes] = attached_volumes 
  Chef::Log.info(attached_volumes) 
end
