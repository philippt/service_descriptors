param :machine
param! "user", "name of the user account in whose context rvm should be installed"
param "ruby_version", "a version of ruby to install using the newly installed rvm"

# TODO needs_sudo

on_machine do |m, params|
  m.as_user("user_name" => params["user"]) do |machine|
    tmp_dir = "/home/#{params["user"]}/tmp"
    machine.mkdir tmp_dir
    machine.ssh("cd #{tmp_dir} && curl -k -L https://get.rvm.io > rvm_io.sh && chmod +x rvm_io.sh")
    machine.ssh("cd #{tmp_dir} && ./rvm_io.sh")
    
    machine.rvm_ssh("rvm get stable")
    
    if params.has_key?("ruby_version")
      machine.rvm_ssh("rvm install #{params["ruby_version"]} --verify-downloads 1")
    end
  end
end
