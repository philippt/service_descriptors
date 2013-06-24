param :machine, "the proxy machine where the config should be generated", :mandatory => false
param :machine_group
param "blacklist", "machines for which config should not be generated", :allows_multiple_values => true, :default_value => []

add_columns [ :machine, :status ]

execute do |params|
  result = []
  @op.machines_in_group("machine_group" => params["machine_group"]).each do |row|
    result << { "machine" => row["name"], "status" => "unknown" }    
    if params["blacklist"].include? row["name"]
      result.last.merge!("status" => "ignored")
      next
    end
    begin
      # TODO handle timeout
      @op.with_machine(row["name"]) do |machine|
        machine.list_configured_vhosts.each do |vhost|
          p = {
            "machine" => row["name"], "domain" => vhost["domain"].strip
          }.merge_from params, :machine => :proxy
          pp p
          @op.configure_reverse_proxy(p)
          result.last.merge! p
        end
      end
      result.last["status"] = "ok"
    rescue => detail
      result.last["status"] = "error"
      result.last["error_message"] = detail.message
    end
  end
  result  
end
