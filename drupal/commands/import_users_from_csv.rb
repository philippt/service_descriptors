require 'uri'

description 'imports drupal users from a particularly styled csv file'

param :machine
#param :host, "the host on which the csv file should be read"
param "file_name", "the csv file from which to read. the first line is ignored (headers probably. errm.)", :mandatory => true

param "drupal_url", "the http URL to the drupal instance to be used", :mandatory => true
param "services_endpoint", "the name of the drupal services endpoint that should be used (the endpoint should include the 'user' resource)", :mandatory => true
param "drupal_user", "an existing drupal user with privileges to create new users", :mandatory => true
param "drupal_password", "the password associated to drupal_user", :mandatory => true

display_type :table
add_columns [ :name, :id, :galeriename, :plz, :ort, :url, :email ]

on_machine do |machine, params|
  result = []
  machine.ssh("command" => "cat #{params["file_name"]}").split("\n").each do |line|      
    parts = line.split(";")
    next if parts[1] == "Suchbegriff"
    result << {
      "name" => parts[1],
      "id" => parts[0],
      "galeriename" => parts[2],
      "vorname" => parts[4],
      "nachname" => parts[5],
      "plz" => parts[6],
      "ort" => parts[7],
      "url" => parts[9],
      "email" => parts[8]
    }      
  end
  
  result.each do |new_user|
    if ((not new_user.has_key?('email')) or (new_user["email"] == nil))
     $logger.warn("ignoring entry for id #{new_user["id"]} because it doesn't have an email address")
     next
    end
    
    options = {
      "drupal_url" => params["drupal_url"],
      "services_endpoint" => params["services_endpoint"], 
      "drupal_user" => params["drupal_user"],
      "drupal_password" => params["drupal_password"],
      "new_user_name" => "galerie#{new_user["id"]}",
      #"new_password" => "kunstschafftneuesdenken",
      "email_address" => new_user["email"], #+ ".hitchhackers.net",      
      "role" => 5
    }
    options["new_password"] = options["email_address"]
    
    
    options["extra"] = []
    %w|galeriename plz ort vorname nachname url|.each do |key|
      options["extra"] << "field_#{key}[und][0][value]=#{new_user[key]}"
    end
    
    options.each do |k,v|
      if v.class.to_s == "Array"
        options[k].map! do |item|
          URI.escape(item)
        end
      elsif v.class.to_s == "String"
        options[k] = URI.escape(options[k])
      else
      end
    end
    
    begin
      @op.update_drupal_user(options)
    rescue Exception => e
      $logger.error "could not import user #{options["id"]} : #{e.message}"
    end
    #sleep 5
  end
  
  result
end
