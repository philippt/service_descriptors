param :machine
param "domain", "the domain at which jenkins should be available", :mandatory => true

on_machine do |machine, params|
  machine.ssh_and_check_result("command" => "sed -i -e 's/JENKINS_USER=\"jenkins\"/JENKINS_USER=\"root\"/g' /etc/sysconfig/jenkins")
  machine.start_unix_service("name" => "jenkins")
  machine.install_apache

  machine.add_reverse_proxy("server_name" => [ params["domain"] ], "target_url" => "http://localhost:8080/")
  
  machine.start_unix_service("name" => "httpd")
 
  host_name = machine.name.split(".")[1..10]
  proxy_name = "proxy." + host_name
  @op.with_machine(proxy_name) do |proxy|
    host.add_reverse_proxy("server_name" => [ params["domain"] ], "target_url" => "http://#{machine.ipaddress}/")
    host.ssh_and_check_result("command" => "/etc/init.d/httpd restart")
  end
end
