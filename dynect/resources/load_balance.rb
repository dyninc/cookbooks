actions :get, :add_ip, :remove_ip

attribute :customer_name, :kind_of => String
attribute :user_name, :kind_of => String
attribute :password, :kind_of => String
attribute :token, :kind_of => String
attribute :uri, :default => 'https://api2.dynect.net/REST'

attribute :zone, :kind_of => String, :required => true
attribute :fqdn, :kind_of => String
attribute :ip
