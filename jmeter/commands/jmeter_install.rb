description "jmeter specific installation instructions"

param :machine

on_machine do |machine, params|
  #process_local_template(:path, machine, "/etc/profile.d/jmeter_path.sh", binding())
  
  machine.wget("target_dir" => machine.home, "url" => "http://mirror.arcor-online.net/www.apache.org//jmeter/binaries/apache-jmeter-2.6.tgz")
  machine.untar("working_dir" => machine.home, "tar_name" => "apache-jmeter*.tgz")
end
