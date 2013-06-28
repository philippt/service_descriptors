param :machine
param :one_database
param! "table", "a table to work with", :lookup_method => lambda { |request|
  @op.list_tables(
    "machine" => request.get_param_value("machine"), 
    "database" => request.get_param_value("database")
  ).map { |x| x["name"] }
}
param "limit", "number of lines that should be returned", :default_value => 5

display_type :table

on_machine do |machine, params|
  mysql_xml_to_rhcp machine.execute_sql("xml" => "true", "database" => params["database"],
    "statement" => "select * from #{params["table"]} limit #{params["limit"]}")
end
