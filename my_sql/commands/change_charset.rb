param :machine
param :database, "the database against which the statement should be executed", :mandatory => false
param! "table", "the table to work with", :lookup_method => lambda { |request|
  @op.show_tables("machine" => request.get_param_value("machine"), "database" => request.get_param_value("database")).map { |x| x["name"] } 
}, :allows_multiple_values => true
param "character_set", "the character set (optionally with collation) that should be set", :default_value => 'utf8 collate utf8_unicode_ci'

# thanks to http://stackoverflow.com/questions/742205/mysql-alter-table-collation
on_machine do |machine, params|
  params["table"].each do |table|
    machine.execute_sql(
      "database" => params["database"], 
      "statement" => "ALTER TABLE #{table} convert to character set #{params["character_set"]}"
    )
  end
end
