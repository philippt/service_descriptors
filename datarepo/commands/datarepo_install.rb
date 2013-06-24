param :machine
param! "domain", "target domain thingy"
param "repo_dir", "the directory in which the repository data should be stored", :default_value => '/var/www/html'
param "datarepo_init_url", "http URL to initialize the datarepo from"
param "alias", "if set, the new data repo will be added to the installing vop's config"

on_machine do |machine, params|
  machine.mkdir("dir_name" => params["repo_dir"])
  machine.allow_access_for_apache("file_name" => params["repo_dir"])
  
  domain = params["domain"]
  machine.add_static_vhost("server_name" => domain, "document_root" => params["repo_dir"], "twist" => "Dav On")
  machine.configure_reverse_proxy("domain" => domain)

  machine.rm("file_name" => "/var/www/html/index.html")
  machine.restart_service("service" => "apache")
  
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
