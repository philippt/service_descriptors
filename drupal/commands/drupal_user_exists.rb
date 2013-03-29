description "returns true if the specified user exists in this drupal instance"

param "drupal_url", "the http URL to the drupal instance to be used", :mandatory => true
param "services_endpoint", "the name of the drupal services endpoint that should be used (the endpoint should include the 'user' resource)", :mandatory => true
param "drupal_user", "an existing drupal user with privileges to create new users", :mandatory => true
param "drupal_password", "the password associated to drupal_user", :mandatory => true

param! "user_name", "the user name to check"

execute do |params|
  as_drupal_user(params) do |localhost, cookie_path, params|    
    users = JSON.parse(localhost.ssh("command" => "curl -s -b #{cookie_path} \"#{params["drupal_url"]}/?q=#{params["services_endpoint"]}/user\""))
    users.select do |candidate|
      candidate["name"] == params["user_name"]
    end.size > 0
  end
end
