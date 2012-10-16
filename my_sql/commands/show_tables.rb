description "lists the tables in the specified database"

param :machine
param :database

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