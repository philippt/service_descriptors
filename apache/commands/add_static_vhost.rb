description "adds a virtual host for static files to the apache configuration"

param :machine

param "server_name", "the http domain served by this vhost", { :mandatory => true, :allows_multiple_values => true }
param "document_root", "fully qualified path to the directory holding the static files", :mandatory => true
param "twist", "some extra content that should be included in the Directory section of the generated config"

on_machine do |machine, params|
  # TODO handle other domains
  first_domain = params["server_name"].first
  
  @directory_includes = params.has_key?("twist") ? params["twist"] : ""
  
  process_local_template(:apache_static_vhost, machine, "/etc/httpd/conf.d.generated/#{first_domain}.conf", binding())
  
  # TODO make sure the document root has the appropriate permissions (apache/www-data)
end
