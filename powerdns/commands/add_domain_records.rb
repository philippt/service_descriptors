description "adds forward and reverse entries for a domain"

param :machine
param! "domain", "name of the domain that should be resolved"
param! "ip", "target IP address"

on_machine do |machine, params|
  data = mysql_xml_to_rhcp machine.execute_sql("database" => "powerdns", "statement" => "select id from domains where name = '#{params["domain"]}'", "xml" => "true")
  id = data.first["id"]
  
  [
    "insert into records (domain_id, name, type, content, ttl) values (#{id}, '#{params["domain"]}', 'A', '#{params["ip"]}', 86400)"
    # TODO add PTR (i'll hate myself for that)
  ].each do |statement|
    machine.execute_sql("database" => "powerdns", "statement" => statement)
  end
end
