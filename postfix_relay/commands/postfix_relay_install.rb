param :machine

param! "smtp_relay_host"
param! "smtp_username"
param! "smtp_password"

# see http://blog.earth-works.com/2013/05/14/postfix-relay-using-gmail-on-centos/
# see http://priority-zero.blogspot.de/2013/03/postfix-with-gmail.html
on_machine do |machine, params|
  process_local_template(:sasl_passwd, machine, "/etc/postfix/sasl_passwd", binding())
  machine.chown("file_name" => "/etc/postfix", "ownership" => "postfix")
  machine.ssh "postmap hash:/etc/postfix/sasl_passwd"
  
  main_cf = read_local_template(:main_cf, binding())
  machine.append_to_file("file_name" => "/etc/postfix/main.cf", "content" => main_cf)
  
  machine.restart_unix_service "postfix"
end
