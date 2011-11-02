param :machine
param "domain", "the domain pointing to the proxy", :mandatory => true
#param :service_root

on_machine do |machine, params|
  machine.install_service("service_root" => "/etc/vop/service_descriptors/apache")
  
  process_template(:index_html, machine, "/var/www/html/index.html", binding())
  machine.add_static_vhost("server_name" => params["domain"], "document_root" => "/var/www/html")
  machine.restart_unix_service("name" => "httpd")  
end
