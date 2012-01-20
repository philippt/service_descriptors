def job_name_http(params)
  job_name = params["job_name"]
  job_name.gsub!(" ", "%20")
  job_name.gsub!("/", "_")
  job_name
end
