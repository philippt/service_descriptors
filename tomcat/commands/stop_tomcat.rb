description "stops the tomcat"

param :machine

on_machine do |machine, params|
  machine.ssh("command" => "rctomcat6 stop")
end