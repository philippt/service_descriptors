description "cleans work directories, starts the tomcat and waits for it to be available"

param :machine

on_machine do |machine, params|
  machine.ssh("command" => "rctomcat6 start")
  @op.comment("message" => "waiting for application startup")
  sleep 15

  found_entry = false
  @op.wait_until("interval" => "5", "timeout" => "60") do
    found_entry = machine.ssh("command" => "tail /var/log/tomcat6/catalina.out").split("\n").select do |line|
      /Server startup in (\d+) ms/.match(line)
    end.size > 0
  end
  found_entry
end
