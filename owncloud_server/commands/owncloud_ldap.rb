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
  ldap_base = CGI.escapeHTML(params['ldap_domain'].split('.').map { |x| "dc=#{x}" }.join(','))
    
  bind_user = CGI.escapeHTML(params["bind_user"])
  bind_password = params['bind_password']
  
  #selenium = read_local_template(:ldap_config, binding())
  selenium = ''
  templates = %w|owncloud_login enable_ldap|
  templates += %w| connection advanced user_filter login_filter|
  templates.each do |template|
    selenium += "\n\n# +++ #{template} +++\n" + read_local_template(template.to_sym, binding())
  end
  @op.selenium_ruby('machine' => params['selenium_machine'], 'selenium' => selenium)
end  