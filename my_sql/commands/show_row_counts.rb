description "returns a list of all tables in a database along with the number of rows in each (performs a count(*) against each table)"
  
param :machine
param :one_database
  
mark_as_read_only() # TODO well, not exactly r/o
add_columns [ :name, :count ]
  
on_machine do |machine, params|
  machine.show_tables(params).each do |table|
    table["count"] = mysql_xml_to_rhcp(machine.execute_sql({
      "database" => params["database"],
      "xml" => true,
      "statement" => "select count(*) as the_count from #{table["name"]}"
    })).first["the_count"]
  end
end
  
