module Opscode
  module Rackspace
    module DNS

      include Opscode::Rackspace

      def get_zone_id(domain="")
        id = nil
        dns.zones.each do |zone|
          if zone.domain == domain
            id = zone.id
          end
        end
        return id
      end

      def get_zone(zone_id="")
        zone = dns.zones.get(zone)
        return zone
      end

      def create_record(zone="", record="", value="", type="A", ttl=300)
        record = zone.records.create(:type => type, :name => record, :value => value, :ttl => ttl)
        return record
      end

      def dns
        @@dns ||= Fog::DNS.new({:provider => "Rackspace", :rackspace_username => @username, :rackspace_api_key => @apikey, :rackspace_auth_url => @auth_url})
      end

    end
  end
end
