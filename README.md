Description
===========
This cookbook provides LWRP's to interact with Rackspace Cloud APIs.

Supports
========
* Rackspace Cloud DNS
* Rackspace Cloud Load Balancers (Coming Soon)
* Rackspace Cloud Database (Coming Soon)
* Rackspace Cloud Block Storage (Coming Soon)
* Rackspace Cloud Servers (Coming Soon)

Usage
=====
### Data Bags
It is highly encouraged that you use an encrypted data bag to provide your Rackspace Cloud username and API key. To do so, make a data bag called ```rackspace``` with an item called ```cloud``` that has at least the following:

```json
{
  "id":"cloud",
  "rackspace_username": "<RACKSPACE_USERNAME>",
  "rackspace_api_key": "<RACKSPACE_APIKEY>"
}
```

You may choose to provide your ```rackspace_auth_url``` and ```rackspace_auth_region``` in the data bag as well, but they can generally be safely provided as attributes.

LWRPs
=====
## rackspace_record:
Provides add, modify, remove functionality for Rackspace Cloud DNS records. Example:

Add an A record:

```ruby
rackspace_record "chef.rackspace.com" do
  record "n02.chef.rackspace.com"
  value "10.1.2.3"
  type "A"
  ttl 300
  action :add
end
```
Add a CNAME:

```ruby
rackspace_record "chef.rackspace.com" do
  record "n02.chef.rackspace.com"
  value "api.chef.rackspace.com"
  type "CNAME"
  ttl 300
  action :add
end
```
### Attributes:
* ```record```: The name of the record being created/deleted/modified.
* ```value```: The value to set the record to.
* ```type```: The type of record to create. Default is ```A```.
* ```ttl```: The TTL for the record. Default is ```300```.