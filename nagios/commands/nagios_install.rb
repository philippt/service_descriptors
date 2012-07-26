description "nagios install script"

param :machine

on_machine do |machine, params|
  machine.ssh_and_check_result("command" => "useradd -m nagios")
  machine.ssh_and_check_result("command" => "/usr/sbin/groupadd nagcmd")
  machine.ssh_and_check_result("command" => "/usr/sbin/usermod -a -G nagcmd nagios")
  machine.ssh_and_check_result("command" => "/usr/sbin/usermod -a -G nagcmd apache")
  
  machine.mkdir("dir_name" => "/root/downloads")
  machine.wget("url" => "http://prdownloads.sourceforge.net/sourceforge/nagios/nagios-3.3.1.tar.gz", "target_dir" => "/root/downloads")
  machine.wget("url" => "http://sourceforge.net/projects/nagiosplug/files/latest/download?source=files", "target_dir" => "/root/downloads")
  
  machine.explode("tar_name" => "/root/downloads/nagios-3.3.1.tar.gz", "working_dir" => "/root/downloads")
  machine.explode("tar_name" => "/root/downloads/nagios-plugins-1.4.15.tar.gz", "working_dir" => "/root/downloads")
  
  machine.ssh_and_check_result("command" => "cd /root/downloads/nagios && ./configure --with-command-group=nagcmd")
  machine.ssh_and_check_result("command" => "cd /root/downloads/nagios && make all")
  
  %w|install install-init install-commandmode install-config|.each do |phase|
    machine.ssh_and_check_result("command" => "cd /root/downloads/nagios && make #{phase}")
  end
  
  #/usr/local/nagios/etc/objects/contacts.cfg
  
  machine.ssh_and_check_result("command" => "cd /root/downloads/nagios && make install-webconf")
  machine.ssh_and_check_result("command" => "htpasswd -cb /usr/local/nagios/etc/htpasswd.users nagiosadmin the_password")
  
  machine.ssh_and_check_result("command" => "cd downloads/nagios-plugins-1.4.15 && ./configure --with-nagios-user=nagios --with-nagios-group=nagios && make && make install")
  
  machine.ssh_and_check_result("command" => "chkconfig --add nagios")
  machine.ssh_and_check_result("command" => "chkconfig nagios on")
  
  machine.append_to_file("file_name" => "/usr/local/nagios/etc/nagios.cfg", "content" => "cfg_dir=/usr/local/nagios/etc/objects/extra_commands")
  machine.append_to_file("file_name" => "/usr/local/nagios/etc/nagios.cfg", "content" => "cfg_dir=/usr/local/nagios/etc/objects/linux")
  
  machine.ssh_and_check_result("command"=> "/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg") # TODO parse for "Things look okay"
  
  machine.start_unix_service("name" => "nagios")
  
  machine.start_unix_service("name" => "httpd")
end
