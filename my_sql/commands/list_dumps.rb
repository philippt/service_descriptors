description "lists all database dumps that can be found on the system"

param :machine

mark_as_read_only()
add_columns [ :name, :date, :host, :service ]

on_machine do |machine, params|
  if machine.file_exists("file_name" => dump_dir)
    result_by_name = {}
    machine.list_files("directory" => dump_dir).each do |file|
      dump_pattern = "db_backup_"
      next unless matcher = /^(db_backup-(.*?))(\.tgz)?$/.match(file)
      name_components = matcher.captures[1].split("-")
      result_hash = {
        "name" => "" + matcher.captures[0],
        "date" => name_components.last,
        "file_name" => dump_dir + '/' + file
      }
      result_hash["host"] = "" + name_components[0].to_s if name_components.size > 1
      result_hash["service"] = name_components[1].to_s if name_components.size > 2
      
      result_by_name[result_hash["name"]] = result_hash        
        
    end
    result = result_by_name.values
    result.sort! { |x,y| x["date"] <=> y["date"] }
    $logger.debug("returning #{result}")
    result
  else
    $logger.warn("looks as if the directory #{dump_dir} does not exist. are you sure you're connected to the right box?")
    []
  end
end
