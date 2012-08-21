description "restarts the apache on the associated proxy server (if any) of a machine"

param :machine

on_machine do |machine, params|
  if machine.proxy != nil
    @op.with_machine(machine.proxy) do |proxy|
      proxy.restart_unix_service("name" => "httpd")
    end
  end
end
