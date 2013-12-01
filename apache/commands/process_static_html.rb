contributes_to :post_process_service_installation

param :machine
param :service, "", :default_param => true

accept_extra_params

on_machine do |machine, params|
  service = @op.service_details(params)
  
  if service.has_key?("static_html")
    unless params.has_key?("extra_params") and params["extra_params"].has_key?("domain")
      raise "static_html configuration found for service #{service["name"]}, but no domain parameter is present. don't know where to publish static html pages"
    end
    
    
    domain = params["extra_params"]["domain"]
    machine.install_canned_service("service" => "apache/apache")

    vhost_options = {
      "server_name" => domain, 
      "document_root" => service["service_root"]
    }
    options = service["static_html"]
    if options.is_a?(Hash) && options.has_key?('twist')
      vhost_options['twist'] = options['twist']
    end 
    machine.add_static_vhost(vhost_options)
    machine.allow_access_for_apache("file_name" => service["service_root"])
    machine.restart_service 'apache/apache'
    
    machine.configure_reverse_proxy("domain" => domain)
  end
end
