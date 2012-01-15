description "creates a new dump from the local database and copies it to another machine"

param :machine
param! "target_machine", "hostname of the machine to which the dump should be transferred"       
param :multiple_optional_databases, "a list of local databases that should be part of the dump (defaults to '*')"

on_machine do |machine, params|
  $logger.debug "+++ CreateAndTransferDumpCommand.execute +++"
  new_dump = nil
  args = {}
  if params.has_key?("database")
    args["database"] = params["database"]
  end
  new_dump = machine.dump_database(args)
  $logger.info "new dump created : #{new_dump}"
  machine.transfer_dump({
    "dump_name" => new_dump,
    "target_machine" => params["target_machine"]
  })

  new_dump
end  