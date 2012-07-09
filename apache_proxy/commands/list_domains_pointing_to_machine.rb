description "returns the domains on which traffic will come in to this machine"

param :machine

display_type :list

on_machine do |machine, params|
  ip = machine.ipaddress
  
  @op.list_domains_configured_for_ip("machine" => machine.proxy, "ip" => ip)
end
