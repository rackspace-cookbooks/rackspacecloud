module Opscode
  module Rackspace

      def initialize(name, run_context=nil)
        super
        begin
          require 'fog'
        rescue LoadError
          Chef::Log.error("Missing gem 'fog'. Use the default rackspace recipe to install it first.")
        end

	get_credentials
     end

     def get_credentials
       begin
         if Chef::DataBag.list.keys.include?("rackspace") && data_bag("rackspace").include?("cloud")
           creds = Chef::EncryptedDataBagItem.load("rackspace", "cloud")
         end
       rescue
         Chef::Log.info("No Rackspace Cloud databag found. Using attributes for credentials.")
       end
 
       @apikey = creds['rackspace_api_key'] rescue node[:rackspace][:rackspace_api_key]
       @username = creds['rackspace_username'] rescue node[:rackspace][:rackspace_username]
       @auth_url = creds['rackspace_auth_url'] rescue node[:rackspace][:rackspace_auth_url]
       @region = creds['rackspace_auth_region'] rescue node[:rackspace][:rackspace_auth_reqion]
     end

  end
end
