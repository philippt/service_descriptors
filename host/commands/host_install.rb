param :machine
param "extra_ip", "extra IP address to configure on eth0"

on_machine do |machine, params|  
  %w|messagebus avahi-daemon libvirtd|.each do |service_name|
    machine.restart_unix_service("name" => service_name)
  end
  %w|messagebus avahi-daemon|.each do |service_name|
    machine.mark_unix_service_for_autostart("name" => service_name)
  end
  
  machine.install_yum_group("group_name" => "Virtualization*")
  
  loaded_modules = machine.ssh_and_check_result("command" => "lsmod | grep -c kvm").to_i
  raise "could not find virtualization kernel module" unless loaded_modules >= 2
  
  machine.reboot_and_wait
    
  # TODO persist this
  machine.ssh_and_check_result("command" => "brctl addbr br10")
  machine.ssh_and_check_result("command" => "ifconfig br10 10.60.10.1 netmask 255.255.255.0")
  if params.has_key?("extra_ip")
    machine.ssh_and_check_result("command" => "ip addr add #{params["extra_ip"]}/32 dev eth0")
  end
  
  machine.iptables_generator_install
  machine.generate_and_execute_iptables_script
  
  machine.mkdir('dir_name' => @op.plugin_by_name('service_descriptors').config_string('service_config_dir'))
end
