description "writes a bash wrapper script onto a machine to execute bash code after sourcing the rvm context. see https://rvm.io/workflow/scripting/"
#TODO see 'https://rvm.io/workflow/scripting/'

param :machine
param! "command", "a bash command that should be executed in rvm context", :default_param => true
param "directory", "if specified, will cd to the directory before invoking command_string" 

on_machine do |machine, params|
  tmp_file = "/tmp/virtualop_rvm_ssh_#{Time.now().to_i}"
  dir = params["directory"] || machine.home
    
  @op.comment "rvm_ssh: #{params["command"]}"  
  process_local_template(:rvm_ssh, machine, tmp_file, binding())
  
  machine.chmod("file_name" => tmp_file, "permissions" => "+x")
  machine.ssh("cd #{dir} && #{tmp_file}") 
end
