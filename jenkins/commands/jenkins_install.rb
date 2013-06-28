param :machine
param "domain", "the domain at which jenkins should be available"

as_root do |machine, params|
  @op.flush_cache
  if machine.file_exists("file_name" => "/etc/sysconfig/jenkins")
    machine.ssh("command" => "sed -i -e 's/JENKINS_USER=\"jenkins\"/JENKINS_USER=\"root\"/g' /etc/sysconfig/jenkins")
  end    
  machine.start_unix_service("name" => "jenkins")
end
