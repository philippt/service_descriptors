description "contributes machine-specific mysql options that are stored in a file on the virtualop machine"

param :machine

contributes_to :mysql_options

on_machine do |machine, params|
  @plugin.state[:drop_dir].read_local_dropdir.select { |x| x["machine"] == params["machine"] }.first
end
