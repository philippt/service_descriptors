description "stops the tomcat"

param :machine

on_machine do |machine, params|
  machine.ssh_and_check_result("command" => "rctomcat6 stop")
end