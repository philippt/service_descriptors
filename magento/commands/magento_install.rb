param :machine
param! "domain", "the base domain at which the magento installation should be available"

on_machine do |machine, params|
  
  machine.wget("target_dir" => machine.home, "url" => "http://www.magentocommerce.com/downloads/assets/1.7.0.2/magento-1.7.0.2.tar.gz")
  machine.explode("tar_name" => "#{machine.home}/magento*.tar.gz", "working_dir" => "/var/www/html")
  
  service_root = "/var/www/html/magento"
  
  %w|media var|.each do |x|
    machine.chmod("file_name" => "#{service_root}/#{x}", "permissions" => "o+w")
  end
  # TODO this probably should not be recursive
  machine.chmod("file_name" => "#{service_root}/app/etc", "permissions" => "o+w")
   
  unless machine.list_databases.map { |x| x["name"] }.include? "magento"
    machine.create_database("name" => "magento")
    machine.execute_sql("statement" => "grant all on magento.* to 'magento_user'@'localhost' identified by 'magento_password'")
  end    
  
  #process_local_template(:local_xml, machine, "#{service_root}/app/etc/local.xml", binding())
  
  machine.add_static_vhost("document_root" => service_root, "server_name" => params["domain"])
  machine.restart_service 'apache/apache'
  machine.configure_reverse_proxy("domain" => params["domain"], "timeout" => "300")
end  
