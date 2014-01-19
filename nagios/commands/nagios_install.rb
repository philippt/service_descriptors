description "nagios install script"

param :machine
param! "domain", "the domain at which nagios should be made available"

on_machine do |machine, params|
  machine.add_system_user 'nagios'  
  machine.add_system_group 'nagcmd'
  [ 'nagios', 'apache' ].each do |x|
    machine.add_system_user_to_group('user' => x, 'group' => 'nagcmd')
  end
  
  machine.mkdir '/root/downloads'
  
  # nagios core
  #machine.wget("url" => "http://prdownloads.sourceforge.net/sourceforge/nagios/nagios-3.3.1.tar.gz", "target_dir" => "/root/downloads")
  machine.wget('url' => 'http://prdownloads.sourceforge.net/sourceforge/nagios/nagios-3.5.1.tar.gz', "target_dir" => "/root/downloads")
  machine.explode("tar_name" => "/root/downloads/nagios-*.tar.gz", "working_dir" => "/root/downloads")   
  
  machine.ssh 'cd /root/downloads/nagios && ./configure --with-command-group=nagcmd'
  machine.ssh 'cd /root/downloads/nagios && make all'
  
  %w|install install-init install-commandmode install-config|.each do |phase|
    machine.ssh "cd /root/downloads/nagios && make #{phase}"
  end
  
  #/usr/local/nagios/etc/objects/contacts.cfg
  
  machine.ssh 'cd /root/downloads/nagios && make install-webconf'
  # TODO hardcoded credentials
  machine.ssh 'htpasswd -cb /usr/local/nagios/etc/htpasswd.users nagiosadmin the_password'
  
  # nagios-plugins
  machine.github_clone('github_project' => 'nagios-plugins/nagios-plugins', 'git_branch' => 'release-1.5')
  machine.ssh 'cd /root/nagios-plugins && tools/setup'
  machine.ssh "cd /root/nagios-plugins && ./configure --with-nagios-user=nagios --with-nagios-group=nagcmd"
  machine.ssh "cd /root/nagios-plugins && make && make install"
  
  machine.ssh("command" => "chkconfig --add nagios")
  machine.ssh("command" => "chkconfig nagios on")
  
  %w|extra_commands linux|.each do |dir|
    dir_name = "/usr/local/nagios/etc/objects/#{dir}"
    machine.mkdir("dir_name" => dir_name)
    machine.chown("file_name" => dir_name, "ownership" => "nagios:")
    machine.append_to_file("file_name" => "/usr/local/nagios/etc/nagios.cfg", "content" => "cfg_dir=#{dir_name}")
  end
  
  machine.ssh "/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg" # TODO parse for "Things look okay"


  @op.with_machine("localhost") do |localhost|
    command_dir = @plugin.path + '/nagios_commands_local'
    localhost.list_files("directory" => command_dir).each do |nagios_command|
      machine.write_file(
        "target_filename" => '/usr/local/nagios/etc/objects/extra_commands/' + nagios_command, 
        "content" => localhost.read_file("file_name" =>  "#{command_dir}/#{nagios_command}"),
        "ownership" => "nagios:"
      )
    end
  end
  
  machine.generate_keypair("ssh_dir" => "/home/nagios/.ssh")
  machine.disable_ssh_key_check("home_dir" => "/home/nagios")
  machine.chown("file_name" => "/home/nagios/.ssh", "ownership" => "nagios:")
  
  own_public_key = @op.with_machine("localhost") do |localhost|
    localhost.list_authorized_keys.first
  end
  machine.append_to_file("file_name" => "/home/nagios/.ssh/authorized_keys", "content" => own_public_key)
  options = {
    "type" => "vm"
  }
  machine.ssh_options_for_machine.each do |k,v|
    options["ssh_#{k}"] = v 
  end
  options["ssh_user"] = "nagios"
  # TODO that's an ugly hack that doesn't survive if ~/.vop_known_machines is deleted/rewritten (could be that it's already not necessary anymore)
  options["name"] = "nagios@#{machine.name}"
  @op.add_known_machine(options)
  
  # TODO and in generate_nagios_config, we put the nagios public key onto the target machine
  
  @op.flush_cache()
  machine.start_unix_service("name" => "nagios")
  machine.restart_unix_service("name" => "httpd")
  
  machine.configure_reverse_proxy("domain" => params["domain"])
end
