#
# Cookbook Name:: rackspacecloud
# Provider:: lbaas
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

include Opscode::Rackspace::LoadBalancers

def whyrun_supported?
  true
end

def load_current_resource
  @current_resource = Chef::Resource::RackspacecloudLbaas.new(@new_resource.name)
  lb_exists = nil
  lb_action{|lb_details| lb_exists = lb_details }
  if lb_exists
    @current_resource.exists = true
  else
    @current_resource.exists = false
  end
  @current_resource
end


def remove_node(node_id)
  begin
    lbaas.delete_node(new_resource.load_balancer_id, node_id)
  rescue Fog::Rackspace::LoadBalancers::NotFound 
    Chef::Log.info "Node does not belong to specified load balancer ID"
  rescue Fog::Rackspace::LoadBalancers::ServiceError => e
    raise "An error occurred removing node from load balancer #{e}"
  else
    Chef::Log.info "Node has been removed from load balancer pool"
  end
end

def add_node
  begin
    #add the node
    create_response = lbaas.create_node(new_resource.load_balancer_id, new_resource.node_address, new_resource.port, new_resource.condition)
  rescue Fog::Rackspace::LoadBalancers::ServiceError => e
    raise "An error occured making the create node request: #{e}"
  end
  Chef::Log.info "Node successfully added to cloud loadbalancer"
end

def lb_action(&block)
  begin
    lb_details = lbaas.get_load_balancer(new_resource.load_balancer_id)
  rescue Fog::Rackspace::LoadBalancers::NotFound
    raise "Load balancer ID specified does not exist, please create load balancer and provide a valid ID"
  end
  yield lb_details.body['loadBalancer']
end

#add node to LB if it doesnt exist
action :add_node do
  converge_by("Adding node to cloud load balancer #{new_resource.load_balancer_id}" ) do
    #Check if LB exists
    lb_action{|lb_details|
      add_node if not lb_details['nodes'].nil? {|node_data| (node_data['address'] == new_resource.node_address) }
    }
    end
end


action :remove_node do
  converge_by("Removing Node from cloud load balancer #{new_resource.load_balancer_id}") do
    lb_action{|lb_details|
      #Find Node id and remove it
      node_id = lb_details['nodes'].select{|node_data| node_data['address'] == new_resource.node_address}.map {|node_id| node_id['id']}.first
      remove_node(node_id) if node_id 
    }
  end
end

