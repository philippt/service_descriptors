description "creates a new jenkins job configuration"

param! "command_string", "the command line that should be executed if the jenkins job is executed"

execute do |params|
  job_name = URI.escape(params["command_string"])
    
  job_exists = @op.list_jenkins_jobs.select do |job|
    job["name"] == job_name
  end.size > 0

  unless job_exists
    temp_file_name = Tempfile.new("virtualop_jenkins_template", '/tmp').path
    @op.with_machine("localhost") do |localhost|
      process_local_template(:blank_job, localhost, temp_file_name, binding())
      localhost.http_post(
        "target_url" => "#{config_string('jenkins_url')}/createItem?name=#{job_name_http("job_name" => job_name)}",
        "extra_headers" => "Content-Type: application/xml;charset=UTF-8",
        "data_file" => temp_file_name
      )
    end    
  end

  sleep 1

  @op.without_cache do
    reloaded = @op.list_jenkins_jobs.select do |job|
      job["name"] == job_name
    end
    raise "could not find newly created job '#{job_name}' in jenkins job list - there probably was an error while creating the job." unless reloaded.size == 1
  end
  job_name
end
