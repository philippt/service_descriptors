description "removes temporary files so that tomcat can be started from a clean baseline"

param :machine

on_machine do |machine, params|
  machine.rm("recursively" => "true", "file_name" => "/srv/tomcat6/webapps/*")
  # TODO add tmp ?
end