param :machine
param! "domain"

on_machine do |machine, params|
  # TODO move into static_html, :document_root => 'foo' ?
  machine.add_static_vhost("server_name" => params["domain"], "document_root" => "/var/www/html/owncloud")
  machine.restart_service("service" => "apache")
  machine.configure_reverse_proxy("domain" => params["domain"])
  
  machine.ssh_and_check_result("command" => "curl -c cookies.txt -v -o /dev/null http://#{params["domain"]}/index.php")
  
  # TODO hardcoded install values
  admin_user = 'marvin'
  admin_pwd = 'the_password'
  machine.ssh_and_check_result("command" => "curl -b cookies.txt -c cookies2.txt -v -o owncloud_set_password.out -d 'install=true&adminlogin=#{admin_user}&adminpass=#{admin_pwd}&directory=%2Fvar%2Fwww%2Fhtml%2Fowncloud%2Fdata&dbtype=sqlite&dbuser=&dbpass=&dbname=&dbhost=localhost' http://#{params["domain"]}/")
  @op.comment machine.read_file("file_name" => "cookies2.txt")
  #@op.comment machine.read_file("file_name" => "owncloud_set_password.out")
  
  if false
    machine.ssh_and_check_result("command" => "curl -c cookies3.txt -v -o admin_login.out -d 'user=#{admin_user}&password=#{admin_pwd}' http://#{params["domain"]}/")
    @op.comment machine.read_file("file_name" => "cookies3.txt")
    @op.comment machine.read_file("file_name" => "admin_login.out")
    machine.ssh_and_check_result("command" => "curl -b cookies3.txt -c cookies4.txt -v -o enable_ldap.out -d 'appid=user_ldap' http://#{params["domain"]}/settings/ajax/enableapp.php?appid=user_ldap")
    @op.comment machine.read_file("file_name" => "cookies4.txt")
    @op.comment machine.read_file("file_name" => "enable_ldap.out")
  end
  
  #request_token = ''
  #ldap_config = "ldap_host=ldap.ci.virtualop.org&ldap_base=dc%3Dci%2Cdc%3Dvirtualop%2Cdc%3Dorg&ldap_dn=cn%3Dmanager&ldap_agent_password=the_password&ldap_login_filter=uid%3D%25uid&ldap_userlist_filter=objectClass%3Dperson&ldap_group_filter=&ldap_port=389&ldap_base_users=&ldap_base_groups=&ldap_group_member_assoc_attribute=uniqueMember&ldap_display_name=uid&ldap_group_display_name=cn&ldap_quota_attr=&ldap_quota_def=&ldap_email_attr=&ldap_cache_ttl=600&home_folder_naming_rule=&requesttoken=#{request_token}"
  #machine.ssh_and_check_result("command" => "curl -b cookies3.txt -c cookies4.txt -v -d '#{ldap_config}' http://#{params["domain"]}/settings/admin.php#")
end
