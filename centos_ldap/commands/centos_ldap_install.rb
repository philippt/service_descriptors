param :machine

param! "domain", "the domain for which the LDAP server should be configured (might be bollocks)"

on_machine do |machine, params|
  machine.ssh("command" => "useradd -m ldap")
  
  machine_short_name = machine.name.split('.').first
  
  external_full_name = "#{machine_short_name}.#{params["domain"]}"
  ldap_suffix = params["domain"].split(".").map { |x| "dc=#{x}" }.join(",")

  hosts_entry = "127.0.0.1 #{external_full_name} #{machine_short_name}"
  machine.append_to_file("file_name" => "/etc/hosts", "content" => hosts_entry)
  
  machine.append_to_file("file_name" => "/etc/resolv.conf", "content" => "search #{params["domain"]}")  
  
  process_local_template(:setup_ds_inf, machine, machine.home + '/tmp/setup_ds.inf', binding())
  machine.ssh "cp #{machine.home}/tmp/setup_ds.inf $HOME/setup_ds.inf.bak"
  
  machine.ssh("command" => "setup-ds.pl -s -f tmp/setup_ds.inf")
end
