port 80
process_regex /httpd/
unix_service :httpd

on_install do |machine, service_root, params|
  machine.rm("file_name" => "/etc/httpd/conf.d/welcome.conf") if machine.file_exists("file_name" => "/etc/httpd/conf.d/welcome.conf")
    
  process_template(:httpd_conf, machine, "/etc/httpd/conf/httpd.conf", binding()) 
  
  machine.mkdir("dir_name" => '/etc/httpd/conf.d.generated')
end

