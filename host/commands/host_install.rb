param :machine
param "extra_ip", "extra IP address to configure on eth0"

on_machine do |machine, params|
  services = %w|messagebus avahi-daemon libvirtd|   
  services.each do |service_name|
    machine.restart_unix_service("name" => service_name)
  end
  services.delete("libvirtd")
  services.each do |service_name|
    machine.mark_unix_service_for_autostart("name" => service_name)
  end
  
  machine.install_yum_group("group_name" => "Virtualization*")
  
  loaded_modules = machine.ssh("command" => "lsmod | grep -c kvm").to_i
  raise "could not find virtualization kernel module" unless loaded_modules >= 2
  
  machine.reboot_and_wait
    
  # TODO persist this
  machine.ssh("command" => "brctl addbr br10")
  machine.ssh("command" => "ifconfig br10 10.60.10.1 netmask 255.255.255.0")
  if params.has_key?("extra_ip")
    machine.ssh("command" => "ip addr add #{params["extra_ip"]}/32 dev eth0")
  end
  
  machine.iptables_generator_install
  machine.generate_and_execute_iptables_script
  
  machine.mkdir('dir_name' => @op.plugin_by_name('service_descriptors').config_string('service_config_dir'))
end
