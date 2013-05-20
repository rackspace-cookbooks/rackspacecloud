actions :add, :delete, :update
default_action :add

attribute :name, :name_attribute => true, :kind_of => String, :required => true
attribute :record, :kind_of => String, :required => true
attribute :value, :kind_of => String, :required => true
attribute :type, :kind_of => String, :default => "A"
attribute :ttl, :kind_of => Integer, :default => 300
