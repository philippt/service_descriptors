param :machine

on_machine do |machine, params|
  new_password = 'the_password'
  machine.ssh_and_check_result("mysqladmin -u root password #{new_password}")
  
end
