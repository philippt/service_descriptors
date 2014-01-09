param :machine
param! "user", "name of the user account in whose context rvm should be used"
param "ruby_version", "a version of ruby to install using the newly installed rvm"

on_machine do |m, params|
  m.as_user('root') do |root|
    unless root.list_system_users.map { |x| x['name'] }.include? params['user']
      root.add_system_user(params['user'])
      root.add_system_user_to_group('user' => params['user'], 'group' => 'rvm') 
    end
    root.rvm_ssh("rvm get head --auto-dotfiles")
  end
  
  @op.flush_cache
  
  m.as_user(params['user']) do |machine|
    if params.has_key?("ruby_version")
      machine.rvm_ssh("rvm install #{params["ruby_version"]} --verify-downloads 1")
      machine.rvm_ssh("rvm --default use #{params["ruby_version"]}")
    end
  end
end
