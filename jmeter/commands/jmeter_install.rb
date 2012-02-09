description "jmeter specific installation instructions"

param :machine

on_machine do |machine, params|
  machine.wget("target_dir" => "/root", "url" => "http://mirror.arcor-online.net/www.apache.org//jmeter/binaries/apache-jmeter-2.6.tgz")
  machine.untar("working_dir" => "/root", "tar_name" => "apache-jmeter*.tgz")
end
