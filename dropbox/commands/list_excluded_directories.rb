description "prints a list of directories currently excluded from syncing"

param :machine

on_machine do |machine, params|
  machine.ssh("command" => "#{machine.home}/dropbox.py exclude list")
end
