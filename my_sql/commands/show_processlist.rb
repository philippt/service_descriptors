description "wrapper for MySQL's 'show full processlist'"

add_columns [ :id, :user, :host, :db, :command, :time, :state, :info ]

on_machine do |machine, params|
  xml_data = machine.execute_sql({
    "statement" => "show full processlist;",
    "xml" => true
  })
  mysql_xml_to_rhcp(xml_data)
end  