description "reboots a machine and waits for it to be reachable through SSH again"

param :machine

execute do |params|
  @op.with_machine(params["machine"]) do |machine|
    machine.ssh_and_check_result("command" => "reboot")
  end
  
  @op.flush_cache
  sleep 15
  
  @op.wait_until(
    "interval" => 5, "timeout" => 120, 
    "error_text" => "could not find a running machine with name '#{params["machine"]}'",
    "condition" => lambda do
      result = false
      begin
        @op.with_machine(params["machine"]) do |new_connection|
          new_connection.hostname
        end      
        result = true
      rescue Exception => e
        $logger.info("got an exception while trying to connect to machine : #{e.message}")
      end
      result
    end
  )
end