description 'lists the virtual hosts that have been configured on this apache'

param :machine

add_columns [ :domain, :target_ip ]

mark_as_read_only

on_machine do |machine, params|
  result = []
  directory = "/etc/httpd/conf.d.generated/"
  machine.list_files("directory" => directory).each do |file_name|
    h = {}
    machine.ssh_and_check_result("command" => "cat #{directory}/#{file_name}").split("\n").each do |line|
      if matched = /ServerName\s+(.+)/.match(line)
        h["domain"] = matched.captures.first
      elsif matched = /ProxyPass\s+\/\s+(.+)/.match(line)
        h["target"] = matched.captures.first
        if inner_match = /^http\:\/\/(.+)\/$/.match(h["target"])
          h["target_ip"] = inner_match.captures.first
        end
      elsif matched = /DocumentRoot\s+(.+)/.match(line)
        h["document_root"] = matched.captures.first        
      end        
    end
    result << h
  end
  result
end
