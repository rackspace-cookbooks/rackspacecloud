Description
===========
This cookbook provides libraries, resources and providers to configure and manage Rackspace Cloud objects using the Rackspace Cloud API.

Currently supported resources:

* Rackspace Cloud DNS ( rackspacecloud_record )
* Rackspace Cloud Files ( rackspacecloud_file )

Coming soon:

* Rackspace Cloud Load Balancers
* Rackspace Cloud Database
* Rackspace Cloud Block Storage
* Rackspace Cloud Servers

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

Retrieves files from Rackspace Cloud Files. Example:

```ruby
rackspacecloud_file "/usr/share/tomcat5/webapps/demo.war" do
  directory "wars"
  rackspace_username "foo"
  rackspace_api_key "nnnnnnnnnnn"
  action :create
end
```

### Attributes:
* ```directory```: The directory on Rackspace Cloud Files where the file can be found.
* ```rackspace_username```: The Rackspace API username. Can be retrieved from data bag or node attributes.
* ```rackspace_api_key```: The Rackspace API key. Can be retrieved from data bag or node attributes.
* ```action```: ```:create``` or ```:create_if_missing```. Default is ```:create```.

rackspacecloud_lbaas
-------------------

Adds and removes nodes from specified load balancer. Example:

```ruby
rackspacecloud_lbaas "loadBalancerIdGoesHere" do
	action :add_node
	rackspace_username "userName"
	rackspace_api_key "apiKey"
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
* ```action```: ```:add_node``` or ```:remove_node```. Default is ```:add_node```.

License and Author
==================

Author:: Ryan Walker (<ryan.walker@rackspace.com>)
Author:: Julian Dunn (<jdunn@opscode.com>)
Author:: Zack Feldstein (<zack.feldstein@rackspace.com>)


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
