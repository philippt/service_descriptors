param :machine
#param :service_root
#param :domain

on_machine do |machine, params|
  #process_template(:settings_conf, machine, "#{params["service_root"]}/sites/default/settings.php", binding())

  #machine.mkdir("dir_name" => "#{params["service_root"]}/sites_default/files")
  #machine.chown("file_name" => ...  

  #machine.add_reverse_proxy("domain" => params["domain"])
  #machine.configure_reverse_proxy("domain")
end
