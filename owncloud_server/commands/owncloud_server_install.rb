param :machine
param! "domain"

on_machine do |machine, params|
  # TODO move into static_html, :document_root => 'foo' ?
  machine.add_static_vhost("server_name" => params["domain"], "document_root" => "/var/www/html/owncloud")
  machine.restart_service("service" => "apache")
  machine.configure_reverse_proxy("domain" => params["domain"])
  
  machine.ssh_and_check_result("command" => "curl -c cookies.txt -v -o /dev/null http://#{params["domain"]}/index.php")
  # TODO hardcoded install values
  machine.ssh_and_check_result("command" => "curl -b cookies.txt -v -d 'install=true&adminlogin=marvin&adminpass=the_password&directory=%2Fvar%2Fwww%2Fhtml%2Fowncloud%2Fdata&dbtype=sqlite&dbuser=&dbpass=&dbname=&dbhost=localhost' http://#{params["domain"]}/")
end
