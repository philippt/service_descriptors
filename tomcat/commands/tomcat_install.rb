description "tomcat-specific installation instructions"

param :machine

on_machine do |machine, params|
  #machine.ssh("command" => "zypper install -y tomcat6")
  machine.mkdir("dir_name" => "/srv/tomcat6/conf")
  machine.chown("file_name" => "/srv/tomcat6", "ownership" => "tomcat:root")
  machine.chmod("file_name" => "/srv/tomcat6", "permissions" => "g+w")
end  
