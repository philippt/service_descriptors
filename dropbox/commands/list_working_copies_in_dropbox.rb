description "returns all working copies found in the dropbox folder"

param :machine

#mark_as_read_only

contributes_to :list_working_copies
result_as :list_working_copies

on_machine do |machine, params|
  result = []
  
  project_path = machine.home + '/Dropbox'
  
  machine.list_files("directory" => project_path).each do |path|
    result << {
      "path" => project_path + '/' + path,
      "type" => "dropbox",
      "name" => path.split("/").last
    }
  end if machine.file_exists("file_name" => project_path)
  
  result
end
