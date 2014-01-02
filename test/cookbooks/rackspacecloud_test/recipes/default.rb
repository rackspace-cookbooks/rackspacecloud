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


##Cloud Block Storage##

#create a volume (by name only)
rackspacecloud_cbs "test-cbs-00" do
  type "SATA"
  size 100
  rackspace_username "foo"
  rackspace_api_key "nnnnnnnnnnn"
  rackspace_region "ord"
  action :create_volume
end

#attach a volume by name
rackspacecloud_cbs "test-cbs-00" do
  rackspace_username "foo"
  rackspace_api_key "nnnnnnnnnnn"
  rackspace_region "ord"
  action :attach_volume
end

#attach a volume by volume_id
rackspacecloud_cbs "test-cbs-02" do
  volume_id "856bb7d1-e9ea-4f5e-967f-f70c5edd962e"
  rackspace_username "foo"
  rackspace_api_key "nnnnnnnnnnn"
  rackspace_region "ord"
  action :attach_volume
end

#create and attach a volume (by name only)
rackspacecloud_cbs "test-cbs-01" do
  type "SATA"
  size 100
  rackspace_username "foo"
  rackspace_api_key "nnnnnnnnnnn"
  rackspace_region "ord"
  action :create_and_attach
end


#create and attach a volume (by name only)
rackspacecloud_cbs "test-cbs-03" do
  type "SATA"
  size 100
  rackspace_username "foo"
  rackspace_api_key "nnnnnnnnnnn"
  rackspace_region "ord"
  action :create_and_attach
end

#detach volume by name
rackspacecloud_cbs "test-cbs-00" do
  rackspace_username "foo"
  rackspace_api_key "nnnnnnnnnnn"
  rackspace_region "ord"
  action :detach_volume
end

#detach volume by volume_id
rackspacecloud_cbs "cbs-test-02" do
  volume_id "856bb7d1-e9ea-4f5e-967f-f70c5edd962e"
  rackspace_username "foo"
  rackspace_api_key "nnnnnnnnnnn"
  rackspace_region "ord"
  action :detach_volume
end

#delete volume by name
rackspacecloud_cbs "test-cbs-00" do
  rackspace_username "foo"
  rackspace_api_key "nnnnnnnnnnn"
  rackspace_region "ord"
  action :delete_volume
end

#delete volume by volume_id
rackspacecloud_cbs "test-cbs-00" do
  volume_id "149b759b-c085-4e98-bd43-d2f2c5f71920"
  rackspace_username "foo"
  rackspace_api_key "nnnnnnnnnnn"
  rackspace_region "ord"
  action :delete_volume
end

#detach and delete volume
rackspacecloud_cbs "test-cbs-01" do
  rackspace_username "foo"
  rackspace_api_key "nnnnnnnnnnn"
  rackspace_region "ord"
  action :detach_and_delete
end

#create and attach a volume (by name only)
rackspacecloud_cbs "test-cbs-03" do
  volume_id "383e4c4b-76ea-4ae2-861d-24e9d4fdaf53"
  type "SATA"
  size 100
  rackspace_username "foo"
  rackspace_api_key "nnnnnnnnnnn"
  rackspace_region "ord"
  action :detach_and_delete
end