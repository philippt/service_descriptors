description "returns a list of dropbox projects that have been synchronized onto this machine"

param :machine

mark_as_read_only

contributes_to :list_working_copies
result_as :list_working_copies

on_machine do |machine, params|
  project_path = config_string('owncloud_path') + '/projects'
  result = []
  
  machine.list_files("directory" => project_path).each do |path|
    result << {
      "path" => project_path + '/' + path,
      "type" => "owncloud",
      "name" => path.split("/").last
    }
  end if machine.file_exists("file_name" => project_path)
  
  result
end