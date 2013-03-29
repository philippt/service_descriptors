description "adds a backend configuration to varnish"

param :machine
param! "backend_host", "the backend host name or IP that should be proxied"
param! "backend_port", "the port name on which the backend server is listening", 
  :default_value => 80
param "template_name", "an alternative template that should be used", :default_value => "default_vcl"

  
on_machine do |machine, params|
  case machine.linux_distribution.split("_").first
  when "ubuntu"  
    # TODO move (from here and varnish_install) into process_local_template
    # got to workaround a permission problem here - ssh user (ubuntu) cannot write to /etc
    temp_file_name = machine.home + "/vop_configure_varnish_backend_#{Time.now.to_i}.tmp"
    process_local_template(:default_vcl, machine, temp_file_name, binding())
    real_path = "/etc/varnish/default.vcl"
    machine.ssh("command" => "sudo cp #{temp_file_name} #{real_path}")
    machine.rm("file_name" => temp_file_name)
  else
    process_local_template(params["template_name"].to_sym, machine, "/etc/varnish/default.vcl", binding())
  end    
end

