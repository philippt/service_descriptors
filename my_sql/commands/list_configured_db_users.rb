description "lists all database users that should be configured on this machine (reads /etc/xop/mysql/users.d)"

param :machine

add_columns [ :name, :privilege, :db, :tables, :host, :password ]

on_machine do |machine, params|
  result = [] 
  with_files(machine, mysql_user_dropdir, '*', 'root') do |file|
    result << {
      "name" => file
    }

    file_name = mysql_user_dropdir + '/' + file
    config_file = machine.ssh(
      "command" => "cat #{file_name}",
      "user" => "root"
    )
    config = YAML.load(config_file)

    [ "privilege", "db", "tables", "host", "password" ].each do |field|
      result.last[field] = config[field]
    end
  end
  result
end  