param :machine
param "domain", "the domain at which jenkins should be available", :mandatory => true

on_machine do |machine, params|
  machine.install_apache
  machine.add_reverse_proxy("server_name" => [ params["domain"] ], "target_url" => "http://localhost:8080/")
  machine.start_unix_service("name" => "httpd")
end
