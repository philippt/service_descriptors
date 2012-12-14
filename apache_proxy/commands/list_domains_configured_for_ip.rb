description "returns the domains that will be proxied to the specified IP address when called"

param :machine
param! "ip", "the target IP address"

display_type :list

on_machine do |machine, params|
  machine.list_configured_vhosts.select do |vhost|
    vhost["target_ip"] == params["ip"]
  end.map { |x| x["domain"] }
end
