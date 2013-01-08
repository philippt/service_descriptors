param :machine

on_machine do |machine, params|
  machine.ssh_and_check_result("command" => "sed -ie 's!^#cache_dir.*!cache_dir ufs /var/spool/squid 25600 16 256!' /etc/squid/squid.conf")
end
