description "purges all proxy config entries that can not be found in the list of installed VMs on the corresponding host"

param :machine
param "just_kidding", "if set to 'true', the command will only be simulated"

result_as :list_configured_vhosts

on_machine do |machine, params|
  installed_ips = machine.list_installed_vms.map { |x| x["ipaddress"] }
  
  morituri = []
  proxy_name = "proxy." + machine.name
  @op.with_machine(proxy_name) do |proxy|
    morituri = proxy.list_configured_vhosts.select do |row|
      not installed_ips.include? row["target_ip"]
    end
    
    unless params["just_kidding"] == "true"
      morituri.each do |moriturus|
        proxy.delete_vhost_configuration("domain" => moriturus["domain"])    
      end
    end
  end
  
  morituri  
end


