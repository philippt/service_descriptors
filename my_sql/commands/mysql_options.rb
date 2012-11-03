description "returns machine-specific connection options for mysql"

param :machine

display_type :hash

with_contributions do |result, params|
  
  unless result.has_key?("mysql_user")
    result["mysql_user"] = config_string('mysql_user', 'root')
  end
  
  if (not result.has_key?("mysql_password")) and @plugin.config.has_key?('mysql_password')
    result["mysql_password"] = @plugin.config['mysql_password']
  end
  
  if (not result.has_key?("mysql_socket")) and @plugin.config.has_key?('mysql_socket')
    result["mysql_socket"] = @plugin.config['mysql_socket']
  end
  
  result
end
