param :machine
param! "user", "name of the user account in whose context rvm should be installed"
param "ruby_version", "a version of ruby to install using the newly installed rvm"

# TODO needs_sudo

on_machine do |m, params|
  m.as_user("user_name" => params["user"]) do |machine|
    machine.ssh("rvm get stable")
    
    if params.has_key?("ruby_version")
      machine.ssh("rvm install #{params["ruby_version"]} --verify-downloads 1")
    end
  end
end
