description 'lists the virtual hosts that have been configured on this apache'

param :machine

add_columns [ :domain, :target_ip, :document_root, :file_name ]

mark_as_read_only

on_machine do |m, params|
  result = []
  # TODO we could think about carefully trying to include "/etc/httpd/conf.d/" (avoiding stuff like php.conf)
  m.as_user("user_name" => "root") do |machine|
    [ machine.apache_generated_conf_dir ].each do |directory|
      machine.list_files("directory" => directory).each do |file_name|
        
        next unless /\.conf$/.match(file_name.strip)
        
        h = {
          "file_name" => directory + "/" + file_name
        }
        machine.read_lines(h).each do |line|
          if matched = /ServerName\s+(.+)/.match(line)
            h["domain"] = matched.captures.first
          elsif matched = /ProxyPass\s+\/\s+(.+)/.match(line)
            h["target"] = matched.captures.first
            if inner_match = /^http\:\/\/(.+)\/$/.match(h["target"])
              h["target_ip"] = inner_match.captures.first
            end
          elsif matched = /DocumentRoot\s+(.+)/.match(line)
            h["document_root"] = matched.captures.first
          elsif matched = /CustomLog\s+(.+)\s+(.+)/.match(line)
            h["log_path"] = matched.captures.first
            h["log_format"] = matched.captures.last        
          end        
        end
        h.values.each do |x| 
          x.strip!
        end
        result << h unless h.keys.size == 0
      end
    end
  end
  result
end
