description 'adds a name-based vhost that acts as reverse proxy (forwarding incoming traffic to a remote backend)'

param :machine
param "server_name", "the http domain served by this vhost", { :mandatory => true, :allows_multiple_values => true }
param "target_url", "http url to the backend", :mandatory => true

on_machine do |machine, params|
  first_domain = params["server_name"].first
  process_template(:apache_reverse_proxy, machine, "/etc/httpd/conf.d.generated/#{first_domain}.conf", binding())
end