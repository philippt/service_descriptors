param :machine

on_machine do |machine, params|
  details = machine.service_details("service" => "datarepo")
  vhost = machine.list_configured_vhosts.select { |x| x["domain"] == details["domain"] }.first
  vhost["document_root"]
end
