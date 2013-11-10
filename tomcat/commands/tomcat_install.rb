description "tomcat-specific installation instructions"

param :machine

on_machine do |machine, params|
  if machine.linux_distribution.split("_").first == 'sles'
    machine.mkdir("dir_name" => "/srv/tomcat6/conf")
    machine.chown("file_name" => "/srv/tomcat6", "ownership" => "tomcat:root")
    machine.chmod("file_name" => "/srv/tomcat6", "permissions" => "g+w")
  end
  
  config_root = '/etc/tomcat6'
  if machine.file_exists config_root
    config_file = "#{config_root}/tomcat6.conf"
    if machine.file_exists config_file
      log4j_file = "#{config_root}/log4j.xml"
      
      process_local_template(:log4j, machine, log4j_file, binding())
      machine.chmod("file_name" => log4j_file, "permissions" => "g+rw,o+r")
      machine.chown("file_name" => log4j_file, "ownership" => "root.tomcat")
      
      machine.append_to_file('file_name' => config_file, 
        'content' => "JAVA_OPTS=\"${JAVA_OPTS} -Dlog4j.configuration=file:#{log4j_file}\"")
      # TODO switch for -Dlog4j.debug?
    end
  end
  
  machine.log4j_for_tomcat
end  
