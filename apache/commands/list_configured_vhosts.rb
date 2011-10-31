description 'lists the virtual hosts that have been configured on this apache'

param :machine

display_type :list

on_machine do |machine, params|
  machine.ssh_and_check_result("command" => "ls /etc/httpd/conf.d.generated/")
end
