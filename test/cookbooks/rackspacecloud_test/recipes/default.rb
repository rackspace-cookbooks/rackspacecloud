include_recipe "rackspacecloud"
require 'fog'
Fog.mock!

rackspacecloud_record "chef.rackspace.com" do
  record "n02.chef.rackspace.com"
  value "10.1.2.3"
  type "A"
  ttl 300
  rackspace_username "foo"
  rackspace_api_key "nnnnnnnnnnn"
  action :add
end

rackspacecloud_record "chef.rackspace.com" do
  record "n02.chef.rackspace.com"
  value "10.1.2.4"
  type "A"
  ttl 300
  rackspace_username "foo"
  rackspace_api_key "nnnnnnnnnnn"
  action :update
end

rackspacecloud_record "chef.rackspace.com" do
  record "n02.chef.rackspace.com"
  value "10.1.2.5"
  type "A"
  ttl 300
  rackspace_username "foo"
  rackspace_api_key "nnnnnnnnnnn"
  action :delete
end
