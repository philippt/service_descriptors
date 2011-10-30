description "adds a virtual host for static files to the apache configuration"

param :machine

param "server_name", "the http domain served by this vhost", { :mandatory => true, :allows_multiple_values => true }
param "document_root", "fully qualified path to the directory holding the static files", :mandatory => true

on_machine do |machine, params|
  first_domain = params["server_name"].first
  process_template(:apache_static_vhost, machine, "/etc/httpd/conf.d.generated/#{first_domain}.conf", binding())
end
