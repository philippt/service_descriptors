description "executes the given sql statement (wrapper for the mysql CLI)"

param :machine
param :database, "the database against which the statement should be executed", :mandatory => false
param "statement", "the statement to execute", :mandatory => true
param "user", "the user for the connection"
param "password", "the password to use for the connection (default : none)"
param "socket", "the socket to use for the connection (default: none)"
param "xml", "enables XML output (the -X option)"

on_machine do |machine, params|
  
  
  sql_statement = params["statement"]
  $logger.info("sql on #{machine.name} : #{sql_statement}")
  
  mysql_command = "mysql"
  
  options = machine.mysql_options
  
  
  socket = params.has_key?('socket') ? params['socket'] : options["mysql_socket"]  
  if socket != nil 
    mysql_command += " -S #{socket}"
  end
   
  mysql_host = params.has_key?('mysql_host') ? params["mysql_host"] : machine.db_host()
  mysql_command += " -h #{mysql_host}" unless socket != nil # TODO is that so?
  
  user = params.has_key?('user') ? params['user'] : options["mysql_user"]
  mysql_command += " -u#{user}"
  
  password = params.has_key?('password') ? params['password'] : options["mysql_password"]    
  if password != nil
    mysql_command += " -p#{password}"
  end
  
  
  if params.has_key?('database')
    mysql_command += " -D" + params['database']
  end
  
  if params.has_key?('xml')
    mysql_command += " -X"
  end
  
  machine.ssh("command" => "echo \"#{sql_statement};\" | #{mysql_command}")  
end  
