description 'lists existing users in a drupal instance'

param "drupal_url", "the http URL to the drupal instance to be used", :mandatory => true
param "services_endpoint", "the name of the drupal services endpoint that should be used (the endpoint should include the 'user' resource)", :mandatory => true
param "drupal_user", "an existing drupal user with privileges to create new users", :mandatory => true
param "drupal_password", "the password associated to drupal_user", :mandatory => true

display_type :table
add_columns [ :uid, :name ]

#mark_as_read_only

execute do |params|
  result = []
  as_drupal_user(params) do |localhost, cookie_path, params|    
    users = JSON.parse(localhost.ssh("command" => "curl -s -b #{cookie_path} \"#{params["drupal_url"]}/?q=#{params["services_endpoint"]}/user\""))
    users.each do |item|
      result << item
    end
  end
  result
end
