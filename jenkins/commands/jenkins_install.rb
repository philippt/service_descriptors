param :machine
param "domain", "the domain at which jenkins should be available"

on_machine do |machine, params|
  if machine.file_exists("file_name" => "/etc/sysconfig/jenkins")
    machine.ssh_and_check_result("command" => "sed -i -e 's/JENKINS_USER=\"jenkins\"/JENKINS_USER=\"root\"/g' /etc/sysconfig/jenkins")
  end    
  machine.start_unix_service("name" => "jenkins")
  
  if params.has_key?('domain')
    machine.install_service("service_root" => "/etc/vop/service_descriptors/apache")
    machine.add_reverse_proxy("server_name" => [ params["domain"] ], "target_url" => "http://localhost:8080/")
    machine.restart_unix_service("name" => "httpd")
    
   
    host_name = machine.name.split(".")[1..10].join(".")
    proxy_name = "proxy." + host_name
    @op.with_machine(proxy_name) do |proxy|
      proxy.add_reverse_proxy("server_name" => [ params["domain"] ], "target_url" => "http://#{machine.ipaddress}/")
      proxy.ssh_and_check_result("command" => "/etc/init.d/httpd restart")
    end
  end
end
