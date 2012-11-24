description "prepares a powerdns instance to host a domain"

param :machine
param! "domain", "name of the domain that should be resolved"

on_machine do |machine, params|
  machine.execute_sql("database" => "powerdns", "statement" => "insert into domains (name) values ('#{params["domain"]}')")
  data = mysql_xml_to_rhcp machine.execute_sql("database" => "powerdns", "statement" => "select id from domains where name = '#{params["domain"]}'", "xml" => "true")
  id = data.first["id"]
  
  [
    "insert into records (domain_id, name, type, content, ttl) values (#{id}, '#{params["domain"]}', 'SOA', 'localhost #{machine.name} 1', 86400)",
    "insert into records (domain_id, name, type, content, ttl) values (#{id}, '#{params["domain"]}', 'NS', 'ns1.#{params["domain"]}', 86400)",
    "insert into records (domain_id, name, type, content, ttl) values (#{id}, '#{params["domain"]}', 'NS', 'ns2.#{params["domain"]}', 86400)",
  ].each do |statement|
    machine.execute_sql("database" => "powerdns", "statement" => statement)
  end
end
