description "migrates all tables in the selected database to the InnoDB engine"
  
param :machine
param :one_database
  
display_type :list

on_machine do |machine, params|
  result = []
  machine.show_tables("database" => params["database"]).each do |table|
    table_name = table["name"]
    machine.execute_sql(
      "database" => params["database"],
      "statement" => "ALTER TABLE #{table_name} ENGINE=INNODB;"
    )
    result << table_name
  end
  result
end