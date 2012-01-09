description "installs an apache httpd server"

param :machine

on_machine do |machine, params|
  machine.rm("file_name" => "/etc/httpd/conf.d/welcome.conf") if machine.file_exists("file_name" => "/etc/httpd/conf.d/welcome.conf")
    
  process_local_template(:httpd_conf, machine, "/etc/httpd/conf/httpd.conf", binding()) 
  
  machine.mkdir("dir_name" => '/etc/httpd/conf.d.generated')
end
