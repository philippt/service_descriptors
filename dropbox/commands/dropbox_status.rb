param :machine

on_machine do |machine, params|
  machine.ssh_and_check_result("command" => "#{machine.home}/dropbox.py status")
end
