description "installs an apache httpd server"

param :machine
param :service_root

on_machine do |machine, params|
  #machine.install_rpm_package("name" => "httpd")
    
  process_template(:httpd_conf, machine, "/etc/httpd/conf/httpd.conf", binding())
  
  machine.mkdir("dir_name" => '/etc/httpd/conf.d.generated')
end
