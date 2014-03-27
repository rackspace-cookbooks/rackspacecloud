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
  lb = get_lb
  if lb
    @current_resource.lb = lb
    @current_resource.nodes = get_nodes
    @current_resource.node = get_node
  else
    @current_resource
  end
end

def check_node_exists
  if @current_resource.lb && !@current_resource.nodes.empty?
    @current_resource.nodes.map {|node| true if node.address == @new_resource.node_address}
  end
end

def get_lb
  begin
    lb = lbaas.load_balancers.get(new_resource.load_balancer_id)
  rescue Fog::Rackspace::LoadBalancers::NotFound
    raise "Load balancer ID specified does not exist, please create load balancer and provide a valid ID"
  end
  return lb
end

def get_node
  if @current_resource.lb && !@current_resource.nodes.empty?
    if check_node_exists
      node = @current_resource.nodes.map {|node| node.id if node.address == @new_resource.node_address}
      return @current_resource.nodes.get(node[0])
    end
  end
end

def get_nodes
  if @current_resource.lb
    @current_resource.lb.nodes
  end
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

#add node to LB if it doesnt exist
action :add_node do
  unless check_node_exists
    converge_by("Adding node to cloud load balancer #{new_resource.load_balancer_id}" ) do
      add_node
    end
  end
end

action :remove_node do
  if check_node_exists
    converge_by("Removing Node from cloud load balancer #{new_resource.load_balancer_id}") do
      node_id = @current_resource.node.id
      remove_node(node_id) if node_id
    end
  end
end
