description "copies the most recent dump from source_machine to target_machine and restores it there"

param :machine
# TODO actually, this should be a lookup of the databases inside the dump, not on the source machine!
param! "target_machine", "hostname of the machine to which the dump should be transferred"
param :multiple_optional_databases, "a list of databases that should be restored (defaults to '*')"

on_machine do |machine, params|
  dump_name = nil

  dumps = machine.list_dumps
  if dumps.size() == 0
    raise Exception.new("no dumps found on source machine!")
  end

  last_dump = dumps.sort { |x,y| y["date"] <=> x["date"] }[0]
  dump_name = last_dump["name"]

  $logger.info("identified current dump on source machine : #{dump_name}")

  machine.transfer_dump({
    "dump_name" => dump_name,
    "target_machine" => params["target_machine"]
  })

  $logger.info("transfer to target machine complete...gonna restore now.")
  @op.with_machine(params["target_machine"]) do |target_machine|
    restore_params = {
      "dump_name" => dump_name
    }
    if params.has_key?("database")
      restore_params["database"] = params["database"]
    end
    target_machine.restore_dump(restore_params)
  end
end