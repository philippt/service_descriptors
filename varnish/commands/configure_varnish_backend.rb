description "adds a backend configuration to varnish"

param :machine
param! "backend_host", "the backend host name or IP that should be proxied"
param! "backend_port", "the port name on which the backend server is listening", 
  :default_value => 80
  
on_machine do |machine, params|
  # got to workaround a permission problem here - ssh user (ubuntu) cannot write to /etc
  temp_file_name = machine.home + "/vop_configure_varnish_backend_#{Time.now.to_i}.tmp"
  process_local_template(:default_vcl, machine, temp_file_name, binding())
  real_path = "/etc/varnish/default.vcl"
  machine.ssh_and_check_result("command" => "sudo cp #{temp_file_name} #{real_path}")
  machine.rm("file_name" => temp_file_name)
end

