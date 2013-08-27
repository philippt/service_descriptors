param :machine
param "domain", "the domain at which jenkins should be available"

param "jenkins_user", "name of the system account that the jenkins process should run as", :default_value => "jenkins"

as_root do |machine, params|
  @op.flush_cache
  
  if machine.file_exists("file_name" => "/etc/sysconfig/jenkins")    
    machine.ssh("sed -i -e 's/JENKINS_USER=\".*\"/JENKINS_USER=\"#{params["jenkins_user"]}\"/g' /etc/sysconfig/jenkins")
  end
  
  %w|/var/lib/jenkins/ /var/cache/jenkins/ /var/log/jenkins/|.each do |dir_name|
    if machine.file_exists dir_name
      machine.chown(
        "file_name" => dir_name, 
        "ownership" => params["jenkins_user"]
      )
    end
  end
  #machine.start_unix_service("name" => "jenkins")
end
