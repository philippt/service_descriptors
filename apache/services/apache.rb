port 80
#process_regex(/httpd/)

names = {
  "centos" => "httpd",
  "amazon" => "httpd",
  "sles" => "apache2",
  "ubuntu" => "apache2"
}
unix_service names

log_file "/var/log/httpd/access_log", :format => "combined"

on_install do |machine, service_root, params|
  machine.rm("file_name" => "/etc/httpd/conf.d/welcome.conf") if machine.file_exists("file_name" => "/etc/httpd/conf.d/welcome.conf")
    
  process_template(:httpd_conf, machine, "/etc/httpd/conf/httpd.conf", binding()) 
  
  machine.mkdir("dir_name" => '/etc/httpd/conf.d.generated')
end

