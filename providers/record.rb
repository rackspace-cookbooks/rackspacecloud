include Opscode::Rackspace::DNS

action :add do

  zone = get_zone(new_resource.name)
  ### Check if record already exists ###
  existing_record = record_exists?(zone)
  if existing_record
    raise "Record #{new_resource.record} already exists for #{new_resource.name}. Use 'action :update' to add or update if exists."
  else
    begin
      zone.records.create(:name => new_resource.record, :value => new_resource.value, :type => new_resource.type, :ttl => new_resource.ttl)
    rescue Fog::DNS::Rackspace::CallbackError => error
      raise "Could not create DNS record: #{error}"
    rescue Fog::Rackspace::Errors::BadRequest => error
      raise "There was a problem with the Create DNS Record request: #{error}"
    end
    Chef::Log.info "#{new_resource.type} record created for #{new_resource.name}: #{new_resource.record} => #{new_resource.value}"
  end

end

action :update do

  zone = get_zone(new_resource.name)
  existing_record = record_exists?(zone)
  if existing_record
    record = zone.records.get(existing_record)
    if record.type != new_resource.type
      Chef::Log.info("Record #{record.name} is type #{record.type}. It cannot be changed to type #{new_resource.type}. Skipping...")
    elsif record.name and new_resource.record and record.value == new_resource.value and record.ttl == new_resource.ttl
      Chef::Log.info("Record #{record.name} is unchanged. Skipping...")
    else
      Chef::Log.info("Record #{new_resource.record} already exists for domain #{new_resource.name}. Updating record.")
      record.name = new_resource.record
      record.value = new_resource.value
      record.ttl = new_resource.ttl
      begin
        record.save
      rescue Fog::DNS::Rackspace::CallbackError => error
        raise "Could not update DNS record: #{error}"
      rescue Fog::Rackspace::Errors::BadRequest => error
        raise "There was a problem updating the Create DNS record: #{error}"
      end
      Chef::Log.info "#{new_resource.type} record updated for #{new_resource.name}: #{new_resource.record} => #{new_resource.value}"
    end
  else
    Chef::Log.info("Record #{new_resource.record} does not exist for domain #{new_resource.name}. Adding new record.")
    begin
      zone.records.create(:name => new_resource.record, :value => new_resource.value, :type => new_resource.type, :ttl => new_resource.ttl)
    rescue Fog::DNS::Rackspace::CallbackError => error
      raise "Could not create DNS record: #{error}"
    rescue Fog::Rackspace::Errors::BadRequest => error
      raise "There was a problem with the Create DNS Record request: #{error}"
    end
    Chef::Log.info "#{new_resource.type} record created for #{new_resource.name}: #{new_resource.record} => #{new_resource.value}"
  end
end

private

def get_zone(name=nil)
  ### Search DNS Zones for provided domain ###
  zone_id = nil
  dns.zones.each do |zone|
    if zone.domain == name
      zone_id = zone.id
    end
  end

  if zone_id.nil?
    raise "Domain #{new_resource.name} does not exist."
  end

  zone = dns.zones.get(zone_id)
  return zone
end

def record_exists?(zone=nil)
  zone.records.all.each do |record|
    if record.name == new_resource.record
      return record.id
    end 
  end
  return false
end
