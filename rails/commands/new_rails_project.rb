param :machine
param! "directory", "target directory"

on_machine do |machine, params|
  service_root = params["directory"]
  machine.ssh("command" => "rails new #{service_root} -d mysql")
  
  machine.configure_rails_service("directory" => service_root, "service_name" => service_root.split("/").last)
  
  %w|execjs therubyracer|.each do |gem|
    machine.append_to_file("file_name" => "#{service_root}/Gemfile", "content" => "gem '#{gem}'")
  end
  
  # TODO mysql_password
  machine.ssh("command" => "sed -ie 's/password:/password: the_password/' #{service_root}/config/database.yml")
  
  # param :data_repovendor/
  #@op.add_file_to_version_control("working_copy" => "?", "file_name" => %w|.gitignore .vop/ Gemfile Gemfile.lock README Rakefile app/ config.ru config/ db/ doc/ lib/ public/ script/ test/ vendor/|)
end
