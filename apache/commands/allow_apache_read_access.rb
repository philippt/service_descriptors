description "changes the permissions of a file so that the apache service can read it"

param :machine
param! "file_name", "path to the file that should be modified"

on_machine do |machine, params|
  user = case machine.linux_distribution.split("_").first
  when "ubuntu"
    "www-data"
  when "sles"
    "wwwrun"
  when "centos"
    "apache"
  else
    nil
  end
  machine.chown("file_name" => params["file_name"], "ownership" => "#{user}:") unless user == nil
  #machine.chmod("file_name" => params["file_name"], "permissions" => "#{permissions}:")
end  