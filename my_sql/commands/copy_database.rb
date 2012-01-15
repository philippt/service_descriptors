description "copies all databases from one host and imports them into another host"

param  :machine
param! "target_machine", "hostname of the machine to which the dump should be transferred"
param :multiple_optional_databases, "a list of local databases that should be part of the dump (defaults to '*')"

on_machine do |machine, params|
  dump_name = nil
  args = {}
  if params["database"]
    args["database"] = params["database"]
  end

  dump_name = machine.dump_database(args)

  machine.transfer_dump({
    "dump_name" => dump_name,
    "target_machine" => params["target_machine"]
  })

  @op.with_machine(params["target_machine"]) do |target_machine|
    target_machine.restore_dump({
      "dump_name" => dump_name
    })
  end
end