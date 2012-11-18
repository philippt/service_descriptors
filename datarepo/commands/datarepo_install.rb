param :machine
param! "domain", "target domain thingy"
param! "repo_dir", "the directory in which the repository data should be stored"

on_machine do |machine, params|
  machine.mkdir("dir_name" => params["repo_dir"])
  machine.allow_access_for_apache("file_name" => params["repo_dir"])
  
  domain = params["domain"]
  machine.add_static_vhost("server_name" => domain, "document_root" => params["repo_dir"], "twist" => "Dav On")
  machine.configure_reverse_proxy("domain" => domain)
end
