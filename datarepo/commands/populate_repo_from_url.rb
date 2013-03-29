description "uses wget to slurp the content of another datarepo into the current one"

param :machine
param! "source_url", "the http URL from which to get the content"

on_machine do |machine, params|
  #machine.wget("target_dir" => "/var/www/html", "url" => params["source_url"])
  machine.ssh("command" => "cd /var/www/html && wget -r -l inf -nH -A tgz #{params["source_url"]}")
end
