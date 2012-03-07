param :machine

on_machine do |machine, params|
  process_local_template(:dropbox_py, machine, machine.home + "/dropbox.py", binding())
  machine.chmod("file_name" => machine.home + "/dropbox.py", "permissions" => "+x")
  
  machine.ssh_and_check_result("command" => "cd ~ && wget -O - http://www.dropbox.com/download?plat=lnx.x86_64 | tar xzf -")
  machine.ssh_and_check_result("command" => "nohup ~/.dropbox-dist/dropboxd 2>&1 > ~/dropboxd.log &")
  
  # TODO read output:
  #This client is not linked to any account...
  #Please visit https://www.dropbox.com/cli_link?host_id=d19507b8a008b05f1c5308da0fbd1203&cl=en_US to link this machine.

  # TODO link server

  # TODO check output
  #Client successfully linked, Welcome Philipp!

  # TODO run ~/.dropbox-dist/dropbox to sync
  
  
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
