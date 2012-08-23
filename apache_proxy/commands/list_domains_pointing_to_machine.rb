description "returns the domains on which traffic will come in to this machine"

param :machine, "", :allows_multiple_values => true

display_type :list

mark_as_read_only

include_for_crawling

execute do |params|
  result = []
  params["machine"].each do |machine_name|
    @op.with_machine(machine_name) do |machine|
      ip = machine.ipaddress
      proxy = machine.proxy
      
      if proxy != nil
        result += @op.list_domains_configured_for_ip("machine" => proxy, "ip" => ip)
      end
    end
  end
  result
end
