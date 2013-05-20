
node[:rackspace][:packages].each do |pkg|
  r = package pkg do
    action :nothing
  end
  r.run_action(:install)
end

chef_gem "fog" do
  version node[:rackspace][:fog_version]
  action :install
end

require 'fog'
