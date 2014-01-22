param :machine
param "selenium_machine", "a machine on which selenium tests can be executed"

on_machine do |machine, params|
  params.merge! machine.service_details("service" => "jenkins/jenkins")
  selenium = read_local_template(:ldap_config, binding())
  @op.selenium_ruby('machine' => params['selenium_machine'], 'selenium' => selenium)
end  
