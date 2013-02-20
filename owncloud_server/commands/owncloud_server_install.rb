param :machine
param! "domain"

on_machine do |machine, params|
  # TODO move into static_html, :document_root => 'foo' ?
  machine.add_static_vhost("server_name" => params["domain"], "document_root" => "/var/www/html/owncloud")
  machine.restart_service("service" => "apache")
  machine.configure_reverse_proxy("domain" => params["domain"])
end
