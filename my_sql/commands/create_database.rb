description "creates a new database"

add_columns [ :name ]

param :machine
param! "name", "the name of the new database", :default_param => true

on_machine do |machine, params|
  machine.execute_sql("statement" => "create database #{params["name"]}")
  
  @op.without_cache do
    machine.list_databases
  end
end