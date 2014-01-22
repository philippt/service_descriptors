description "calls OPTIMIZE TABLE on each table in a database"
  
param :machine
param :one_database
  
display_type :list

on_machine do |machine, params|
  result = []
  machine.show_tables("database" => params["database"]).each do |table|
    table_name = table["name"]
    machine.execute_sql(
      "database" => params["database"],
      "statement" => "OPTIMIZE TABLE #{table_name}"
    )
    result << table_name
  end
  result
end