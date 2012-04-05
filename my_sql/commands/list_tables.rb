description 'lists all tables in a database'

param :machine
param :one_database

mark_as_read_only

add_columns [ :name ]

on_machine do |machine, params|
  xml_data = machine.execute_sql({
    "database" => params["database"],
    "statement" => "show tables",
    "xml" => true
  })
  result = mysql_xml_to_rhcp(xml_data)
  result.each do |row|
    row["name"] = row["Tables_in_#{params["database"]}"]
  end
  result
end  

