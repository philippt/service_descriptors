description "lists all databases contained in the specified dump"

param :machine
param! "file_name", "a tarball containing a dump file", :default_param => true

mark_as_read_only

on_machine do |machine, params|
  raise "no such file" unless machine.file_exists params["file_name"]
  
  result = []
    
  unless matched = /(.+?([^\/]+))\.tgz$/.match(params["file_name"])
    raise "unexpected dump file - not a tarball (at least not one ending in .tgz)"
  end
  path_to_dump = $1
  dump_name = $2
  
  content = machine.ssh "tar -tzf #{params["file_name"]}"
  content.split("\n").each do |line|
    line.strip! and line.chomp!
    if dump_name_matched = /#{dump_name}\/(.+)/.match(line)
      result << dump_name_matched.captures.first
    end
  end
  
  result
end
