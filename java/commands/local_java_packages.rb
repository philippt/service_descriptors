execute do |params|
  @op.with_machine('localhost') do |machine|
    machine.list_files(machine.home + '/tmp').select do |file|
      /server-jre-.+-linux-x64.tar.gz/.match(file)
    end
  end
end
