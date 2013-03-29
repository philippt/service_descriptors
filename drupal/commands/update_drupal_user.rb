description 'adds a new user account to the specified drupal instance'

param "drupal_url", "the http URL to the drupal instance to be used", :mandatory => true
param "services_endpoint", "the name of the drupal services endpoint that should be used (the endpoint should include the 'user' resource)", :mandatory => true
param "drupal_user", "an existing drupal user with privileges to create new users", :mandatory => true
param "drupal_password", "the password associated to drupal_user", :mandatory => true

param "new_user_name", "the name of the user that should be created", :mandatory => true
param "new_password", "the clear text password of the user that should be created", :mandatory => true
param "email_address", "the email address for the new user", :mandatory => true
param "role", "id of the drupal roles that the user should be added to", :mandatory => false, :allows_multiple_values => true
param "extra", "key=value string for extra fields that should be set. if the key starts with field_, drupal black magic is performed.", :mandatory => false, :allows_multiple_values => true 

execute do |params|
  as_drupal_user(params) do |localhost, cookie_path, params|
    
    data_string = "name=#{params["new_user_name"]}&pass=#{params["new_password"]}&mail=#{params["email_address"]}"
    if params.has_key?("role")
      params["role"].each do |role|
        data_string += "&roles[]=#{role}"
      end
    end
    if params.has_key?("extra")
      params["extra"].each do |extra|
        data_string += "&#{extra}"
      end
    end
    
    #if @op.drupal_user_exists("user_name" => params["new_user_name"])
      
    #end
    
    localhost.ssh("command" => "curl -b #{cookie_path} -d \"#{data_string}\" \"#{params["drupal_url"]}/?q=#{params["services_endpoint"]}/user\"")    
  end
end
