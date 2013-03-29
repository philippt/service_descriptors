param :machine
param! "domain"

param "ldap_host", "hostname or IP of a LDAP server used for auth"
param "ldap_domain", "the domain that should be used to construct the base DN (e.g. foo.org will be transformed to dc=foo,dc=org)"
param "bind_user", "ldap search string identifying the user to use for binding to the LDAP server (e.g. cn=manager)"
param "bind_password", "the password to use for LDAP binding"

on_machine do |machine, params|
  # TODO move into static_html, :document_root => 'foo' ?
  machine.add_static_vhost("server_name" => params["domain"], "document_root" => "/var/www/html/owncloud")
  machine.restart_service("service" => "apache")
  machine.configure_reverse_proxy("domain" => params["domain"])
  
  machine.ssh("command" => "curl -c cookies.txt -v -o /dev/null http://#{params["domain"]}/index.php")
  
  # TODO hardcoded install values
  admin_user = 'marvin'
  admin_pwd = 'the_password'
  machine.ssh("command" => "curl -b cookies.txt -c cookies2.txt -v -d 'install=true&adminlogin=#{admin_user}&adminpass=#{admin_pwd}&directory=%2Fvar%2Fwww%2Fhtml%2Fowncloud%2Fdata&dbtype=sqlite&dbuser=&dbpass=&dbname=&dbhost=localhost' http://#{params["domain"]}/")
  @op.comment machine.read_file("file_name" => "cookies2.txt")

  if params.has_key?("ldap_host")
    # login as admin
    machine.ssh("command" => "curl -c cookies3.txt -v -d 'user=#{admin_user}&password=#{admin_pwd}' http://#{params["domain"]}/")
    @op.comment machine.read_file("file_name" => "cookies3.txt")
    
    # get a requesttoken
    output = machine.ssh("command" => "curl -b cookies3.txt -c cookies4.txt http://#{params["domain"]}/")
    @op.comment machine.read_file("file_name" => "cookies4.txt")
    token = nil
    output.split("\n").each do |line|
      if matched = /oc_requesttoken = '(.+)'/.match(line)
        token = $1
      end
    end
    @op.comment token
    
    machine.ssh("command" => "curl -b cookies4.txt -c cookies5.txt -v -o enable_ldap.out -d 'appid=user_ldap&requesttoken=#{token}' http://#{params["domain"]}/settings/ajax/enableapp.php")
    @op.comment machine.read_file("file_name" => "cookies5.txt")
    @op.comment machine.read_file("file_name" => "enable_ldap.out")
    
    ldap_host = params["ldap_host"]
    ldap_domain = params["ldap_domain"]
    #ldap_host = 'ldap.ci.virtualop.org'
    #ldap_domain = 'ci.virtualop.org'
    
    ldap_base = CGI.escapeHTML(ldap_domain.split('.').map { |x| "dc=#{x}" }.join(','))
    #ldap_base = 'dc%3Dci%2Cdc%3Dvirtualop%2Cdc%3Dorg'
    
    bind_user = CGI.escapeHTML(params["bind_user"])
    bind_password = params['bind_password']
      
    ldap_config = "ldap_host=#{ldap_host}&ldap_base=#{ldap_base}&ldap_dn=#{bind_user}&ldap_agent_password=#{bind_password}&ldap_login_filter=uid%3D%25uid&ldap_userlist_filter=objectClass%3Dperson&ldap_group_filter=&ldap_port=389&ldap_base_users=&ldap_base_groups=&ldap_group_member_assoc_attribute=uniqueMember&ldap_display_name=uid&ldap_group_display_name=cn&ldap_quota_attr=&ldap_quota_def=&ldap_email_attr=&ldap_cache_ttl=600&home_folder_naming_rule=&requesttoken=#{token}"
    machine.ssh("command" => "curl -b cookies5.txt -c cookies6.txt -v -d '#{ldap_config}' http://#{params["domain"]}/settings/admin.php")
  end
end
