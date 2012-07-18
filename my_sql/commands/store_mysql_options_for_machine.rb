description "stores mysql connection options for a machine into the dropdir backing mysql_options_from_file"

param :machine
param! "mysql_user", "the mysql user"
param "mysql_password", "the mysql password"
param "mysql_socket", "the mysql socket to use (if any)"

execute do |params|
  @plugin.state[:drop_dir].write_params_to_file(Thread.current['command'], params)
end
