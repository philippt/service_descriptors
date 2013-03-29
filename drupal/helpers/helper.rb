require 'tempfile'

def as_drupal_user(params, &block)
  file = Tempfile.new('virtualop_as_drupal_user_cookies')
  cookie_path = file.path
  $logger.debug "working with cookie file in #{cookie_path}"
  
  @op.with_machine("localhost") do |machine|
    data_string = "name=#{params["drupal_user"]}&pass=#{params["drupal_password"]}&form_id=user_login"
    machine.ssh("command" => "curl -b #{cookie_path} -c #{cookie_path} --data \"#{data_string}\" #{params["drupal_url"]}/?q=user/login")
    
    $logger.info "logged in successfully as #{params["drupal_user"]} to #{params["drupal_url"]}."
    
    block.call(machine, cookie_path, params)
    
    data_string = "name=#{params["drupal_user"]}&pass=#{params["drupal_password"]}"
    machine.ssh("command" => "curl -b #{cookie_path} -c #{cookie_path} --data \"#{data_string}\" #{params["drupal_url"]}/?q=user/logout")
    
    machine.rm("file_name" => cookie_path)
  end
end  