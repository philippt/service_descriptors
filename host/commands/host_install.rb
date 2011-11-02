param :machine

on_machine do |machine, params|
  machine.install_yum_group("group_name" => "Virtualization*")
  
  loaded_modules = machine.ssh_and_check_result("command" => "lsmod | grep -c kvm").to_i
  raise "could not find virtualization kernel module" unless loaded_modules >= 2
  
  #machine.ssh_and_check_result("command" => "reboot")
  
  # TODO persist this
  machine.ssh_and_check_result("command" => "brctl addbr br10")
  machine.ssh_and_check_result("command" => "ifconfig br10 10.60.10.1 netmask 255.255.255.0")
  
  machine.iptables_generator_install
  machine.generate_and_execute_iptables_script
  
end
