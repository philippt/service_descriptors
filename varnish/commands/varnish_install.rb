param :machine

on_machine do |machine, params|
  case machine.linux_distribution.split("_").first
  when "ubuntu"  
    # got to workaround a permission problem here - ssh user (ubuntu) cannot write to /etc
    temp_file_name = machine.home + "/vop_process_local_template__#{Time.now.to_i}.tmp"
    process_local_template(:varnish, machine, temp_file_name, binding())
    real_path = "/etc/default/varnish"
    machine.ssh("command" => "sudo cp #{temp_file_name} #{real_path}")
    machine.rm("file_name" => temp_file_name)
  when "centos"
    process_local_template(:varnish_centos, machine, "/etc/sysconfig/varnish", binding())
  else
    process_local_template(:varnish, machine, "/etc/default/varnish", binding())
  end
end
