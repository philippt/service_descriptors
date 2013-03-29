param :machine

on_machine do |machine, params|
  commands = [ "mkdir -p /usr/local/nagios/checks" ]
  if machine.linux_distribution.split("_").first == "ubuntu"
    commands.map! do |c|
      "sudo #{c}"
    end
    commands << "sudo chown -R ubuntu: /usr/local/nagios/checks"
  end 
  machine.ssh("command" => commands.join(" && "))
  
  target_dir = "/usr/local/nagios/checks"
  machine.wget(
    "target_dir" => target_dir,
    "ignore_certificate" => "true", 
    "url" => "https://raw.github.com/justintime/nagios-plugins/master/check_mem/check_mem.pl"
  )
  machine.chmod("file_name" => "#{target_dir}/*", "permissions" => "+x")
  
  #machine.add_service_config("service_description" => "memory", "check_command" => "check_mem_by_ssh")
  #@op.reload_nagios()
end
