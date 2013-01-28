param :machine
param! "directory", "target directory"
param! "service_name"

on_machine do |machine, params|
  process_local_template(:service_descriptor, machine, "#{params["directory"]}/.vop/services/#{params["service_name"]}.rb", binding())
  process_local_template(:install_command, machine, "#{params["directory"]}/.vop/commands/#{params["service_name"]}_install.rb", binding())
  
  # param :data_repovendor/
  #@op.add_file_to_version_control("working_copy" => "?", "file_name" => %w|.gitignore .vop/ Gemfile Gemfile.lock README Rakefile app/ config.ru config/ db/ doc/ lib/ public/ script/ test/ vendor/|)
end
