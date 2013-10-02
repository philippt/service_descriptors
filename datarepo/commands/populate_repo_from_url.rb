description "uses wget to slurp the content of another datarepo into the current one"

param :machine
param! "source_url", "the http URL from which to get the content"

on_machine do |machine, params|
  machine.ssh "cd #{machine.datarepo_dir} && wget -r -l inf -nH -A tgz #{params["source_url"]}"
end
