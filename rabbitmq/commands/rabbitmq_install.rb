param :machine

on_machine do |machine, params|
  machine.ssh_and_check_result("command" => "rabbitmq-plugins enable rabbitmq_management")
  #machine.ssh_and_check_result("command" => "rabbitmqctl add_user the_user the_password")
  #machine.ssh_and_check_result("command" => "rabbitmqctl set_permissions the_user '.*' '.*' '.*'")
end