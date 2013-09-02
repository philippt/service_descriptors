param :machine

on_machine do |m, params|
  
  m.as_user("root") do |machine|
    if machine.linux_distribution.split("_").first == "centos"
      machine.ssh("command" => "rabbitmq-plugins enable rabbitmq_management")
    end
    machine.replace_in_file(
      "file_name" => "/etc/init.d/rabbitmq-server",
      "source" => 'START_PROG="runuser',
      "target" => 'START_PROG="nohup runuser'
    )
    #machine.ssh("command" => "rabbitmqctl add_user the_user the_password")
    #machine.ssh("command" => "rabbitmqctl set_permissions the_user '.*' '.*' '.*'")
  end
end