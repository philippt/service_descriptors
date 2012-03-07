description "imports links from the old bvdg database into drupal"

param "drupal_url", "the http URL to the drupal instance to be used", :mandatory => true
param "services_endpoint", "the name of the drupal services endpoint that should be used (the endpoint should include the 'user' resource)", :mandatory => true
param "drupal_user", "an existing drupal user with privileges to create new users", :mandatory => true
param "drupal_password", "the password associated to drupal_user", :mandatory => true

param! :machine
param! "database", "name of the database to read from"

on_machine do |machine, params|
  category_mapping = {
    1 => 54,
    5 => 55,
    11 => 56,
    13 => 57
  }
  
  input = mysql_xml_to_rhcp(machine.execute_sql("xml" => "true", "database" => params["database"], "statement" => "select * from links"))
  input.each do |row|
    $logger.debug("processing #{row["link"]}")
    p = {}
    %w|drupal_url services_endpoint drupal_user drupal_password|.each do |field|
      p[field] = params[field]
    end
    
    p["link"] = row["link"]
    p["description"] = row["link_desc"]
    p["category_id"] = category_mapping[row["katID"].to_i]
    
    @op.add_link(p)
  end
end
