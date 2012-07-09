param :machine

on_machine do |machine, params|
  process_local_template(:dropbox_py, machine, machine.home + "/dropbox.py", binding())
  machine.chmod("file_name" => machine.home + "/dropbox.py", "permissions" => "+x")
  
  machine.ssh_and_check_result("command" => 'cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -')
  
  t = Thread.new do
    machine.ssh("command" => "nohup ~/.dropbox-dist/dropboxd 2>&1 > ~/dropboxd.log &")
  end
  sleep 2
  
  machine.read_file("file_name" => "dropboxd.log").each do |line|
    if matched = /Please visit (http\S+) to link/.match(line)
      url = matched.captures.first
      @op.comment("message" => "should hit #{url} now")
      
      message = read_local_template(:mail, binding())    
      @op.send_mail("message" => message)
      break
    end
  end
  

  # TODO check output
  #Client successfully linked, Welcome Philipp!
  
  
  # TODO kill?
  #machine.processes

  
  # TODO make dropbox dir available for apache:
  # z_neu.cabildo.virtualop $ chown
  # chown.file_name $ /root
  # chown.ownership $ root:apache
  # 
  # z_neu.cabildo.virtualop $ chown
  # chown.file_name $ /root/Dropbox
  # chown.ownership $ root:apache
  # 
  # $ chmod
  # chmod.file_name $ /root/Dropbox
  # chmod.permissions $ g+rx
end
