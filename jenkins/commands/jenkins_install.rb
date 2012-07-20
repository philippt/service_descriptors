param :machine
param "domain", "the domain at which jenkins should be available"

on_machine do |machine, params|
  @op.flush_cache
  if machine.file_exists("file_name" => "/etc/sysconfig/jenkins")
    machine.ssh_and_check_result("command" => "sed -i -e 's/JENKINS_USER=\"jenkins\"/JENKINS_USER=\"root\"/g' /etc/sysconfig/jenkins")
  end    
  machine.start_unix_service("name" => "jenkins")
  
  if params.has_key?('domain')    
    machine.install_canned_service("service" => "apache/apache")
    machine.add_reverse_proxy("server_name" => [ params["domain"] ], "target_url" => "http://localhost:8080/")
    machine.restart_unix_service("name" => "httpd")
    
    machine.configure_reverse_proxy("domain" => params["domain"])
  end
end
