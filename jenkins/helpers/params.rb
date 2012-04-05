def param_jenkins_job(options = {})
  merge_options_with_defaults(options, {
    :lookup_method => lambda do
      @op.list_jenkins_jobs.map do |x|
        x["name"]
      end
    end
  })
  RHCP::CommandParam.new("jenkins_job", "the jenkins job configuration to work with", options)
end
