description "restores the local database(s) from a dump file. old data gets lost while doing so."

#add_columns [ :name, :date, :host ]
display_type :list

param :machine
param! "file_name", "a tarball (.tgz) holding the dump file (.dmp) that should be restored", :default_param => true
param "database", "a list of databases that should be restored (default: all)", :allows_multiple_values => true
param "dont_drop", "if set to true, will not drop any possibly existing local database with the same name", 
  :lookup_method => lambda { %w|true false| }, 
  :default_value => 'false'

on_machine do |machine, params|
  raise "no such file" unless machine.file_exists params["file_name"]
  
  file_name = params["file_name"]
  
  unless matched = /((.+?)\/([^\/]+))\.tgz$/.match(file_name)
    raise "unexpected dump file - not a tarball (at least not one ending in .tgz)"
  end
  path_to_dump = $1
  parent_dir = $2
  dump_name = $3
  
  machine.untar(
    "tar_name" => file_name,
    "working_dir" => parent_dir
  )
  
  # we're going to import database by database
  local_dbs = machine.list_databases.map { |x| x["name"] }
  
  the_databases = machine.list_dump_file_content(file_name)
  the_databases.each do |dump_file|
    next unless matched = /(.+)\.dmp/.match(dump_file)
    db_name = $1
    if blacklisted_db_names.include?(db_name)
      $logger.info("ignoring database #{db_name} (blacklisted)")
      next
    else
      # if the "database" parameter has been specified, we should restore only
      # if the database is listed there.
      if params.has_key?("database")
        whitelisted = params["database"]
        if not whitelisted.include?(db_name)
          $logger.info("ignoring database #{db_name} (not whitelisted)")
          next
        end
      end

      $logger.info("restoring database #{db_name}")

      if local_dbs.include?(db_name) && params["dont_drop"].to_s != 'true'
        machine.drop_database("database" => db_name)
        local_dbs.delete(db_name)
      end

      unless local_dbs.include? db_name
        machine.create_database db_name 
      end

      mysql_host = machine.db_host()
      full_name = path_to_dump + '/' + dump_file
      if machine.file_exists full_name
        machine.ssh "mysql #{mysql_credentials(machine, db_name)} -D#{db_name} -h #{mysql_host} < #{full_name}"
      end
    end
  end

  machine.rm({
    "file_name" => path_to_dump,
    "recursively" => "true"
  })

  the_databases  
end
