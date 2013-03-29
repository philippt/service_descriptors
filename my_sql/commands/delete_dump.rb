description "deletes the specified dump (*really*)"

add_columns [ :name ]

param :machine
param :dump, "the dump that should be deleted"

on_machine do |machine, params|
  dump_name = params["dump_name"]
  $logger.info("deleting dump " + dump_name)
  path_to_dump = dump_dir + '/' + dump_name

  if not machine.file_exists({"file_name" => path_to_dump})
    $logger.debug "did not find the dump directory...checking for tarball"
    path_to_dump += ".tgz"
    if not machine.file_exists({"file_name" => path_to_dump})
      raise Exception.new("could not find the dump 'dump_name' neither as directory nor as tarball...something's wrong here")
    end
  end

  # TODO this does not throw an error if the dump cannot be deleted due to a permission problem
  machine.ssh("rm -rf #{path_to_dump}")

  # TODO compare list of dumps before and after deleting
end  
