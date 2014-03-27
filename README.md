Description
===========
This cookbook provides libraries, resources and providers to configure and manage Rackspace Cloud objects using the Rackspace Cloud API.

Currently supported resources:

* Rackspace Cloud DNS ( rackspacecloud_record )
* Rackspace Cloud Files ( rackspacecloud_file )
* Rackspace Cloud Block storage ( rackspacecloud_cbs )
* Rackspace Cloud Load Balancers ( rackspacecloud_lbaas)

Coming soon:

* Rackspace Cloud Database
* Rackspace Cloud Servers

Not Included:

* Rackspace Cloud Monitoring: See [cookbook-cloudmonitoring](https://github.com/rackspace-cookbooks/cookbook-cloudmonitoring)

Requirements
============

Requires Chef 0.7.10 or higher for Lightweight Resource and Provider support. Chef 0.8+ is recommended. While this cookbook can be used in chef-solo mode, to gain the most flexibility, we recommend using chef-client with a Chef Server.

A Rackspace Cloud account is required. The username and API key are used to authenticate with Rackspace Cloud.

Rackspace Credentials
=====================

In order to manage Rackspace Cloud components, authentication credentials need to be available to the node. There are a number of ways to handle this, such as node attributes or roles. We recommend storing these in a databag item (Chef 0.8+), and loading them in the recipe where the resources are needed. To do so, make a data bag called ```rackspace``` with an item called ```cloud``` that has at least the following:

```json
{
  "id":"cloud",
  "rackspace_username": "<RACKSPACE_USERNAME>",
  "rackspace_api_key": "<RACKSPACE_APIKEY>"
}
```

You may choose to provide your ```rackspace_auth_url``` and ```rackspace_auth_region``` in the data bag item as well, but they can generally be safely provided as attributes.

The values can be loaded in a recipe with:

```ruby
rackspace = data_bag_item("rackspace", "cloud")
```

And to access the values:

```ruby
rackspace['rackspace_username']
rackspace['rackspace_api_key']
```

The data bag items can also be encrypted for extra security.

Recipes
=======

default.rb
----------

The default recipe installs the ```fog``` RubyGem, which this cookbook requires in order to work with the Rackspace API. Make sure that the default recipe is in the node or role ```run_list``` before any resources from this cookbook are used.

"run_list": [
  "recipe[rackspacecloud]"
]

The ```gem_package``` is created as a Ruby Object and thus installed during the compile phase of the Chef run.

Libraries
=========

The cookbook has several library modules which can be included where necessary:

```ruby
Opscode::Rackspace
Opscode::Rackspace::BlockStorage
Opscode::Rackspace::DNS
Opscode::Rackspace::Storage
```

Resources and Providers
=======================

This cookbook provides several resources and corresponding providers.

rackspacecloud_record
---------------------

Provides add, modify, remove functionality for Rackspace Cloud DNS records. Example:

Add an A record:

```ruby
rackspacecloud_record "chef.rackspace.com" do
  record "n02.chef.rackspace.com"
  value "10.1.2.3"
  type "A"
  ttl 300
  rackspace_username "foo"
  rackspace_api_key "nnnnnnnnnnn"
  action :add
end
```
Add a CNAME:

```ruby
rackspacecloud_record "chef.rackspace.com" do
  record "n02.chef.rackspace.com"
  value "api.chef.rackspace.com"
  type "CNAME"
  ttl 300
  rackspace_username "foo"
  rackspace_api_key "nnnnnnnnnnn"
  action :add
end
```
Update a record:

```ruby
rackspacecloud_record "chef.rackspace.com" do
  record "n02.chef.rackspace.com"
  value "10.1.2.4"
  type "A"
  ttl 300
  rackspace_username "foo"
  rackspace_api_key "nnnnnnnnnnn"
  action :update
end
```

### Attributes:
* ```record```: The name of the record being created/deleted/modified.
* ```value```: The value to set the record to.
* ```type```: The type of record to create. Default is ```A```.
* ```ttl```: The TTL for the record. Default is ```300```.
* ```rackspace_username```: The Rackspace API username. Can be retrieved from data bag or node attributes.
* ```rackspace_api_key```: The Rackspace API key. Can be retrieved from data bag or node attributes.
* ```action```: ```:add```, ```:delete```, ```:update```. Default is ```:add```.

rackspacecloud_file
-------------------

Retrieves/Stores files from/to Rackspace Cloud Files. Example:

```ruby
rackspacecloud_file "/usr/share/tomcat5/webapps/demo.war" do
  directory "wars"
  rackspace_username "foo"
  rackspace_api_key "nnnnnnnnnnn"
  rackspace_region "ORD"
  binmode true
  action :create
end
```

```ruby
rackspacecloud_file "/usr/share/tomcat5/webapps/demo.war" do
  directory "wars"
  rackspace_username "foo"
  rackspace_api_key "nnnnnnnnnnn"
  rackspace_region "ORD"
  binmode true
  action :upload
end
```

### Attributes:
* ```directory```: The directory on Rackspace Cloud Files where the file can be found or should be uploaded to.
* ```rackspace_username```: The Rackspace API username. Can be retrieved from data bag or node attributes.
* ```rackspace_api_key```: The Rackspace API key. Can be retrieved from data bag or node attributes.
* ```rackspace_region```: The Rackspace Cloud Files region (ORD, DFW, HKG, IAD, etc.)
* ```binmode```: ```true``` or ```false```. Default is ```false```. Setting this to ```true``` will download the file in binary mode.
* ```action```: ```:create```, ```:create_if_missing```, ```:upload```. Default is ```:create```.

rackspacecloud_lbaas
-------------------

Adds and removes nodes from specified load balancer. Example:

```ruby
rackspacecloud_lbaas "loadBalancerIdGoesHere" do
  action :add_node
  rackspace_username "userName"
  rackspace_api_key "apiKey"
  rackspace_region "ORD"
  node_address node[:rackspace][:local_ipv4]
end
```

### Attributes:
* ```load_balancer_id```: Id of the load balancer to add/remove nodes on.
* ```port```: Port the load balancer will route traffic to. (default is 80)
* ```node_address```: The IP address of the node you are adding or removing
* ```condition```: Either ENABLED or DISABLED (default is enabled)
* ```rackspace_username```: The Rackspace API username. Can be retrieved from data bag or node attributes.
* ```rackspace_api_key```: The Rackspace API key. Can be retrieved from data bag or node attributes.
* ```rackspace_region```: Region for load balancer (ORD, DFW, HKG, IAD, etc.)
* ```action```: ```:add_node``` or ```:remove_node```. Default is ```:add_node```.


rackspacecloud_cbs
---------------------

Provides functionality to manage storage volumes and server attachments for Rackspace Cloud Block Storage including creating, attaching, detaching and deleting volumes.  All actions performed are idempotent.

### Actions:

```:create_volume``` - Creates a new storage volume with the given name.  If a volume with the given name exists no action will be taken.  This action does not accept volume_id as a parameter.

```:attach_volume``` - Attaches an existing storage volume to the current node.  If the volume is already attached no action will be taken.  If the volme is attached to another server, an exception will be raised. The volumes may be attached by name or by volume_id.

```:create_and_attach``` - The default action.  Combines create_volume and attach_volume into one action.  This action does not accept volume_id as a parameter.

```:detach_volume``` - Detaches a volume from an existing server.  If the given volume is not attached no action is performed.  If the volume is attached to another server, an exception will be raised.  The volume may be detached by name or volume_id.

```:delete_volume``` - Deletes an existing storage volume.  A volume must be detached in order to be deleted.  If the given volume does not exist no action will be taken.  The volume may be identified by name or volume_id.

```:detach_and_delete``` - Combines detach_volume and delete_volume into a single action.  Volume may be identified by name or volume_id.

### Examples:

Create and attach a 100GB SSD storage volume:

```ruby
rackspacecloud_cbs "myvolume-01" do
  type "SSD"
  size 100
  rackspace_username "userName"
  rackspace_api_key "apiKey"
  rackspace_region "ord"
  action :create_and_attach
end
```

Create a 200GB SATA volume:

```ruby
rackspacecloud_cbs "myvolume-02" do
  type "SATA"
  size 200
  rackspace_username "userName"
  rackspace_api_key "apiKey"
  rackspace_region "ord"
  action :create_volume
end
```

Attach a volume by volume_id:

```ruby
rackspacecloud_cbs "myvolume-02" do
  volume_id "74fe8714-fd92-4d07-a6a2-ddd15ed09f79"
  rackspace_username "userName"
  rackspace_api_key "apiKey"
  rackspace_region "ord"
  action :attach_volume
end
```

Detach a volume by name:

```ruby
rackspacecloud_cbs "myvolume-02" do  
  rackspace_username "userName"
  rackspace_api_key "apiKey"
  rackspace_region "ord"
  action :detach_volume
end
```

Detach and delete volume by id:

```ruby
rackspacecloud_cbs "myvolume-01" do
  volume_id "74fe8714-fd92-4d07-a6a2-ddd15ed09f79"
  rackspace_username "userName"
  rackspace_api_key "apiKey"
  rackspace_region "ord"
  action :detach_and_delete
end
```

### Node Attributes:

During the provider run, a node attribute is updated with a list of hashes describing the attached volumes.  The list of attached volumes is pulled from the compute and storage api so it will include all attached volumes whether created with this recipe or not.  The data is in the following format:

```ruby
node[:rackspacecloud][:cbs][:attached_volumes] = [
  {
    :device => '/dev/xvde',
    :size => 100,
    :volume_id => "4300a4b7-1b66-4d44-b18d-de1b3236b001",
    :display_name => "myvolume-01",
    :volume_type => "SSD"
  },
  {
    :device => "/dev/xvdb",
    :size => 200,
    :volume_id => "642a8a7b-cb31-479b-8e4c-0158a2be3519",
    :display_name => "myvolume-02",
    :volume_type => "SATA"
  }
]
```

### Example Recipe with LVM:

Below is an example of a simple recipe that creates 2 100GB cloud block storage volumes and uses LVM to create a logical volume group, format the filesystem, and mount at /var/log.  This example uses the [Opscode LVM recipe](https://github.com/opscode-cookbooks/lvm).

```ruby
include_recipe 'rackspacecloud'
include_recipe 'lvm'

rackspace = data_bag_item("rackspace", "cloud")
rackspace_username = rackspace["rackspace_username"]
rackspace_api_key = rackspace["rackspace_api_key"]

(1..2).each do |vol_number|
  rackspacecloud_cbs "#{node[:hostname]}-#{vol_number}" do
    type "SATA"
    size 100
    rackspace_username rackspace_username
    rackspace_api_key rackspace_api_key
    rackspace_region "#{node[:rackspace][:cloud][:region]}"
    action :create_and_attach
  end
end

#use lazy attribute evaluation to get attachment data at execution time
lvm_volume_group 'vg00' do
  not_if {node[:rackspacecloud][:cbs][:attached_volumes].empty? }
  physical_volumes lazy {node[:rackspacecloud][:cbs][:attached_volumes].collect{|attachment| attachment["device"]}}
  logical_volume 'blockstorage' do
    size        '100%VG'
    filesystem  'ext4'
    mount_point '/var/log'
  end
 end
```

### Attributes:
* ```name```: Name of the volume to perform operations with.
* ```volume_id```: The volume_id of the volume to attach, detach, or delete. This option is not valid for actions that create volumes.
* ```type```: The type of storage device, either [SSD, SATA]. Default is SATA.
* ```size```: The size in GB of strage device.  Default is 100.
* ```rackspace_username```: The Rackspace API username. Can be retrieved from data bag or node attributes.
* ```rackspace_api_key```: The Rackspace API key. Can be retrieved from data bag or node attributes.
* ```action```: ```:create_volume```, ```:attach_volume```, ```:create_and_attach```, ```:detach_volume```, ```:delete_volume```, ```:detach_and_delete```. Default is ```:create_and_attach```.


License and Author
==================

Author:: Ryan Walker (<ryan.walker@rackspace.com>)
Author:: Julian Dunn (<jdunn@opscode.com>)
Author:: Michael Goetz (<mpgoetz@opscode.com>)
Author:: Zack Feldstein (<zack.feldstein@rackspace.com>)
Author:: Steven Gonzales (<steven.gonzales@rackspace.com>)


Copyright 2013, Rackspace Hosting
Copyright 2013, Opscode, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
