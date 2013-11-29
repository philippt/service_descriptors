contributes_to :post_process_service_installation

param :machine
param :service, "", :default_param => true

accept_extra_params

on_machine do |machine, params|
  service = @op.service_details(params)
  
  if service.has_key?("http_endpoint") and service["http_endpoint"].size > 0
    unless params.has_key?("extra_params") and params["extra_params"].has_key?("domain")
      raise "http_endpoint configuration found for service #{service["name"]}, but no domain parameter is present. not handling http_endpoint #{service["http_endpoint"]}"
    end
    
    domain = params["extra_params"]["domain"]      
    machine.install_canned_service("service" => "apache/apache")

    target_urls = service["http_endpoint"].map do |endpoint|
      "http://127.0.0.1:#{endpoint}"
    end
    machine.add_reverse_proxy("server_name" => domain, "target_url" => target_urls)
    machine.restart_service 'apache/apache'
    
    machine.configure_reverse_proxy("domain" => domain) if machine.proxy
  end
end