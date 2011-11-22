param :machine

on_machine do |machine, params|
  machine.ssh_and_check_result("command" => "rabbitmq-plugins enable rabbitmq_management")
end