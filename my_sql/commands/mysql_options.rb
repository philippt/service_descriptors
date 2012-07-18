description "returns machine-specific connection options for mysql"

param :machine

display_type :hash

with_contributions do |result, params|
  options = result.select do |x|
    x["machine"] == params["machine"]
  end
  
  if options.size > 0 then
    options.first
  else
    {
      "mysql_user" => config_string('mysql_user', 'root'),
      "mysql_password" => @plugin.config.has_key?('mysql_password') ? config_string('mysql_password')  : nil,
      "mysql_socket" => @plugin.config.has_key?('mysql_socket') ? config_string('mysql_socket') : nil,
    }
  end
end
