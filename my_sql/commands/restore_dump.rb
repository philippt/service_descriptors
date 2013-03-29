description "restores the local database(s) from a dump. old data gets lost while doing so."

add_columns [ :name, :date, :host ]

param :machine
param! :dump, "the dump from which we're going to restore"
param "database", "a list of databases that should be restored (default: all)", :allows_multiple_values => true
#param :mysql_host

on_machine do |machine, params|
  dump_name = params["dump_name"]
  $logger.info("restoring local databases from dump " + dump_name)
  path_to_dump = dump_dir + '/' +  dump_name
  path_to_tarred_dump = path_to_dump + ".tgz"

  # check which databases we've got locally
  local_dbs = machine.list_databases.collect do |item|
    item["name"]
  end

  dump_has_been_extracted = false
  if not machine.file_exists({"file_name" => path_to_dump})
    if machine.file_exists({"file_name" => path_to_tarred_dump})
      machine.untar({
        "tar_name" => path_to_tarred_dump,
        "working_dir" => dump_dir
      })
      dump_has_been_extracted = true
    end
  end

  # we're going to import database by database
  the_databases = machine.list_dump_content({
    "dump_name" => dump_name
  })
  the_databases.each do |item|
    db_name = item["name"]
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

      # drop the existing db if it exists
      if local_dbs.include?(db_name)
        machine.drop_database("database" => db_name)
      end

      machine.create_database(
        "name" => db_name
      )

      dump_file = path_to_dump + "/" + db_name + ".dmp"

      # the dump file may be tarred - check if this is the case and untar
      # if necessary
      might_have_extracted_tarball = false # probably not
      tarball_name = dump_file + ".tgz"
      begin
        database_dir_name = path_to_dump + '/' + db_name
        schema_file = database_dir_name + '/schema.sql'
        if not machine.file_exists({"file_name" => dump_file})
          $logger.debug "plain dump file #{dump_file} not found, looking for tarball at #{tarball_name}"
          tarball_exists = machine.file_exists({"file_name" => tarball_name})
          if tarball_exists
            $logger.info "temporarily extracting tarball #{tarball_name} in order to restore it..."
            might_have_extracted_tarball = true
            machine.untar({
              "tar_name" => tarball_name,
              "working_dir" => path_to_dump,
            })
          else
            if machine.file_exists("file_name" => schema_file)
              $logger.info "found schema.sql file for database #{db_name}"                
            else
              raise Exception.new("[BUG] list_dump_content returned dump #{db_name}, but I cannot find neither a dump nor a tarball at #{dump_file} or #{tarball_name}")
            end
          end
        end

        # now we might have either .dmp files per db or a directory per db containing tsv files
        mysql_host = machine.db_host()
        if machine.file_exists("file_name" => dump_file)
          # => oldschool mysql dumps
          
          # yes, rico...
          machine.ssh("command" => "mysql #{mysql_credentials(machine, db_name)} -D#{db_name} -h #{mysql_host} < #{dump_file}")
        else
          # tsv files in a database directory
          if machine.file_exists("file_name" => database_dir_name)
            # TODO check if it's really a directory
            
            # first create the database structure from the thoughtfully provided schema.sql
            if machine.file_exists("file_name" => schema_file)
              $logger.debug("schema file found, assuming that this is a tsv file dump")
              
              machine.ssh("command" => "mysql #{mysql_credentials(host, db_name)} -D#{db_name} -h #{mysql_host} < #{schema_file}")
            end
            
            # now for the tsv files themselves
            with_files(machine, database_dir_name, "*.tsv") do |file_name|
              $logger.debug"importing tsv file #{file_name}"
              
              matched = /(.+)\.tsv$/.match(file_name)
              if matched                 
                table_name = matched.captures.first
                full_file_name = database_dir_name + '/' + file_name
                
                line_count = machine.file_size("file_name" => full_file_name)
                batch_size = 100000
                if line_count > batch_size
                  $logger.debug "file is bigger than #{batch_size} lines, gonna split it"
                  # split the file into chunks of a comfortable size
                  prefix = '.split_'
                  file_name_with_prefix = file_name + prefix                
                  # TODO this fails miserably when dealing with multi-line values like BLOBs
                  machine.ssh("command" => "split -a 5 -d -l #{batch_size} #{full_file_name} #{full_file_name + prefix}") 
                  
                  # and import all chunk files created by 'split'
                  with_files(homachinest, database_dir_name, "#{file_name_with_prefix}*") do |chunk_file_name|
                    full_chunk_file_name = database_dir_name + '/' + chunk_file_name
                    machine.execute_sql(
                      "database" => db_name,
                      "statement" => "LOAD DATA LOCAL INFILE '#{full_chunk_file_name}' INTO TABLE #{table_name}"
                    )
                    machine.rm("file_name" => full_chunk_file_name)
                  end
                else
                  # import the whole file (it's small enough)
                  machine.execute_sql(
                    "database" => db_name,
                    "statement" => "LOAD DATA LOCAL INFILE '#{full_file_name}' INTO TABLE #{table_name}"
                  )  
                end
              end
            end
          end
        end

      ensure
        if might_have_extracted_tarball
          if machine.file_exists({"file_name" => dump_file})
            $logger.info "deleting previously extracted tarball at #{dump_file}"
            machine.rm({
              "file_name" => dump_file
            })
          end
        end
      end
    end
  end

  # cleanup
  if dump_has_been_extracted
    machine.rm({
      "file_name" => path_to_dump,
      "recursively" => "true"
    })
  end

  the_databases
end
