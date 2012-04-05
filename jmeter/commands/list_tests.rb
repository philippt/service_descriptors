description "lists the tests available for execution on this machine"

param :machine

display_type :list

mark_as_read_only

on_machine do |machine, params|
  machine.list_files("directory" => "tests").map do |file_name|
    parts = file_name.split(".")
    parts.pop
    parts.join(".")
  end
end