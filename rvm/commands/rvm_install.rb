param :machine
param! "user", "name of the user account in whose context rvm should be used"
param "ruby_version", "a version of ruby to install using the newly installed rvm"

as_root do |machine, params|
  #m.as_user(params['user']) do |machine|
  #m.as_user('root') do |machine|
  unless machine.list_system_users.map { |x| x['name'] }.include? params['user']
    machine.add_system_user(params['user'])
    machine.add_system_user_to_group('user' => params['user'], 'group' => 'rvm') 
  end
  
  #machine.ssh("rvm get head --auto-dotfiles")
  
  #if params.has_key?("ruby_version")
  #  machine.ssh("rvm install #{params["ruby_version"]} --verify-downloads 1")
  #end
  #end
end
