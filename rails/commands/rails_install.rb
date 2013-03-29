param :machine

on_machine do |machine, params|
  machine.ssh("command" => "rails -v")
end
