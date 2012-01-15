description "lists the users on the local mysql database"

param :machine

mark_as_read_only()
add_columns [ :user, :host ]
  
on_machine do |machine, params|
  xml_data = machine.execute_sql({
    "database" => "mysql",
    "statement" => "select user, host from user",
    "xml" => true
  })
  mysql_xml_to_rhcp(xml_data)
end