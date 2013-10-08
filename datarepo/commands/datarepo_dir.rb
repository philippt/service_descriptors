param :machine

on_machine do |machine, params|
  details = machine.service_details("service" => "datarepo")
  
  if details.has_key?("extra_params") && details["extra_params"].has_key?("repo_dir")
    result = details["extra_params"]["repo_dir"]
  end
  
  if result.is_a?(Array)
    result = result.first
  end
  
  result
end
