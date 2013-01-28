param :machine
param! "domain", "http domain for the admin web interface"

on_machine do |machine, params|
  # TODO dirty java6 dependency
  machine.append_to_file("file_name" => "/etc/sysconfig/openfire", "content" => "JAVA_HOME=/usr/lib/jvm/jre-1.6.0-openjdk.x86_64")
end
