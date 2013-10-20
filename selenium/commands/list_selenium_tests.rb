param :machine

#display_type :list

add_columns [ "name", "type" ]

on_machine do |machine, params|
  result = []
  
  machine.find("path" => "tests", "type" => "f").each do |x|
    x.strip!
    if matched = /tests\/(.+)\.(.+)?/.match(x)
      result << {
        "file_name" => x,
        "name" => matched.captures.first,
        "type" => matched.captures.last || 'unknown'
      } 
    end
  end
  
  result
end  
