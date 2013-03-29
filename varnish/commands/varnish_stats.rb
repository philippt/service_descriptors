description 'invokes varnishstat and parses the result'

param :machine

add_columns [ :key, :description, :value, :rate ]

on_machine do |machine, params|
  result = []
  machine.ssh("command" => "varnishstat -1").split("\n").each do |line|
    if matched = /(\S+)\s+(\d+)\s+([\d\.]+)\s+(.+)/.match(line)
      result << {
        "key" => matched.captures[0],
        "description" => matched.captures[3],
        "value" => matched.captures[1],
        "rate" => matched.captures[2],
      }  
    end
  end
  result
end
