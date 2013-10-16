param :machine
param! "domain", "target domain thingy"
param "repo_dir", "the directory in which the repository data should be stored", :default_value => '/var/www/html'
param "datarepo_init_url", "http URL to initialize the datarepo from"
param "alias", "if set, the new data repo will be added to the installing vop's config"

as_root do |machine, params|
  machine.mkdir("dir_name" => params["repo_dir"])
  machine.allow_access_for_apache("file_name" => params["repo_dir"])
  machine.chmod("file_name" => params["repo_dir"], "permissions" => "g+w")
  
  domain = params["domain"]
twist = <<EOF
Dav On

<Limit PUT>
  Order allow,deny
  Allow from all
</Limit>

EOF
        
  machine.add_static_vhost("server_name" => domain, "document_root" => params["repo_dir"], "twist" => twist)
  machine.configure_reverse_proxy("domain" => domain) if machine.proxy

  # TODO that's only necessary if repo_dir == /var/www/html
  machine.as_user('root') do |root|  
    root.rm_if_exists("/var/www/html/index.html")
  end
  
  %w|dav dav_fs dav_lock|.each do |mod|
    if machine.linux_distribution.split("_").first == "sles"
      machine.ssh("sudo a2enmod #{mod}")
      
      dav_lock_dir = '/var/lib/apache2/dav'
      machine.mkdir dav_lock_dir
      machine.allow_access_for_apache dav_lock_dir
      machine.write_file(
        "target_filename" => "/etc/apache2/conf.d/dav_lock.conf", 
        "content" => "DAVLockDB #{dav_lock_dir}"
      )
    end
  end
  
  machine.restart_service 'apache/apache'
  
  if params.has_key?("datarepo_init_url")
    machine.populate_repo_from_url("source_url" => params["datarepo_init_url"])
  end
  
  if params.has_key?("alias")
    machine.add_data_repo(
      "alias" => params["alias"], 
      "url" => "http://#{params["domain"]}"
    )
  end
end
