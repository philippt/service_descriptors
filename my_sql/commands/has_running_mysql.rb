description "returns 'true' if there's a mysql instance running on the specified host"

param :machine
  
on_machine do |machine, params|
  machine.list_services_full.select do |service|
    service["name"] == "mysql" and service["is_running"] == true
  end.size > 0
end