require 'net/https'
require 'uri'
require 'json'

action :get do
# Set up our HTTP object with the required host and path
  api_host = new_resource.uri
  url = URI.parse("#{api_host}/Session/")
  headers = { "Content-Type" => 'application/json' }
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  
  # Login and get an authentication token that will be used for all subsequent requests.  
  session_data = { :customer_name => new_resource.customer_name, :user_name => new_resource.user_name, :password => new_resource.password}  
  resp, data = http.post(url.path, session_data.to_json, headers)
  result = JSON.parse(data)
  
  if result['status'] == 'success'
    token = result['data']['token']
   else 
    puts "Command Failed:\n"
    # the messages returned from a failed command are a list
    result['msgs'][0].each{|key, value| print key, " : ", value, "\n"}
  end   

  # New headers to use from here on with the auth-token set
  headers = { "Content-Type" => 'application/json', 'Auth-Token' => token }

  # Get the current load balancer configuration
  ZONE = new_resource.zone
  FQDN = new_resource.fqdn
  url = URI.parse("#{api_host}/LoadBalance/#{ZONE}/#{FQDN}/")
  resp, data = http.get(url.path, headers)
  result = JSON.parse(data)

  if result['status'] == 'success'
    pool = result['data']['pool']
   else 
    puts "Command Failed:\n"
    # the messages returned from a failed command are a list
    result['msgs'][0].each{|key, value| print key, " : ", value, "\n"}
  end   

#  pool.each do |item|
#	puts "#{item['address']} : #{item['status']}"
#  end

  # Logout
  url = URI.parse("#{api_host}/Session/")
  resp, data = http.delete(url.path, headers)
end


action :add_ip do
# Set up our HTTP object with the required host and path
  api_host = new_resource.uri
  url = URI.parse("#{api_host}/Session/")
  headers = { "Content-Type" => 'application/json' }
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  
  # Login and get an authentication token that will be used for all subsequent requests.  
  session_data = { :customer_name => new_resource.customer_name, :user_name => new_resource.user_name, :password => new_resource.password}  
  resp, data = http.post(url.path, session_data.to_json, headers)
  result = JSON.parse(data)
  
  if result['status'] == 'success'
    token = result['data']['token']
   else 
    puts "Command Failed:\n"
    # the messages returned from a failed command are a list
    result['msgs'][0].each{|key, value| print key, " : ", value, "\n"}
  end   

  # New headers to use from here on with the auth-token set
  headers = { "Content-Type" => 'application/json', 'Auth-Token' => token }

  # Get the current load balancer configuration
  ZONE = new_resource.zone
  FQDN = new_resource.fqdn
  url = URI.parse("#{api_host}/LoadBalance/#{ZONE}/#{FQDN}/")
  resp, data = http.get(url.path, headers)
  result = JSON.parse(data)

  if result['status'] == 'success'
    pool = result['data']['pool']
   else 
    puts "Command Failed:\n"
    # the messages returned from a failed command are a list
    result['msgs'][0].each{|key, value| print key, " : ", value, "\n"}
  end   

  IP = new_resource.ip || node[:ipaddress]
  pool.each do |item|
    if item['address'] == IP
      print "Already in the IP pool\n"
      Process.exit
    end
  end

  # add the new ip to the pool
  pool << { 'address' => IP, } 

  # Update the LoadBalancer IP Pool
  url = URI.parse("#{api_host}/LoadBalance/#{ZONE}/#{FQDN}/")
  record_data = { :pool => pool }
  resp, data = http.put(url.path, record_data.to_json, headers)
  result = JSON.parse(data)
  unless result['status'] == 'success'
    puts "Command Failed:\n"
    # the messages returned from a failed command are a list
    result['msgs'][0].each{|key, value| print key, " : ", value, "\n"}
  end

  # Logout
  url = URI.parse("#{api_host}/Session/")
  resp, data = http.delete(url.path, headers)
end


action :remove_ip do
# Set up our HTTP object with the required host and path
  api_host = new_resource.uri
  url = URI.parse("#{api_host}/Session/")
  headers = { "Content-Type" => 'application/json' }
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  
  # Login and get an authentication token that will be used for all subsequent requests.  
  session_data = { :customer_name => new_resource.customer_name, :user_name => new_resource.user_name, :password => new_resource.password}  
  resp, data = http.post(url.path, session_data.to_json, headers)
  result = JSON.parse(data)
  
  if result['status'] == 'success'
    token = result['data']['token']
   else 
    puts "Command Failed:\n"
    # the messages returned from a failed command are a list
    result['msgs'][0].each{|key, value| print key, " : ", value, "\n"}
  end   

  # New headers to use from here on with the auth-token set
  headers = { "Content-Type" => 'application/json', 'Auth-Token' => token }

  # Get the current load balancer configuration
  ZONE = new_resource.zone
  FQDN = new_resource.fqdn
  url = URI.parse("#{api_host}/LoadBalance/#{ZONE}/#{FQDN}/")
  resp, data = http.get(url.path, headers)
  result = JSON.parse(data)

  if result['status'] == 'success'
    pool = result['data']['pool']
   else 
    puts "Command Failed:\n"
    # the messages returned from a failed command are a list
    result['msgs'][0].each{|key, value| print key, " : ", value, "\n"}
  end   

  IP = new_resource.ip || node[:ipaddress]
  pool.each do |item|
    if item['address'] == IP
		pool.delete(item)
    end
  end

  # Update the LoadBalancer IP Pool
  url = URI.parse("#{api_host}/LoadBalance/#{ZONE}/#{FQDN}/")
  record_data = { :pool => pool }
  resp, data = http.put(url.path, record_data.to_json, headers)
  result = JSON.parse(data)
  unless result['status'] == 'success'
    puts "Command Failed:\n"
    # the messages returned from a failed command are a list
    result['msgs'][0].each{|key, value| print key, " : ", value, "\n"}
  end

  # Logout
  url = URI.parse("#{api_host}/Session/")
  resp, data = http.delete(url.path, headers)
end
