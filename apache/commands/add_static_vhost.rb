description "adds a virtual host for static files to the apache configuration"

param :machine

param "server_name", "the http domain served by this vhost", { :mandatory => true, :allows_multiple_values => true }
param "document_root", "fully qualified path to the directory holding the static files", :mandatory => true
param "twist", "some extra content that should be included in the Directory section of the generated config"

as_root do |machine, params|
  # TODO handle other domains
  generated_dir = machine.apache_generated_conf_dir
  
  @directory_includes = params.has_key?("twist") ? params["twist"] : ""
  first_domain = params["server_name"].first
  
  process_local_template(:apache_static_vhost, machine, "#{generated_dir}/#{first_domain}.conf", binding())
  
  # TODO make sure the document root has the appropriate permissions (apache/www-data)
  
  @op.without_cache do
    machine.list_configured_vhosts
  end
end
