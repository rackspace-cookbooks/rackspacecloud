module Opscode
  module Rackspace
    module DNS

      include Opscode::Rackspace

      def dns
        @@dns ||= Fog::DNS.new({:provider => "Rackspace", :rackspace_username => @username, :rackspace_api_key => @apikey, :rackspace_auth_url => @auth_url})
      end

    end
  end
end
