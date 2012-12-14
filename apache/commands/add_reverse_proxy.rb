description 'adds a name-based vhost that acts as reverse proxy (forwarding incoming traffic to a remote backend)'

param :machine
param "server_name", "the http domain served by this vhost", { :mandatory => true, :allows_multiple_values => true }
param "target_url", "http url to the backend", :mandatory => true
param "timeout", "configuration for the ProxyTimeout directice - timeout in seconds to wait for a proxied response"

on_machine do |machine, params|
  generated_dir = machine.apache_generated_conf_dir
  apache_log_dir = machine.apache_log_dir
  
  first_domain = params["server_name"].first
  process_local_template(:apache_reverse_proxy, machine, "#{generated_dir}/#{first_domain}.conf", binding())
end