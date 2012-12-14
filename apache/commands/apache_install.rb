description "installs an apache httpd server"

param :machine

on_machine do |machine, params|
  machine.rm("file_name" => "/etc/httpd/conf.d/welcome.conf") if machine.file_exists("file_name" => "/etc/httpd/conf.d/welcome.conf")
    
  if machine.linux_distribution.split("_").first == "centos"
    process_local_template(:httpd_conf, machine, "/etc/httpd/conf/httpd.conf", binding()) 
  end
  
  generated_dir = machine.apache_generated_conf_dir
  machine.mkdir("dir_name" => generated_dir) unless generated_dir == nil
  
  target_file_name = "/var/www/html/index.html"
  process_local_template(:index_html, machine, target_file_name, binding())
  machine.allow_access_for_apache("file_name" => target_file_name)
  
 if machine.linux_distribution.split("_").first == "sles"
    %w|proxy proxy_http|.each do |m|
      machine.ssh_and_check_result("command" => "a2enmod #{m}")
    end
    process_local_template(:custom_log, machine, "/etc/apache2/conf.d/logformat_vop.conf", binding())
  end
  
  #machine.add_static_vhost("server_name" => params["domain"], "document_root" => "/var/www/html")
end
