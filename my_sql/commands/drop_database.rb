description "drops a database. really. dangerous. bigtime."

add_columns [ :name ]

param :machine
param! :one_database, "the database that should be dropped (choose wisely)"

on_machine do |machine, params|
  # TODO support multi-values for 'database'

  machine.execute_sql("statement" => "drop database #{params["database"]}")
    
  @op.without_cache do
    machine.list_databases
  end

  # TODO add paranoia check that checks against list_databases on the new machine
        
  # TODO invalidate cache
  
end