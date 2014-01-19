param :machine, '', :default_param => true

add_columns [ :name, :messages_ready ]

on_machine do |machine, params|
  url = machine.service_details("service" => "rabbitmq/webinterface")["domain"]
  result = JSON.parse(@op.http_get("url" => "http://#{url}/api/queues", "user" => "guest", "password" => "guest"))
  result
end
