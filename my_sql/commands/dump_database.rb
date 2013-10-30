description "will create a dump from the local mysql databases"

param :machine
param :multiple_optional_databases, "a list of local databases that should be dumped (defaults to '*')", :default_param => true
# the dump_name param makes unit tests much easier, otherwise it probably does not make sense
param "dump_name", "the name of the dump directory to be created"
param "as_tsv", "if 'true' exports the database in tab-separated value format", { 
          :lookup_method => lambda {
            [ "true", "false" ]
          }
        }
param "table_whitelist", "an optional list of table names that should be dumped. if specified, then exactly one database needs to be selected", :allows_multiple_values => true
param "table_blacklist", "an optional list of table names that should not be dumped. if specified, then exactly one database needs to be selected", :allows_multiple_values => true
param "target_filename", "the fully qualified filename into which the dump should be written."
param "skip_check", "if set to 'true', will not check afterwards (using list_dumps) if the dump has been created.", {
		:lookup_method => lambda do
          %w|true false|
        end
      }
param "dont_drop", "if set to 'true', will not write DROP TABLE statements before CREATE (mysqldump 'add-drop-table')"      
      
on_machine do |machine, params|
  # TODO if there are other dumps, estimate the needed diskspace and bail out if necessary

  # first, get the current list of dumps and store it for later comparison
  dumps_before = []
  @op.without_cache do
    dumps_before = machine.list_dumps()
  end    
  $logger.debug "got #{dumps_before.size} dumps before : #{dumps_before}"

  # prepare default dir and filename
  dump_name = params.has_key?("dump_name") ?
    params["dump_name"] :
    "db_backup-" + machine.name + '-' + Time.now().strftime("%Y%m%d%H%M")    
  target_dir_name = dump_dir + '/' + dump_name
  
  # allow for overriding the target filename
  if params.has_key?("target_filename")
    target_dir_name = File.dirname(params["target_filename"]) + "/" + File.basename(params["target_filename"]) 
    dump_name = File.basename(params["target_filename"])
  end
  
  $logger.info "gonna create new dump called '#{dump_name}' in '#{target_dir_name}'"

  # check that the dump does not exist locally yet
  existing_dumps = dumps_before.select do |item|
    item["name"] == dump_name
  end
  if existing_dumps.size() > 0
    raise Exception.new("dump #{dump_name} exists already. could it be that you already created a dump in this minute?")
  end

  machine.mkdir("dir_name" => target_dir_name) unless machine.file_exists("file_name" => target_dir_name)

  # now create the dumps for all local databases
  local_dbs = machine.list_databases.select do |item|
    not blacklisted_db_names.include?(item["name"])
  end.collect do |item|
    item["name"]
  end

  # if a list of databases has been specified, dump these and not all
  # local databases
  if params.has_key?("database")
    local_dbs = params["database"]
  end
  
  if local_dbs.size != 1 and params.has_key?('table_whitelist')
    raise Exception.new("multiple databases and table_whitelist specified. won't work, sorry.")
  end
  if local_dbs.size != 1 and params.has_key?('table_blacklist')
    raise Exception.new("multiple databases and table_blacklist specified. won't work, sorry.")
  end
  
  if params.has_key?('table_blacklist') and params.has_key?('table_whitelist')
    raise Exception.new("found both black and white list...please use only one of them")
  end

  # dump each specified database
  local_dbs.each do |db_name|
    
    # we've got two possible ways for dumping : standard 'mysqldump' or export as tab-separated values
    if (params.has_key?('as_tsv') && (params['as_tsv'] == "true"))
      target_dir = target_dir_name + "/" + db_name
      machine.ssh("command" => "mkdir #{target_dir}")
      machine.ssh("command" => "chmod 777 #{target_dir}")
      machine.show_tables("database" => db_name).each do |table|
        table_file_name = target_dir + '/' + table["name"] + '.tsv'
        command = "SELECT * FROM #{table["name"]} INTO OUTFILE '#{table_file_name}'"
        machine.execute_sql("statement" => command, "database" => db_name)
      end
      
      structure_dump_file = target_dir + '/schema.sql'
      machine.ssh("command" => "mysqldump --no-data #{mysql_credentials(machine, db)} #{db_name} > #{structure_dump_file}")
    else        
      target_file = target_dir_name + "/" + db_name + ".dmp"
      
      options = ''
      if params["dont_drop"].to_s == 'true'
        options += ' --add-drop-table=false'
      end
      command = "mysqldump #{mysql_credentials(machine, db_name)} #{options} #{db_name}"
      
      if params.has_key?('table_whitelist')        
        command += " " + params['table_whitelist'].join(" ")
      elsif params.has_key?('table_blacklist')
        whitelist = machine.show_tables("database" => db_name).select do |table|
          not params['table_blacklist'].include?(table["name"])
        end.map do |table|
          table["name"]
        end
        command += " " + whitelist.join(" ")
      end
      command += " > #{target_file}"
      
      machine.ssh("command" => command)
      if params["dont_drop"].to_s == 'true'
        machine.replace_in_file("file_name" => target_file, "source" => 'CREATE TABLE', "target" => 'CREATE TABLE IF NOT EXISTS')
      end
    end
  end

  # and tar the whole directory afterwards
  machine.implode({
    "tar_name" => target_dir_name + ".tgz",
    "working_dir" => File.dirname(target_dir_name),
    "files" => dump_name
  })

  unless params.has_key?("skip_check") and params["skip_check"] == 'true'
    # and get the new list of dumps
    dumps_after = []
    @op.without_cache do
      dumps_after = machine.list_dumps()
    end
          
    dumps_after.sort! do |a,b|
      a["date"] <=> b["date"]
    end
    $logger.debug "got #{dumps_after.size} dumps after"

    # check if the dump appears in list_dumps afterwards
    candidates = dumps_after.select do |candidate|
      candidate["name"] == dump_name
    end
    raise "could not find newly created dump '#{dump_name}' in list_dumps!\nfound dumps:\n#{candidates.map { |c| c["name"] }.join("\n")}" unless candidates.size > 0

    # TODO compare the size of the new dump against the last dump
    # TODO check if the date of the created dump matches our expectations
  end

  # return the name of the dump that we created
  dump_name
end