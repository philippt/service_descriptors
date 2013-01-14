runlevel "infrastructure"

names = {
  "centos" => "mysqld",
  "ubuntu" => "mysql",
  "sles" => "mysql"
}
unix_service names

post_installation do |machine, params|
  begin
    # TODO we can do this only once
    # TODO hardcoded password
    new_password = 'the_password'
    machine.ssh_and_check_result("command" => "mysqladmin -u root password #{new_password}")
  rescue
  end
end
