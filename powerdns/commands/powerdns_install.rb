param :machine

param "domain", "if specified, the nameserver is preconfigured for the specified domain"

on_machine do |machine, params|
  process_local_template(:pdns_conf, machine, "/etc/powerdns/pdns.conf", binding())
  
  machine.create_database("name" => "powerdns") unless machine.list_databases.select { |x| x["name"] == "powerdns" }.size > 0
  
  sql = read_local_template(:database, binding())
  machine.execute_sql("database" => "powerdns", "statement" => sql)
  
  if params.has_key?("domain") and params["domain"] != null
    #machine.prepare_domain_config("domain" => params["domain"])
    #machine.add_domain_records("domain" => params["domain"], "ip" => params["ip"])
  end
end
