param :machine

on_machine do |machine, params|
  machine.ssh("command" => "#{machine.home}/dropbox.py status")
end
