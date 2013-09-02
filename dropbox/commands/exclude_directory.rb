description "adds one or more directories to the exclusion list, then resynchronizes Dropbox."

param :machine
param! "dir_name", "a directory that should be excluded from syncing", :allows_multiple_values => true, :is_default_param => true

on_machine do |machine, params|
  machine.ssh("command" => "#{machine.home}/dropbox.py exclude add #{params["dir_name"].join(' ')}")
end
