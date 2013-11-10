description "installs java7 on a machine"

param :machine

on_machine do |machine, params|
  if /1.7.0/.match(machine.java_version)
    $logger.info "found java version #{machine.java_version}, no need to install anything."
  else
    if machine.linux_distribution.split('_').first == 'sles'
      installed = machine.list_installed_rpm_packages
  
      machine.ssh("command" => "zypper install -y jpackage-utils")
  
      base_url = 'http://download.opensuse.org/repositories/home:/cseader:/java-sun/SLE_11_SP1/x86_64/'
      packages = [
        'java-1_7_0-sun-1.6.0.ea.b104-3.1.x86_64.rpm',
        'java-1_7_0-sun-devel-1.6.0.ea.b104-3.1.x86_64.rpm'
      ]
  
      packages.each do |pkg|
        package_name = pkg.split("&").last.split("=").last
        puts "searching if package '#{package_name}' is already installed...."
        next if installed.select do |i|
          /^#{package_name}/.match(i["full_string"])
        end.size > 0
  
        machine.wget(
          "target_dir" => "/root/tmp",
          "url" => "#{base_url}/#{pkg}"
        )    
      end  
      if machine.file_exists("file_name" => "/root/tmp/*.rpm")
        machine.ssh("command" => "cd /root/tmp && rpm -Uvh *.rpm")
        machine.rm("file_name" => "/root/tmp/*.rpm")
      else
        puts "no RPMs to install - probably already installed."
      end        
    end
  end
  
  /1.7.0/.match(machine.java_version)
end
