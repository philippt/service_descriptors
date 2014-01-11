description "creates a new jenkins job configuration"

param! "command_string", "the command line that should be executed if the jenkins job is executed"
param "job_name", "name for the job to be created"

github_params

execute do |params|
  job_name = (params.has_key?("job_name") and (params["job_name"] != '')) ? params["job_name"] : params["command_string"]
  job_name = URI.escape(job_name)
    
  job_exists = @op.list_jenkins_jobs.select do |job|
    job["name"] == job_name
  end.size > 0

  @op.delete_jenkins_job("jenkins_job" => params["job_name"]) if job_exists

  temp_file_name = Tempfile.new("virtualop_jenkins_template", '/tmp').path
  @op.with_machine("localhost") do |localhost|
    context = {}
    context['github_token'] = params['github_token'] if params['github_token'] # TODO snafoo!
    
    process_local_template(:blank_job, localhost, temp_file_name, binding())
    p = {
      "target_url" => "#{config_string('jenkins_url')}/createItem?name=#{job_name_http("job_name" => job_name)}",
      "extra_headers" => "Content-Type: application/xml;charset=UTF-8",
      "data_file" => temp_file_name
    }
    auth = config_string('jenkins_auth', '')
    p['basic_auth'] = auth if auth != ''
    localhost.http_post(p)
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
