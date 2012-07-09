description "returns the name of the proxy living on the same host as the specified VM"

param :machine

on_machine do |machine, params|
  host_name = machine.name.split('.')[1..10].join('.')
  "proxy." + host_name  
end
