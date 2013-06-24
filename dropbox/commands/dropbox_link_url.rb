description "returns the URL that needs to be hit for the dropbox to be linked (or an empty string)"

param :machine

on_machine do |machine, params|
  result = ''
  machine.read_file("file_name" => "log/dropbox.log").split("\n").each do |line|
    if matched = /Please visit (http\S+) to link/.match(line)
      result = matched.captures.first
      #break
    end
  end
  result
end