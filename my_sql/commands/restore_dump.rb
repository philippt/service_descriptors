description "restores the local database(s) from a dump. old data gets lost while doing so."

display_type :list

param :machine
param! :dump, "the dump from which we're going to restore"
param "database", "a list of databases that should be restored (default: all)", :allows_multiple_values => true

on_machine do |machine, params|
  dump_name = params["dump_name"]
  $logger.info("restoring local databases from dump " + dump_name)

  machine.restore_dump_from_file(params.merge("file_name" => dump_dir + '/' +  dump_name + '.tgz'))
end
