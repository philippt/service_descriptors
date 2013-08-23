description "lists all databases contained in the specified dump"

mark_as_read_only()
add_columns [ :name ]

param :machine
param :dump
  
def perform_match(line, &block)
  matcher = /^([^\/]+?)(?:\.dmp\.tgz|\.dmp|\.tgz|\/)?$/.match(line)
  if matcher
    $logger.debug "adding #{matcher.captures[0]}"
    block.call(matcher.captures.first)
  end
end

on_machine do |machine, params|
  dump_name = params["dump_name"]
  path_to_dump = dump_dir + '/' + dump_name

  result = []

  if machine.file_exists({"file_name" => path_to_dump})
    result = []
    input = machine.ssh("command" => "ls -1 " + path_to_dump)
    input.split("\n").each do |line|
      line.strip!
      
      perform_match(line) do |db_name|
        result << {
          "name" => db_name
        }
      end
      
    end
  
    result
  else
    # could be that the whole thing is tarred
    tarball_name = path_to_dump + ".tgz"
    if machine.file_exists("file_name" => tarball_name)
      tar_content = machine.ssh("command" => "tar -tzf #{tarball_name}")
      #puts ">>>#{tar_content}<<<"
      tar_content.split("\n").each do |line|
        # the content has been packed relatively to /home/webadmin/tmp, so we need to
        # strip the dump name that is prefixing all entries
        line.strip! and line.chomp!
        
        dump_name_matched = /#{dump_name}\/(.+)/.match(line)
        if dump_name_matched          
          dump_name_rest = dump_name_matched.captures.first
          
          perform_match(dump_name_rest) do |db_name|
            result << {
              "name" => db_name              
            }
          end
         
        else
          # TODO
        end
      end
    end
  end

  result.sort { |x,y| x["name"] <=> y["name"] }
end