param :machine

on_machine do |machine, params|
  begin
    # TODO we can do this only once
    new_password = 'the_password'
    machine.ssh("command" => "mysqladmin -u root password #{new_password}")
  rescue
  end   
end
