param! :jenkins_job, "a jenkins job", :default_param => true

execute do |params|
  result = []
  
  job_name = job_name_http("job_name" => params["jenkins_job"])
  
  @op.http_post(
    "machine" => "localhost",
    "target_url" => "#{config_string('jenkins_url')}/job/#{job_name}/doDelete",
    "data" => "yo=mama"
  )
  
  @op.without_cache do
    @op.list_jenkins_jobs
  end
end  