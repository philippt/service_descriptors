param :machine

on_machine do |machine, params|
  begin
    # TODO we can do this only once
    new_password = 'the_password'
    machine.ssh_and_check_result("command" => "mysqladmin -u root password #{new_password}")
  rescue
  end   
end
