description "transfers a dump to another machine"

param :machine
param! :dump, "the dump that should be transferred"
# TODO could we build a lookup method here? would be kind of cool ;-)
param! "target_machine", "hostname of the machine to which the dump should be transferred"

on_machine do |machine, params|
  # check if the dump exists on the target system - bail out if it does
  @op.with_machine(params["target_machine"]) do |target_machine|
    dumps = target_machine.list_dumps()
    if dumps.size() > 0
      existing_dumps = dumps.select do |item|
        item["name"] == params["dump_name"]
      end
      if existing_dumps.size() > 0
        raise Exception.new("the dump exists on the target machine already.")
      end
    else
      $logger.info "no dumps found on #{target_machine.name}" 
    end
  end

  path_to_dump = dump_dir + params["dump_name"]
  path_to_tarball = path_to_dump + ".tgz"
  file_to_copy = path_to_dump

  # we prefer to copy tarballs (directories could be temporary)
  if machine.file_exists({"file_name" => path_to_tarball})
    file_to_copy = path_to_tarball
  else
    if machine.file_exists({"file_name" => path_to_dump})
      file_to_copy = path_to_dump
    else
      raise Exception.new("cannot find the specified dump as tarball (#{path_to_tarball}) or directory (#{path_to_dump}) - something is wrong here. chickening out.")
    end
  end
  
  @op.with_machine("localhost") do |localhost|
    temp_dir = "/tmp/"
    machine.download_file("file_name" => file_to_copy, "local_dir" => temp_dir)

    @op.with_machine(params["target_machine"]) do |target_machine|
      target_machine.upload_file("local_file" => "#{temp_dir}/#{file_to_copy.split("/").last}", "target_file" => file_to_copy)
    
      @op.without_cache do
        new_dumps = target_machine.list_dumps()
        new_dump_on_target = new_dumps.select do |dump|
          dump["name"] == params["dump_name"]
        end
        if new_dump_on_target.size == 0
          raise "did not find dump '#{params["dump_name"]}' on target machine - something may be wrong here."
        end
      end
    end
  end  
end
