param :machine

on_machine do |machine, params|
  machine.add_service_config("service_description" => "load", "check_command" => "check_load_by_ssh")
  @op.reload_nagios()
end
