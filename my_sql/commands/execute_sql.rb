description "executes the given sql statement"

param :machine
param "statement", "the statement to execute", :mandatory => true
param "database", "the database on which the statement should be executed"
param "user", "the user for the connection (default : root)"
param "password", "the password to use for the connection (default : none)"
param "xml", "enables XML output (the -X option)"

on_machine do |machine, params|
  
  sql_statement = params["statement"]
  $logger.info("sql on #{machine.name} : #{sql_statement}")
  
  mysql_command = "mysql"
  
  user = params.has_key?('user') ? params['user'] : mysql_user(machine, params["database"])
  mysql_command += " -u#{user}"
  
  if params.has_key?('password')      
    mysql_command += " -p#{params["password"]}"
  else
    password = mysql_password(machine, params["database"])
    if password != nil
      mysql_command += " -p#{password}"
    end
  end
  
  configured_socket = config_string('mysql_socket', '')
  if configured_socket != '' 
    mysql_command += " -S #{configured_socket}"
  end 
  
  if params.has_key?('database')
    mysql_command += " -D" + params['database']
  end
  
  if params.has_key?('xml')
    mysql_command += " -X"
  end
  
  machine.ssh_and_check_result("command" => "echo \"#{sql_statement};\" | #{mysql_command}")  
end  
