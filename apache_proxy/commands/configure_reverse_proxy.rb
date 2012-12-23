description 'configures a reverse proxy virtualop host on the proxy machine sitting on the same host as the selected machine'

param :machine
param! "domain", "the domain at which the service should be available"
param "timeout", "configuration for the ProxyTimeout directice - timeout in seconds to wait for a proxied response"
param "proxy", "name of the machine where the proxy is running"
param "port", "a port to forward to (defaults to 80)"

on_machine do |machine, params|
  
  proxy_name = params["proxy"] || machine.proxy
  
  @op.with_machine(proxy_name) do |proxy|
    port = params.has_key?("port") ? ':' + params["port"] : ''
    p = {"server_name" => [ params["domain"] ], "target_url" => "http://#{machine.ipaddress}#{port}/"}.merge_from params, :timeout, :invalidation
    proxy.add_reverse_proxy(p)
    proxy.restart_unix_service("name" => "httpd")
  end
end