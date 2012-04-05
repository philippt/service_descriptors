description "grants database access for the users specified in #{mysql_user_dropdir}"

param :machine

on_machine do |machine, params|
  machine.list_configured_db_users.each do |config|
    sql_statement = "grant #{config["privilege"]} on #{config["db"]}.#{config["tables"]} "
    sql_statement += "to '#{config["name"]}'@'#{config["host"]}' identified by '#{config['password']}'"
    machine.execute_sql({
      "statement" => sql_statement
    })
  end

  true
end