description "removes a vhost configuration file"

param :machine
param! "domain", "the domain name of the configuration file that should be removed"

on_machine do |machine, params|
  vhost = machine.list_configured_vhosts.select { |x| x["domain"] == params["domain"] }.first
  machine.rm("file_name" => vhost["file_name"])
  
  @op.without_cache do
    machine.list_configured_vhosts
  end
end


