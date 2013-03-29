param :machine

on_machine do |machine, params|
  if machine.linux_distribution.split("_").first == "centos"
    machine.ssh("command" => "rabbitmq-plugins enable rabbitmq_management")
  end
  #machine.ssh("command" => "rabbitmqctl add_user the_user the_password")
  #machine.ssh("command" => "rabbitmqctl set_permissions the_user '.*' '.*' '.*'")
end