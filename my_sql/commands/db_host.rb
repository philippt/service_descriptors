description "returns the machine to use as a database for the specified machine. can be used to externalize databases"

param :machine

on_machine do |machine, params|
  machine.name
end  
