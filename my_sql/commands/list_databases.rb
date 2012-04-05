description "lists all local mysql databases"

param :machine
param "hide_blacklisted", "if set to 'true', this will filter out all blacklisted databases from the list"

mark_as_read_only
add_columns [ :name ]

on_machine do |machine, params|
  input = machine.execute_sql("statement" => "show databases", "xml" => "true")
  raw_result = mysql_xml_to_rhcp(input)

  raw_result.sort! { |x,y| x["Database"] <=> y["Database"] }
  
  result = raw_result.map do |item|
    { 
      "name" => item["Database"]
    }
  end
  
  if params.has_key?("hide_blacklisted") and params["hide_blacklisted"] == "true"
    new_result = []
    result.each do |line|
      $logger.info("checking db name '#{line["name"]}' against blacklist: '#{blacklisted_db_names.join(",")}'")
      if not blacklisted_db_names.include?(line["name"])
        new_result << line
      end
    end
  else
    new_result = result
  end

  $logger.debug("returning #{new_result}")
  new_result
end
