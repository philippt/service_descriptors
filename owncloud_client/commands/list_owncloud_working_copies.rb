description "returns a list of dropbox projects that have been synchronized onto this machine"

param :machine

mark_as_read_only

contributes_to :list_working_copies
result_as :list_working_copies

on_machine do |machine, params|
  project_path = config_string('owncloud_path') + '/projects'
  machine.list_files("directory" => project_path).map do |path|
    {
      "path" => project_path + '/' + path,
      "type" => "owncloud",
      "name" => path.split("/").last
    }
  end
end