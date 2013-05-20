include Opscode::Rackspace::DNS

action :add do

  ### Search DNS Zones for provided domain ###
  zone_id = nil
  dns.zones.each do |zone|
    if zone.domain == new_resource.name
      zone_id = zone.id
    end
  end
      
  if zone_id.nil?
    raise "Domain #{new_resource.name} does not exist."
  end

  zone = dns.zones.get(zone_id)

  begin
    zone.records.create(:name => new_resource.record, :value => new_resource.value, :type => new_resource.type, :ttl => new_resource.ttl)
  rescue Fog::DNS::Rackspace::CallbackError => error
    raise "Could not create DNS record: #{error}"
  rescue Fog::Rackspace::Errors::BadRequest => error
    raise "There was a problem with the Create DNS Record request: #{error}"
  end

  Chef::Log.info "#{new_resource.type} record created for #{new_resource.name}: #{new_resource.record} => #{new_resource.value}"

end
