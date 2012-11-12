param :machine

on_machine do |machine, params|
  machine.ssh_and_check_result("command" => "rails -v")
end
