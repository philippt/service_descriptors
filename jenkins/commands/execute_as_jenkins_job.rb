description "executes a virtualop command string asynchronously with a little help from jenkins"

param! "command_string", "the virtualop command line that should be executed"

execute do |params|
  new_job = @op.create_jenkins_job(params)
  build_id = @op.trigger_build("jenkins_job" => new_job)
  
  [ new_job, build_id ]
end


