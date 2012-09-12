description "returns the name of the proxy living on the same host as the specified VM"

param :machine

mark_as_read_only

on_machine do |machine, params|
  # TODO handle localhost
  host_name = machine.name.split('.')[1..10].join('.')
  hypothetical_name = "proxy." + host_name  
  @op.list_machines.select { |x| x["name"] == hypothetical_name }.size > 0 ?
    hypothetical_name : nil  
end
