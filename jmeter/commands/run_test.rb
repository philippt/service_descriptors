description "executes a jmeter test (locally)"

param! :machine
param! "test", "the test that should be executed", :lookup_method => lambda { |request|
  @op.list_tests("machine" => request.get_param_value("machine"))
}
param "slave", "a machine that should execute the test as jmeter slave", 
  :allows_multiple_values => true,
  :lookup_method => lambda {
    @op.list_machines.map { |m| m["name"] }    
  }
param "slave_ip", "the IP address to a machine that should execute the test as jmeter slave", 
  :allows_multiple_values => true
  
#display_type :hash

on_machine do |machine, params|
  test_path = "tests/#{params["test"]}.jmx"
  command_string = "apache-jmeter-2.6/bin/jmeter -n -t #{test_path}"
  
  slaves = []
  
  if params.has_key?('slave')
    params['slave'].each do |slave_name|
      @op.with_machine(slave_name) do |slave|
        d = slave.machine_detail
        slaves << (d.has_key?('dns_name') ? d['dns_name'] : d['ssh_host'])  
      end
    end    
  end
  
  if params.has_key?('slave_ip')
    slaves += params['slave_ip']
  end
  
  command_string += " -R #{slaves.join(',')}" unless slaves.size == 0
  
  output = machine.ssh("command" => command_string)
  result = output
#  result = {"unparsed_output" => output}
#  output.split("\n").each do |line|
#    line.strip!
#               # Generate Summary Results =  2500 in  20.0s =  125.3/s Avg:   488 Min:    22 Max:  6139 Err:     0 (0.00%)
#    matched = /Generate\s+Summary\s+Results\s+=\s+(\d+)\s+in\s+([\d\.]+s)\s+=\s+([\d\.]+\/s)\s+Avg:\s+(\d+)\s+Min:\s+(\d+)\s+Max:\s+(\d+)\s+/.match(line)
#    if matched
#      result = {}
#      result["sample_count"] = matched.captures[0],
#      result["total_duration"] = matched.captures[1],
#      result["throughput"] = matched.captures[2],
#      result["average"] = matched.captures[3],
#      result["min"] = matched.captures[4],
#      result["max"] = matched.captures[5]
#      #result["error_count"] = matched.captures[7],
#      #result["error_percentage"] = matched.captures[8]
#      
#      break
#    end
#  end
  
  result
end