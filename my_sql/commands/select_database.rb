description "preselects a database (context magick)"

param :machine
param :one_database

execute_request do |request, response|
  response.set_context('database' => request.get_param_value('database'))
end  
