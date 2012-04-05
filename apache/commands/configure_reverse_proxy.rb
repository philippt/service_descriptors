description 'configures a reverse proxy virtualop host on the proxy machine sitting on the same host as the selected machine'

param :machine
param "domain", "the domain at which the service should be available", :mandatory => true

on_machine do |machine, params|
  host_name = machine.name.split('.')[1..10].join('.')
  proxy_name = "proxy." + host_name
  @op.with_machine(proxy_name) do |proxy|
    proxy.add_reverse_proxy("server_name" => [ params["domain"] ], "target_url" => "http://#{machine.ipaddress}/")
    proxy.restart_unix_service("name" => "httpd")
  end
end