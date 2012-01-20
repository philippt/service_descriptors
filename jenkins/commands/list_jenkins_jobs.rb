description "lists the configured jenkins jobs"

add_columns [ :name, :disabled ]

mark_as_read_only

execute do |params|
  result = []
  json_data = @op.http_get("url" => "#{config_string('jenkins_url')}/api/json?depth=1")

  as_object = JSON.parse(json_data)
  as_object["jobs"].each do |job|
    xml_job = @op.http_get("url" => "#{config_string('jenkins_url')}/job/#{job_name_http("job_name" => job["name"])}/config.xml")
    xmldata = XmlSimple.xml_in(xml_job)
      
    result << {
      "name" => job["name"],
      "disabled" => xmldata["disabled"].first,
      "xmldata" => xml_job,
      "data" => xmldata
    }
  end

  result
end
