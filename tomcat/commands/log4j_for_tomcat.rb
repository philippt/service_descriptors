param :machine

on_machine do |machine, params|
   # TODO adapt for SLES
  if machine.linux_distribution.split("_").first == 'centos'
    tc_files = machine.ssh("rpm -ql tomcat6").split("\n")
    
    found = {}
    tc_version = nil
    tc_files.each do |file|
      puts file
      if matched = /((bin|lib)\/(tomcat-juli(?:-(.+))?.jar))/.match(file)
        dir = matched.captures[1]
        found[dir] = [] unless found[dir]
        found[dir] << {
          :full => matched.captures[0],
          :name => matched.captures[2]
        }
        tc_version = matched.captures[3] if matched.captures[3]
      end
    end
    $logger.info "tomcat version : #{tc_version}" if tc_version
    
    tc_home = machine.ssh('. /etc/tomcat6/tomcat6.conf && echo $CATALINA_HOME').split("\n").first.strip.chomp
    
    if tc_version and tc_home
      $logger.info "configuring tomcat #{tc_version} in #{tc_home} for log4j"
      
      if found['bin']
        found['bin'].select { |x| /tomcat-juli.jar$/ =~ x[:name] }.each do |x|
          machine.rm_if_exists [tc_home,x[:full]].join('/')
        end
        found['bin'].select { |x| /tomcat-juli-([\d\.]+).jar$/ =~ x[:name] }.each do |x|
          machine.rm_if_exists [tc_home,x[:full]].join('/')
        end
      end
      
      if found['lib']
        found['lib'].select { |x| /tomcat-juli-([\d\.]+).jar$/ =~ x[:name] }.each do |x|
          machine.rm_if_exists [tc_home,x[:full]].join('/')
        end
      end
      
      base_url = "http://archive.apache.org/dist/tomcat/tomcat-6/v#{tc_version}/bin/extras/"
      machine.wget('url' => "#{base_url}/tomcat-juli-adapters.jar", 'target_dir' => "#{tc_home}/lib")
      machine.wget('url' => "#{base_url}/tomcat-juli.jar", 'target_dir' => "#{tc_home}/bin")
    end
  end
end  
