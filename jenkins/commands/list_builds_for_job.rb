description "returns a list of past executions for the specified jenkins job"

param! :jenkins_job, "a jenkins job", :default_param => true

add_columns [ :number, :url ]

execute do |params|
  result = []
  
  job_name = job_name_http("job_name" => params["jenkins_job"])
  
  json_data = @op.http_get(
    "url" => "#{config_string('jenkins_url')}/job/#{job_name}/api/json"
  )
  as_object = JSON.parse(json_data)
  as_object["builds"].each do |job|
    result << job
  end
  
  result
end
