param :machine

param! "external_domain", "the domain for which the LDAP server should be configured (might be bollocks)"

on_machine do |machine, params|
  machine.ssh_and_check_result("command" => "useradd -m ldap")
  
  machine_short_name = machine.name.split('.').first
  
  external_full_name = "#{machine_short_name}.#{params["external_domain"]}"
  ldap_suffix = params["external_domain"].split(".").map { |x| "dc=#{x}" }.join(",")

  hosts_entry = "127.0.0.1 #{external_full_name} #{machine_short_name}"
  machine.append_to_file("file_name" => "/etc/hosts", "content" => hosts_entry)
  
  machine.append_to_file("file_name" => "/etc/resolv.conf", "content" => "search #{params["external_domain"]}")  
  
  process_local_template(:setup_ds_inf, machine, machine.home + '/tmp/setup_ds.inf', binding())
  
  machine.ssh_and_check_result("command" => "setup-ds.pl -s -f tmp/setup_ds.inf")
end
