param :machine

on_machine do |machine, params|
  search_dir = "#{@op.home('machine' => 'localhost')}/tmp"
  jres = @op.local_java_packages
  raise "no JREs found locally - searched on localhost in #{search_dir}" if jres.size == 0
  jre = jres.first
        
  target_dir = '/usr/local/lib/'
  machine.upload_file('local_file' => "#{search_dir}/#{jre}", 'target_file' => "#{machine.home}/tmp/#{jre}")
  machine.explode('tar_name' => "#{machine.home}/tmp/#{jre}", 'working_dir' => target_dir)
  
  installed = machine.find('path' => target_dir, 'type' => 'd', 'maxdepth' => 1, 'name' => 'jdk*')
  #installed = machine.list_files("#{target_dir}/jdk*")
  raise "could not find installed JDK in #{target_dir} after extracting - searched in #{target_dir}" if installed.size == 0
  path = installed.first
  
  unless machine.file_exists("#{target_dir}/java")
    machine.ssh("ln -s #{path} #{target_dir}/java")
  end  
  
  process_local_template(:manual_java, machine, '/etc/profile.d/manual_java.sh', binding())
end
