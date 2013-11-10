param :machine

on_machine do |machine, params|
  result = nil
  
  begin
    output = machine.ssh "java -version"
                 #java version "1.6.0_24"
    if matched = /java version \"([\w\.]+)_(\d+)\"/.match(output)
      result = matched.captures.first
    end 
  rescue
  end
  result
end
