param :machine
param! "domain"

param 'admin_user', 'user name for the first administrative account', :default_value => 'admin'
param 'admin_password', 'password for the first administrative account', :default_value => 'the_password'

param "ldap_host", "hostname or IP of a LDAP server used for auth"
param "ldap_domain", "the domain that should be used to construct the base DN (e.g. foo.org will be transformed to dc=foo,dc=org)"
param "bind_user", "ldap search string identifying the user to use for binding to the LDAP server (e.g. cn=manager)"
param "bind_password", "the password to use for LDAP binding"
param "selenium_machine", "a machine on which selenium tests can be executed"

on_machine do |machine, params|
  # TODO move into static_html, :document_root => 'foo' ?
  machine.add_static_vhost("server_name" => params["domain"], "document_root" => "/var/www/html/owncloud")
  machine.restart_service 'apache/apache'
  machine.configure_reverse_proxy("domain" => params["domain"])
  
  machine.ssh "curl -c cookies.txt -v -o /dev/null http://#{params["domain"]}/index.php"
  
  init_config = "install=true&adminlogin=#{params['admin_user']}&adminpass=#{params['admin_password']}&directory=%2Fvar%2Fwww%2Fhtml%2Fowncloud%2Fdata&dbtype=sqlite&dbuser=&dbpass=&dbname=&dbhost=localhost" 
  machine.ssh "curl -b cookies.txt -c cookies2.txt -v -d '#{init_config}' http://#{params["domain"]}/"
  @op.comment machine.read_file("file_name" => "cookies2.txt")

  if params.has_key?('ldap_host') && params.has_key?('selenium_machine')
    machine.owncloud_ldap(params)
  end
end
