description "lists all database dumps that can be found on the system"

param :machine

mark_as_read_only()
add_columns [ :name, :date, :host, :service ]

on_machine do |machine, params|
  if machine.file_exists({"file_name" => dump_dir})
    dump_pattern = dump_dir + "/db_backup_*"
    begin
      input = machine.ssh_and_check_result("command" => "ls -1 -d #{dump_pattern}")
      unparseable_lines = 0
      result_by_name = {}
      input.split("\n").each do |line|
        $logger.debug("processing line >>#{line}<<")
        # /home/webadmin/tmp/db_backup_200908272123
        # /home/webadmin/tmp/db_backup_beta_200908291551        
        # /home/webadmin/tmp/db_backup_complete02.tobago.pro.bm.loc_center_200908291551
        #matcher = /\/home\/webadmin\/tmp\/(db_backup_(?:(.+)_)?(\d+))\s*/.match(line)
        matcher = /#{dump_dir}\/(db_backup_(.*?))(\.tgz)?$/.match(line)
        if matcher then
          name_components = matcher.captures[1].split("_")
          result_hash = {
            "name" => "" + matcher.captures[0],
            "date" => name_components.last
          }
          result_hash["host"] = "" + name_components[0].to_s if name_components.size > 1
          result_hash["service"] = name_components[1].to_s if name_components.size > 2
          
          result_by_name[result_hash["name"]] = result_hash        
        else
          unparseable_lines += 1
        end
      end
    #    y result_by_name
      result = result_by_name.values
      result.sort! { |x,y| x["date"] <=> y["date"] }
    
      if (unparseable_lines > 0) then
        raise RuntimeError.new("could not parse result - encountered #{unparseable_lines} lines that do not match expectations")
      end
    
      $logger.debug("returning #{result}")
      result
    rescue InvalidResultCodeException
      $logger.warn("looks as if there are no dumps to be found in #{dump_dir}")
      []
    end
  else
    $logger.warn("looks as if the directory #{dump_dir} does not exist. are you sure you're connected to the right box?")
    []
  end
end

# we get a simple list of all matching directory names
def process(input)
  
end