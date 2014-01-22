description "returns the virtual hosts reported by apache(ctl)"

param :machine

#mark_as_read_only

on_machine do |machine, params|
  tool_name = nil
  %w|apachectl apache2ctl|.each do |candidate|
    result = machine.ssh_extended("which apachectl")
    if result["result_code"] == 0
      tool_name = candidate
      break
    end  
  end
  
  machine.ssh "#{tool_name} -t -D DUMP_VHOSTS"
end  
