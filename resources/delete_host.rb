actions :delete
default_action :delete

attribute :server_connection, :kind_of => Hash, :default => {}
attribute :hostname, :kind_of => String, :name_attribute => true
