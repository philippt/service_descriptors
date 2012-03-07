param :machine

on_machine do |machine, params|
  machine.ssh_and_check_result("command" => "sudo mkdir -p /usr/local/nagios/checks && sudo chown -R ubuntu: /usr/local/nagios/checks")
  target_dir = "/usr/local/nagios/checks"
  machine.wget(
    "target_dir" => target_dir,
    "ignore_certificate" => "true", 
    "url" => "https://raw.github.com/justintime/nagios-plugins/master/check_mem/check_mem.pl"
  )
  machine.chmod("file_name" => "#{target_dir}/*", "permissions" => "+x")
end
