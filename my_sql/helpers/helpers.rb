#include Bash::BashHelper
    
def blacklisted_db_names
  [ "mysql", "information_schema", "lost+found", "test" ]
end

def mysql_user_dropdir
  "/etc/xop/mysql/users.d"
end

def mysql_xml_to_rhcp(data)
  xml_data = XmlSimple.xml_in(data)
  result = []
  if xml_data.has_key?('row')
    xml_data['row'].each do |row|
      the_row = {}
      row['field'].each do |field|
        the_row[field["name"]] = field["content"] || ""
      end

      result << the_row
    end
  end
  result
end

def mysql_xml_to_rhcp_graph(data)
  xml_data = XmlSimple.xml_in(data)
  result = []
  if xml_data.has_key?('row')
    xml_data['row'].each do |row|
      
      # sanity check: every row should have two columns
      raise Exception("expecting resultset with two (numerical) columns") unless row['field'].size() == 2
      
      result << [
        # TODO actually, the conversion (* 1000) should take place somewhere in the webapp
        row['field'].first['content'].to_i * 1000,
        row['field'].last['content'].to_f
      ]
    end
  end
  # TODO also, we shouldn't have to convert to json here, i think
  result.to_json
end

def dump_dir
  # TODO merge with local_backup_dir from data_repo
  s = config_string('dump_dir', '$HOME/tmp')
  s += '/' unless /\/$/.match(s)
  s
end

def mysql_user(host, db_name = nil)
  config_string('mysql_user', 'root')
end

def mysql_password(host, db_name = nil)      
  # can't throw in nil to config_string, thus this indirect thingy
  configured_password = config_string('mysql_password', '')
  configured_password != '' ? 
    configured_password : 
    nil
end

def mysql_credentials(machine, db_name = nil)
  options = machine.mysql_options
  
  result = "-u" + options["mysql_user"]
  password = options["mysql_password"]
  if password != nil
    result += " -p" + password
  end
  if options["mysql_socket"] != nil
    result += " -S" + options["mysql_socket"]
  end
  result
end

def mysql_socket(machine)
  config_string('mysql_socket', '')
end