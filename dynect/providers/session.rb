require 'net/https'
require 'uri'
require 'json'

action :login do
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
end


action :logout do

end
