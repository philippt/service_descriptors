param :machine

on_machine do |machine, params|
  details = machine.service_details("service" => "datarepo/datarepo")
  
  if details.has_key?("extra_params") && details["extra_params"].has_key?("repo_dir")
    result = details["extra_params"]["repo_dir"]
    if result.is_a?(Array)
      result = result.first
    end
  end
  
  result ||= '/var/www/html' # TODO this is already defined as default value for datarepo_install.repo_dir
  
  result
end
