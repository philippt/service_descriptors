require 'tempfile'

description "adds a new node of type 'Link' to the specified drupal"

param! "drupal_url", "the http URL to the drupal instance to be used"
param! "services_endpoint", "the name of the drupal services endpoint that should be used (the endpoint should include the 'user' resource)"
param! "drupal_user", "an existing drupal user with privileges to create new users"
param! "drupal_password", "the password associated to drupal_user"

param! "description", "the textual description for the new link"
param! "link", "the actual HTTP link"
param! "category_id", "the id of the category taxonomy term this link should be tagged with"

execute do |params|
  file = Tempfile.new('virtualop_drupal_user_cookies')
  cookie_path = file.path
  $logger.debug "working with cookie file in #{cookie_path}"
  
  @op.with_machine("localhost") do |machine|
    # login
    data_string = "name=#{params["drupal_user"]}&pass=#{params["drupal_password"]}&form_id=user_login"
    machine.ssh("command" => "curl -b #{cookie_path} -c #{cookie_path} --data \"#{data_string}\" #{params["drupal_url"]}/?q=user/login")
    
    $logger.info "logged in successfully as #{params["drupal_user"]} to #{params["drupal_url"]}."
    
    # add node
    data_string = "type=link&title=#{params["description"]}&field_link[und][0][value]=#{params["link"]}&field_kategorie[und][0]=#{params["category_id"]}"
    machine.ssh("command" => "curl -b #{cookie_path} -d \"#{data_string}\" \"#{params["drupal_url"]}/?q=#{params["services_endpoint"]}/node\"")
    
    # logout
    data_string = "name=#{params["drupal_user"]}&pass=#{params["drupal_password"]}"
    machine.ssh("command" => "curl -b #{cookie_path} -c #{cookie_path} --data \"#{data_string}\" #{params["drupal_url"]}/?q=user/logout")
    
    machine.rm("file_name" => cookie_path)
  end
end