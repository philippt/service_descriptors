param :machine

on_machine do |machine, params|
  machine.install_yum_group("group_name" => "Virtualization*")  
end
