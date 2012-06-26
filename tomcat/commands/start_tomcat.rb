description "cleans work directories, starts the tomcat and waits for it to be available"

param :machine

on_machine do |machine, params|
  machine.ssh_and_check_result("command" => "rctomcat6 start")
  @op.comment("message" => "waiting for application startup")
  sleep 15

  found_entry = false
  @op.wait_until(
    "interval" => "5",
    "timeout" => "60",
    "condition" => lambda do
      found_entry = machine.ssh_and_check_result("command" => "tail /var/log/tomcat6/catalina.out").split("\n").select do |line|
        /Server startup in (\d+) ms/.match(line)
      end.size > 0
    end
  )
end