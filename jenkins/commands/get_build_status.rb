param! :jenkins_job, "a jenkins job", :default_param => true
param! "number", "number identifying the build"

display_type :hash

execute do |params|
  job_name = job_name_http("job_name" => params["jenkins_job"])
  
  json_data = @op.http_get(
    "url" => "#{config_string('jenkins_url')}/job/#{job_name}/#{params["number"]}/api/json"
  )
  as_object = JSON.parse(json_data)
  pp as_object
  {
    "building" => as_object["building"],
    "duration" => as_object["duration"],
    "result" => as_object["result"]
  }
end

