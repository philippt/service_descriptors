param :machine
param "domain", "the domain pointing to the proxy", :mandatory => true
#param :service_root

on_machine do |machine, params|
  machine.add_static_vhost("server_name" => params["domain"], "document_root" => "/var/www/html")
  machine.restart_service 'apache/apache'
end
