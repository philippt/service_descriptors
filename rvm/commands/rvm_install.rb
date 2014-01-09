param :machine
param! "user", "name of the user account in whose context rvm should be installed"
param "ruby_version", "a version of ruby to install using the newly installed rvm"
param "rvm_version", "a specific version of RVM that should be installed"

# TODO needs_sudo

on_machine do |m, params|
  m.as_user("user_name" => params["user"]) do |machine|
    tmp_dir = "/home/#{params["user"]}/tmp"
    machine.mkdir tmp_dir
    machine.ssh("cd #{tmp_dir} && curl -k -L https://get.rvm.io > rvm_io.sh && chmod +x rvm_io.sh")
    
    rvm_version = params.has_key?("rvm_version") ? params["rvm_version"] : ''
    machine.ssh("cd #{tmp_dir} && ./rvm_io.sh #{rvm_version}")
    
    machine.rvm_ssh("rvm get stable")
    machine.rvm_ssh("rvm get head --auto-dotfiles")
    
    if params.has_key?("ruby_version")
      machine.rvm_ssh("rvm install #{params["ruby_version"]} --verify-downloads 1")
    end
  end
end